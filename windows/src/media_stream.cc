#include "media_stream.h"
#include <mutex>
#include "flutter/standard_method_codec.h"
#include "flutter_webrtc.h"
#include "parsing.h"

namespace flutter_webrtc_plugin {

// `TrackObserverInterface` implementation forwarding events to the Flutter side
// via inner `flutter::EventSink`.
class TrackEventCallback : public TrackObserverInterface {
 public:
  struct Dependencies {
    // `EventSink` guard.
    std::unique_ptr<std::mutex> lock_ = std::make_unique<std::mutex>();
    // `EventSink`, used to send events to the Flutter side.
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
    // Flutter `EventChannel`, used to dispose the channel object.
    std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> chan_;
  };

  TrackEventCallback(std::shared_ptr<Dependencies> deps)
      : deps_(std::move(deps)){};

  ~TrackEventCallback() {
    if (deps_->chan_) {
      deps_->chan_->SetStreamHandler(nullptr);
    }
  }

  void OnEnded() {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[flutter::EncodableValue("event")] = "onended";
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  }

 private:
  std::shared_ptr<Dependencies> deps_;
};

// Calls Rust `EnumerateDevices()` and converts the received Rust vector of
// `MediaDeviceInfo` info for Dart.
void EnumerateDevice(rust::Box<Webrtc>& webrtc,
                     std::unique_ptr<MethodResult<EncodableValue>> result) {
  rust::Vec<MediaDeviceInfo> devices = webrtc->EnumerateDevices();

  EncodableList sources;

  for (size_t i = 0; i < devices.size(); ++i) {
    std::string kind;
    switch (devices[i].kind) {
      case MediaDeviceKind::kAudioInput:
        kind = "audioinput";
        break;

      case MediaDeviceKind::kAudioOutput:
        kind = "audiooutput";
        break;

      case MediaDeviceKind::kVideoInput:
        kind = "videoinput";
        break;

      default:
        result->Error("Invalid MediaDeviceKind");
        return;
    }

    EncodableMap info;
    info[EncodableValue("label")] =
        EncodableValue(std::string(devices[i].label));
    info[EncodableValue("deviceId")] =
        EncodableValue(std::string(devices[i].device_id));
    info[EncodableValue("kind")] = EncodableValue(kind);
    info[EncodableValue("groupId")] = EncodableValue(std::string(""));

    sources.push_back(EncodableValue(info));
  }

  EncodableMap params;
  params[EncodableValue("sources")] = EncodableValue(sources);

  result->Success(EncodableValue(params));
}

// Parses the received constraints from Dart and passes them to Rust
// `GetMedia()`, then converts the backed `MediaStream` info for Dart.
void GetMedia(rust::Box<Webrtc>& webrtc,
              flutter::BinaryMessenger* messenger,
              const flutter::MethodCall<EncodableValue>& method_call,
              std::unique_ptr<flutter::MethodResult<EncodableValue>> result,
              bool is_display) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  auto args = GetValue<EncodableMap>(*method_call.arguments());
  auto constraints_arg = findMap(args, "constraints");

  auto video_arg = findMap(constraints_arg, "video");
  auto audio_arg = findMap(constraints_arg, "audio");

  MediaStreamConstraints constraints;

  constraints.video = ParseVideoConstraints(video_arg);
  constraints.audio = ParseAudioConstraints(audio_arg);

  MediaStream media = webrtc->GetMedia(constraints, is_display);

  for (size_t i = 0; i < media.video_tracks.size(); ++i) {
    RegisterTrackObserver(&webrtc, messenger, media.video_tracks[i].id);
  }

  for (size_t i = 0; i < media.audio_tracks.size(); ++i) {
    RegisterTrackObserver(&webrtc, messenger, media.audio_tracks[i].id);
  }

  EncodableMap params;

  params[EncodableValue("streamId")] =
      EncodableValue(std::to_string(media.stream_id));
  params[EncodableValue("videoTracks")] =
      EncodableValue(GetParams(TrackKind::kVideo, media));
  params[EncodableValue("audioTracks")] =
      EncodableValue(GetParams(TrackKind::kAudio, media));

  result->Success(EncodableValue(params));
}

