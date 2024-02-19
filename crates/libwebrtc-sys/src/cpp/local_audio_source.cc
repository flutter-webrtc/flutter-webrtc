#include "local_audio_source.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {

// Calculates audio level based on the provided audio data.
float calculate_audio_level(int16_t* data, int size) {
  double sum = 0.0;
  for (int i = 0; i < size; ++i) {
    sum += data[i] * data[i];
  }

  return std::sqrt(sum / size) / INT16_MAX;
}

rtc::scoped_refptr<LocalAudioSource> LocalAudioSource::Create(
    cricket::AudioOptions audio_options) {
  auto source = rtc::make_ref_counted<LocalAudioSource>();
  source->_options = audio_options;
  return source;
}

void LocalAudioSource::AddSink(webrtc::AudioTrackSinkInterface* sink) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  sinks_.push_back(sink);
}

void LocalAudioSource::RemoveSink(webrtc::AudioTrackSinkInterface* sink) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  sinks_.remove(sink);
}

void LocalAudioSource::OnData(const void* audio_data,
                              int bits_per_sample,
                              int sample_rate,
                              size_t number_of_channels,
                              size_t number_of_frames) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  if (cb_) {
    auto now = std::chrono::steady_clock::now();
    auto elapsed_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                          now - last_audio_level_recalculation_)
                          .count();

    if (elapsed_ms > 100) {
      last_audio_level_recalculation_ = now;
      auto volume = calculate_audio_level(
          (int16_t*)audio_data, number_of_channels * sample_rate / 100);
      bridge::on_audio_level_change(*cb_.value(), volume);
    }
  }

  for (auto* sink : sinks_) {
    sink->OnData(audio_data, bits_per_sample, sample_rate, number_of_channels,
                 number_of_frames);
  }
}

void LocalAudioSource::RegisterAudioLevelObserver(
    rust::Box<bridge::DynAudioSourceOnAudioLevelChangeCallback> cb) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  cb_ = std::move(cb);
}

void LocalAudioSource::UnregisterAudioLevelObserver() {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  cb_ = std::nullopt;
}

}  // namespace bridge
