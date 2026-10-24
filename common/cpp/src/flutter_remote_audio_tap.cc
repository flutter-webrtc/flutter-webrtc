#include "flutter_remote_audio_tap.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstring>
#include <mutex>
#include <thread>
#include <vector>

#include "rtc_audio_track.h"

namespace flutter_webrtc_plugin {

namespace {
// Up to 1 s of 48 kHz stereo is buffered between the audio thread and the
// delivery thread; beyond that, new data is dropped and counted.
constexpr size_t kMaxBufferedSamples = 48000 * 2;
}  // namespace

// The sink runs on the SDK's audio thread. It never waits: try_lock, copy into
// a preallocated buffer, notify. A delivery thread swaps the buffer out and
// posts it to the event channel (which hops to the platform thread).
class RemoteAudioTap : public libwebrtc::AudioTrackSink {
 public:
  RemoteAudioTap(const std::string& id,
                 scoped_refptr<RTCAudioTrack> track,
                 bool silence,
                 std::unique_ptr<EventChannelProxy> channel)
      : id_(id), track_(track), silence_(silence), channel_(std::move(channel)) {
    buffer_.reserve(kMaxBufferedSamples);
    out_.reserve(kMaxBufferedSamples);
    thread_ = std::thread([this] { Deliver(); });
    if (silence_) track_->SetVolume(0);
    track_->AddSink(this);
  }

  ~RemoteAudioTap() override {
    track_->RemoveSink(this);
    // The wrapper exposes no volume getter; restore the SDK default.
    if (silence_) track_->SetVolume(1);
    {
      std::lock_guard<std::mutex> lock(mutex_);
      stop_ = true;
    }
    wake_.notify_one();
    if (thread_.joinable()) thread_.join();
  }

  void OnData(const void* audio_data, int bits_per_sample, int sample_rate,
              size_t number_of_channels, size_t number_of_frames) override {
    ++callbacks_;
    if (bits_per_sample != 16 || !audio_data || number_of_channels == 0) {
      unsupported_frames_ += number_of_frames;
      return;
    }
    std::unique_lock<std::mutex> lock(mutex_, std::try_to_lock);
    if (!lock.owns_lock()) {
      contended_frames_ += number_of_frames;
      return;
    }
    const size_t n = number_of_frames * number_of_channels;
    if (!buffer_.empty() && (sample_rate != rate_ ||
                             static_cast<int>(number_of_channels) != channels_)) {
      format_dropped_frames_ += number_of_frames;  // wait for the old format to drain
      return;
    }
    if (buffer_.size() + n > kMaxBufferedSamples) {
      overflow_frames_ += number_of_frames;
      return;
    }
    rate_ = sample_rate;
    channels_ = static_cast<int>(number_of_channels);
    const int16_t* pcm = static_cast<const int16_t*>(audio_data);
    buffer_.insert(buffer_.end(), pcm, pcm + n);
    lock.unlock();
    wake_.notify_one();
  }

  EncodableMap Stats() const {
    return EncodableMap{
        {EncodableValue("callbacks"), EncodableValue(static_cast<int64_t>(callbacks_.load()))},
        {EncodableValue("deliveredFrames"), EncodableValue(static_cast<int64_t>(delivered_frames_.load()))},
        {EncodableValue("events"), EncodableValue(static_cast<int64_t>(events_.load()))},
        {EncodableValue("contendedFrames"), EncodableValue(static_cast<int64_t>(contended_frames_.load()))},
        {EncodableValue("overflowFrames"), EncodableValue(static_cast<int64_t>(overflow_frames_.load()))},
        {EncodableValue("formatDroppedFrames"), EncodableValue(static_cast<int64_t>(format_dropped_frames_.load()))},
        {EncodableValue("unsupportedFrames"), EncodableValue(static_cast<int64_t>(unsupported_frames_.load()))},
        {EncodableValue("silencedNativePlayout"), EncodableValue(silence_)},
    };
  }