// Parses video constraints recieved from Dart to Rust `VideoConstraints`.
VideoConstraints ParseVideoConstraints(EncodableValue video_arg) {
  EncodableMap video_mandatory;

  size_t width = DEFAULT_WIDTH;
  size_t height = DEFAULT_HEIGHT;
  size_t fps = DEFAULT_FPS;
  std::string video_device_id;
  bool video_required;

  if (TypeIs<bool>(video_arg)) {
    if (GetValue<bool>(video_arg)) {
      video_required = true;
    } else {
      width = 0;
      height = 0;
      fps = 0;
      video_required = false;
    }
    video_device_id = std::string();
  } else {
    EncodableMap video_map = GetValue<EncodableMap>(video_arg);
    video_mandatory = findMap(video_map, "mandatory");
    if (!video_mandatory.empty()) {
      std::string width_s = findString(video_mandatory, "minWidth");
      std::string height_s = findString(video_mandatory, "minHeight");
      std::string fps_s = findString(video_mandatory, "minFrameRate");
      if (!width_s.empty()) {
        int width_n = std::stoi(width_s);
        if (width_n > 0) {
          width = width_n;
        }
      }
      if (!height_s.empty()) {
        int height_n = std::stoi(height_s);
        if (height_n > 0) {
          height = height_n;
        }
      }
      if (!fps_s.empty()) {
        int fps_n = std::stoi(fps_s);
        if (fps_n > 0) {
          fps = fps_n;
        }
      }
    }
    video_device_id = findString(video_map, "deviceId");
    video_required = true;
  }

  VideoConstraints video_constraints;

  video_constraints.required = video_required;
  video_constraints.width = width;
  video_constraints.height = height;
  video_constraints.frame_rate = fps;
  video_constraints.device_id = video_device_id;

  return video_constraints;
}

// Parses audio constraints received from Dart to Rust `AudioConstraints`.
AudioConstraints ParseAudioConstraints(EncodableValue audio_arg) {
  EncodableValue audio_device_id;
  bool audio_required;

  if (TypeIs<bool>(audio_arg)) {
    if (GetValue<bool>(audio_arg)) {
      audio_required = true;
    } else {
      audio_required = false;
    }
    audio_device_id = std::string();
  } else {
    EncodableMap audio_map = GetValue<EncodableMap>(audio_arg);
    audio_device_id = findString(audio_map, "deviceId");
    audio_required = true;
  }

  AudioConstraints audio_constraints;

  audio_constraints.required = audio_required;
  audio_constraints.device_id =
      rust::String(GetValue<std::string>(audio_device_id));

  return audio_constraints;
}

// Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList`
// for passing to Dart according to `TrackKind`.
EncodableList GetParams(TrackKind type, MediaStream& media) {
  auto rust_tracks =
      type == TrackKind::kVideo ? media.video_tracks : media.audio_tracks;

  EncodableList tracks;

  if (rust_tracks.size() == 0) {
    tracks = EncodableList();
  } else {
    for (size_t i = 0; i < rust_tracks.size(); ++i) {
      EncodableMap info;
      info[EncodableValue("id")] =
          EncodableValue(std::to_string(rust_tracks[i].id));
      info[EncodableValue("label")] =
          EncodableValue(std::string(rust_tracks[i].label));
      info[EncodableValue("kind")] = EncodableValue(
          rust_tracks[i].kind == TrackKind::kVideo ? "video" : "audio");
      info[EncodableValue("enabled")] = EncodableValue(rust_tracks[i].enabled);

      tracks.push_back(EncodableValue(info));
    }
  }

  return tracks;
}

// Changes the `enabled` property of the specified media track calling Rust
// `SetTrackEnabled`.
void SetTrackEnabled(
    rust::Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string track_id = findString(params, "trackId");
  const bool enabled =
      GetValue<bool>(params.find(EncodableValue("enabled"))->second);

  webrtc->SetTrackEnabled((uint64_t)std::stoi(track_id), enabled);

  result->Success();
}

// Disposes some media stream calling Rust `DisposeStream`.
void DisposeStream(
    rust::Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto converted_id = std::stoi(findString(params, "streamId"));
  if (converted_id < 0) {
    result->Error("Stream id can`t be less then 0.");
    return;
  }

  webrtc->DisposeStream(converted_id);
  result->Success();
}

// Registers an observer for the `MediaStreamTrackInterface`.
void RegisterTrackObserver(Box<Webrtc>* webrtc,
                           flutter::BinaryMessenger* messenger,
                           uint64_t track_id) {
  auto ctx = std::make_shared<TrackEventCallback::Dependencies>();
  auto observer = std::make_unique<TrackEventCallback>(ctx);

  rust::String error =
      (*webrtc)->RegisterTrackObserver(track_id, std::move(observer));

  if (error == "") {
    auto event_channel = std::make_unique<EventChannel<EncodableValue>>(
        messenger, "MediaStreamTrack/" + std::to_string(track_id),
        &StandardMethodCodec::GetInstance());

    std::weak_ptr<TrackEventCallback::Dependencies> weak_deps(ctx);
    auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
        [=](const flutter::EncodableValue* arguments,
            std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                events)
            -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
          auto context = weak_deps.lock();
          if (context) {
            const std::lock_guard<std::mutex> lock(*context->lock_);
            context->sink_ = std::move(events);
          }
          return nullptr;
        },
        [=](const flutter::EncodableValue* arguments)
            -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
          auto context = weak_deps.lock();
          if (context) {
            const std::lock_guard<std::mutex> lock(*context->lock_);
            context->sink_.reset();
          }
          return nullptr;
        });
    event_channel->SetStreamHandler(std::move(handler));
    ctx->chan_ = std::move(event_channel);
  }
}

}  // namespace flutter_webrtc_plugin
