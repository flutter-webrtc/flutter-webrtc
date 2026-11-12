#include "flutter_external_media.h"
#include <algorithm>
#include <cstdint>
#include <map>
#include "rtc_video_frame.h"
namespace flutter_webrtc_plugin {
namespace {
const EncodableValue* Arg(const EncodableMap& a, const char* key) {
  const auto i = a.find(EncodableValue(key)); return i == a.end() ? nullptr : &i->second;
}
int64_t Number(const EncodableMap& a, const char* key) {
  const auto* v = Arg(a, key); if (!v) return -1;
  if (const auto* n = std::get_if<int32_t>(v)) return *n;
  if (const auto* n = std::get_if<int64_t>(v)) return *n;
  return -1;
}
uint8_t Clip(int v) { return static_cast<uint8_t>(std::clamp(v, 0, 255)); }
EncodableMap Track(const std::string& id, const char* kind) {
  return {{EncodableValue("id"), EncodableValue(id)},
          {EncodableValue("label"), EncodableValue("external")},
          {EncodableValue("kind"), EncodableValue(kind)},
          {EncodableValue("enabled"), EncodableValue(true)},
          {EncodableValue("settings"), EncodableValue(EncodableMap{})}};
}
}
struct FlutterExternalMedia::State {
  struct Source {
    std::string id, audio_id, video_id;
    scoped_refptr<RTCAudioSource> audio;
    scoped_refptr<RTCVideoSource> video;
    scoped_refptr<RTCMediaStream> stream;
    scoped_refptr<RTCMediaTrack> audio_track, video_track;
    int64_t audio_blocks = 0, video_frames = 0, flushes = 0, timestamp = -1;
  };
  FlutterWebRTCBase* base;
  std::map<std::string, std::unique_ptr<Source>> sources;
  explicit State(FlutterWebRTCBase* b) : base(b) {}
  void Remove(const std::string& id) {
    const auto i = sources.find(id); if (i == sources.end()) return;
    for (const auto& track_id : {i->second->audio_id, i->second->video_id}) {
      const auto track = base->local_tracks_.find(track_id);
      if (track != base->local_tracks_.end()) { track->second->set_enabled(false); base->local_tracks_.erase(track); }
    }
    base->local_streams_.erase(id); sources.erase(i);
  }
  ~State() { while (!sources.empty()) Remove(sources.begin()->first); }
};
FlutterExternalMedia::FlutterExternalMedia(FlutterWebRTCBase* b) : state_(new State(b)) {}
FlutterExternalMedia::~FlutterExternalMedia() = default;
void FlutterExternalMedia::ExternalMediaMethod(const MethodCallProxy& call,
                                               std::unique_ptr<MethodResultProxy> result) {
  auto& s = *state_;
  if (!s.base->external_audio_input_only_) { result->Error("external_input_required", "Initialize externalAudioInputOnly before creating the factory"); return; }
  const auto* args = call.arguments() ? std::get_if<EncodableMap>(call.arguments()) : nullptr;
  if (!args) { result->Error("external_media_arguments", "Expected argument map"); return; }
  const auto& a = *args;
  const auto method = call.method_name();
  if (method == "externalMediaCreate") {
    if (!s.sources.empty()) { result->Error("external_media_limit", "One external stream per factory is supported"); return; }
    const bool audio = findBoolean(a, "audio"), video = findBoolean(a, "video");
    if (!audio && !video) { result->Error("external_media_arguments", "At least one track is required"); return; }
    auto source = std::make_unique<State::Source>(); source->id = s.base->GenerateUUID();
    source->stream = s.base->factory_->CreateStream(source->id.c_str());
    if (!source->stream) { result->Error("external_media_create", "Stream unavailable"); return; }
    EncodableList audio_tracks, video_tracks;
    if (audio) {
      source->audio_id = source->id + "-audio";
      RTCAudioOptions options;
      const bool processing = findBoolean(a, "audioProcessing");
      options.echo_cancellation = processing; options.auto_gain_control = processing;
      options.noise_suppression = processing; options.highpass_filter = processing;
      source->audio = s.base->factory_->CreateAudioSource("external", RTCAudioSource::kCustom, options);
      if (!source->audio) { result->Error("external_media_create", "Custom audio source unavailable"); return; }
      auto track = s.base->factory_->CreateAudioTrack(source->audio, source->audio_id.c_str());
      if (!track) { result->Error("external_media_create", "Audio track unavailable"); return; }
      source->stream->AddTrack(track); source->audio_track = track;
      audio_tracks.push_back(EncodableValue(Track(source->audio_id, "audio")));
    }
    if (video) {
      source->video_id = source->id + "-video";
      source->video = s.base->factory_->CreateCustomVideoSource("external", RTCMediaConstraints::Create());
      if (!source->video) { result->Error("external_media_create", "Video source unavailable"); return; }
      auto track = s.base->factory_->CreateVideoTrack(source->video, source->video_id.c_str());
      if (!track) { result->Error("external_media_create", "Video track unavailable"); return; }
      source->stream->AddTrack(track); source->video_track = track;
      video_tracks.push_back(EncodableValue(Track(source->video_id, "video")));
    }
    if (source->audio_track) s.base->local_tracks_[source->audio_id] = source->audio_track;
    if (source->video_track) s.base->local_tracks_[source->video_id] = source->video_track;
    const auto id = source->id; s.base->local_streams_[id] = source->stream;
    s.sources[id] = std::move(source);
    result->Success(EncodableValue(EncodableMap{
      {EncodableValue("streamId"), EncodableValue(id)}, {EncodableValue("ownerTag"), EncodableValue("local")},
      {EncodableValue("audioTracks"), EncodableValue(audio_tracks)}, {EncodableValue("videoTracks"), EncodableValue(video_tracks)},
      {EncodableValue("renderReference"), EncodableValue(false)},
      {EncodableValue("videoTimestampSource"), EncodableValue("arrival")}})); return;
  }
  const auto id = findString(a, "streamId"); const auto it = s.sources.find(id);
  if (method == "externalMediaDispose") { s.Remove(id); result->Success(); return; }
  if (it == s.sources.end()) { result->Error("external_media_closed", "Unknown external stream"); return; }
  auto& source = *it->second;
  if (method == "externalMediaFlush") { ++source.flushes; result->Success(); return; }
  if (method == "externalMediaStats") {
    result->Success(EncodableValue(EncodableMap{{EncodableValue("audioBlocks"), EncodableValue(source.audio_blocks)},
      {EncodableValue("videoFrames"), EncodableValue(source.video_frames)}, {EncodableValue("flushes"), EncodableValue(source.flushes)}})); return;
  }
  const auto* value = Arg(a, "bytes");
  const auto* bytes = value ? std::get_if<std::vector<uint8_t>>(value) : nullptr;
  if (!bytes) { result->Error("external_media_arguments", "Expected byte buffer"); return; }
  if (method == "externalMediaAudio") {
    if (!source.audio || bytes->size() != 960) { result->Error("external_media_audio", "Expected480 mono48k PCM16 samples"); return; }
    int16_t pcm[480]; for (size_t k = 0; k < 480; ++k) pcm[k] = static_cast<int16_t>((*bytes)[k * 2] | ((*bytes)[k * 2 + 1] << 8));
    source.audio->CaptureFrame(pcm, 16, 48000, 1, 480); ++source.audio_blocks; result->Success(); return;
  }
  if (method == "externalMediaVideo") {
    const auto width = Number(a, "width"), height = Number(a, "height"), time = Number(a, "timestampUs");
    if (!source.video || width < 1 || height < 1 || width > 1920 || height > 1080 ||
        bytes->size() != static_cast<size_t>(width * height * 4) || time < 0 || time <= source.timestamp) {
      result->Error("external_media_video", "Expected packed BGRA <=1920x1080 and increasing timestampUs"); return;
    }
    const int w = static_cast<int>(width), h = static_cast<int>(height), cw = (w + 1) / 2, ch = (h + 1) / 2;
    std::vector<uint8_t> y(w * h), u(cw * ch), v(cw * ch);
    for (int row = 0; row < h; ++row) for (int col = 0; col < w; ++col) {
      const auto* p = bytes->data() + (row * w + col) * 4;
      y[row * w + col] = Clip(((66*p[2]+129*p[1]+25*p[0]+128)>>8)+16);
    }
    for (int row = 0; row < h; row += 2) for (int col = 0; col < w; col += 2) {
      int r=0,g=0,b=0,n=0;
      for (int dy=0;dy<2 && row+dy<h;++dy) for(int dx=0;dx<2 && col+dx<w;++dx) {
        const auto* p=bytes->data()+((row+dy)*w+col+dx)*4; b+=p[0];g+=p[1];r+=p[2];++n;
      }
      r/=n;g/=n;b/=n;const int k=(row/2)*cw+col/2;
      u[k]=Clip(((-38*r-74*g+112*b+128)>>8)+128);v[k]=Clip(((112*r-94*g-18*b+128)>>8)+128);
    }
    source.video->OnCapturedFrame(RTCVideoFrame::Create(w,h,y.data(),w,u.data(),cw,v.data(),cw));
    source.timestamp=time;++source.video_frames;result->Success();return;
  }
  result->NotImplemented();
}
}  // namespace flutter_webrtc_plugin