 private:
  void Deliver() {
    std::unique_lock<std::mutex> lock(mutex_);
    while (!stop_) {
      wake_.wait_for(lock, std::chrono::milliseconds(20),
                     [this] { return stop_ || !buffer_.empty(); });
      if (stop_) break;
      if (buffer_.empty()) continue;
      out_.swap(buffer_);
      buffer_.clear();
      const int rate = rate_, channels = channels_;
      lock.unlock();
      const size_t frames = out_.size() / channels;
      std::vector<uint8_t> bytes(out_.size() * 2);
      std::memcpy(bytes.data(), out_.data(), bytes.size());
      out_.clear();
      channel_->Success(EncodableValue(EncodableMap{
                            {EncodableValue("data"), EncodableValue(bytes)},
                            {EncodableValue("sampleRate"), EncodableValue(rate)},
                            {EncodableValue("channels"), EncodableValue(channels)},
                            {EncodableValue("frames"), EncodableValue(static_cast<int64_t>(frames))},
                        }),
                        false);
      delivered_frames_ += frames;
      ++events_;
      lock.lock();
    }
  }

  std::string id_;
  scoped_refptr<RTCAudioTrack> track_;
  bool silence_;
  std::unique_ptr<EventChannelProxy> channel_;
  std::mutex mutex_;
  std::condition_variable wake_;
  std::vector<int16_t> buffer_, out_;
  int rate_ = 0, channels_ = 0;
  bool stop_ = false;
  std::thread thread_;
  std::atomic<uint64_t> callbacks_{0}, delivered_frames_{0}, events_{0}, contended_frames_{0},
      overflow_frames_{0}, format_dropped_frames_{0}, unsupported_frames_{0};
};

FlutterRemoteAudioTap::FlutterRemoteAudioTap(FlutterWebRTCBase* base) : base_(base) {}
FlutterRemoteAudioTap::~FlutterRemoteAudioTap() = default;

void FlutterRemoteAudioTap::RemoteAudioTapMethod(const MethodCallProxy& call,
                                                 std::unique_ptr<MethodResultProxy> result) {
  const auto* args = call.arguments() ? std::get_if<EncodableMap>(call.arguments()) : nullptr;
  if (!args) {
    result->Error("remote_audio_tap_arguments", "Expected argument map");
    return;
  }
  const auto method = call.method_name();
  if (method == "remoteAudioTapAttach") {
    const std::string track_id = findString(*args, "trackId");
    scoped_refptr<RTCMediaTrack> found;
    for (const auto& item : base_->peerconnections_) {
      for (const auto& receiver : item.second->receivers().std_vector()) {
        auto track = receiver->track();
        if (track && track->id().std_string() == track_id && track->kind().std_string() == "audio") {
          found = track;
        }
      }
      if (found) break;
    }
    if (!found) {
      result->Error("remote_audio_tap_track", "No remote audio track " + track_id);
      return;
    }
    const std::string id = base_->GenerateUUID();
    auto channel = EventChannelProxy::Create(base_->messenger_, base_->task_runner_,
                                             "FlutterWebRTC/remoteAudioTap/" + id);
    taps_[id] = std::make_unique<RemoteAudioTap>(
        id, scoped_refptr<RTCAudioTrack>(static_cast<RTCAudioTrack*>(found.get())),
        findBoolean(*args, "silenceNativePlayout"), std::move(channel));
    result->Success(EncodableValue(EncodableMap{{EncodableValue("tapId"), EncodableValue(id)}}));
    return;
  }
  const std::string id = findString(*args, "tapId");
  const auto it = taps_.find(id);
  if (method == "remoteAudioTapDetach") {
    if (it != taps_.end()) taps_.erase(it);
    result->Success();
    return;
  }
  if (it == taps_.end()) {
    result->Error("remote_audio_tap_closed", "Unknown remote audio tap");
    return;
  }
  if (method == "remoteAudioTapStats") {
    result->Success(EncodableValue(it->second->Stats()));
    return;
  }
  result->NotImplemented();
}

}  // namespace flutter_webrtc_plugin
