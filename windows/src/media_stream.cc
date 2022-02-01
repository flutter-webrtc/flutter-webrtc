#include "flutter_webrtc.h"
#include "media_stream.h"

/// Calls Rust `EnumerateDevices()` and converts the received Rust vector of
/// `MediaDeviceInfo` info for Dart.
void enumerate_device(Box<Webrtc>& webrtc,
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

/// Parses the received constraints from Dart and passes them to Rust
/// `GetUserMedia()`, then converts the backed `MediaStream` info for Dart.
void get_user_media(const flutter::MethodCall<EncodableValue>& method_call,
                    Box<Webrtc>& webrtc,
                    std::unique_ptr<MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  auto args = GetValue<EncodableMap>(*method_call.arguments());
  auto constraints_arg = findMap(args, "constraints");

  auto video_arg = constraints_arg.find(EncodableValue("video"));
  auto audio_arg = constraints_arg.find(EncodableValue("audio"));

  MediaStreamConstraints constraints;

  constraints.video = parse_video_constraints(video_arg->second);
  constraints.audio = parse_audio_constraints(audio_arg->second);

  MediaStream user_media = webrtc->GetUserMedia(constraints);
  EncodableMap params;

  params[EncodableValue("streamId")] =
      EncodableValue(std::to_string(user_media.stream_id).c_str());
  params[EncodableValue("videoTracks")] =
      EncodableValue(get_params(TrackKind::kVideo, user_media));
  params[EncodableValue("audioTracks")] =
      EncodableValue(get_params(TrackKind::kAudio, user_media));

  result->Success(EncodableValue(params));
}

/// Parses video constraints recieved from Dart to Rust `VideoConstraints`.
VideoConstraints parse_video_constraints(EncodableValue video_arg) {
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
    auto it = video_map.find(EncodableValue("mandatory"));
    if (it != video_map.end()) {
      video_mandatory = GetValue<EncodableMap>(it->second);
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

/// Parses audio constraints received from Dart to Rust `AudioConstraints`.
AudioConstraints parse_audio_constraints(EncodableValue audio_arg) {
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

/// Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList`
/// for passing to Dart according to `TrackKind`.
EncodableList get_params(TrackKind type, MediaStream& user_media) {
  auto rust_tracks = type == TrackKind::kVideo ? user_media.video_tracks
                                               : user_media.audio_tracks;

  EncodableList tracks;

  if (rust_tracks.size() == 0) {
    tracks = EncodableList();
  } else {
    for (size_t i = 0; i < rust_tracks.size(); ++i) {
      EncodableMap info;
      info[EncodableValue("id")] =
          EncodableValue(std::to_string(rust_tracks[i].id).c_str());
      info[EncodableValue("label")] =
          EncodableValue(rust_tracks[i].label.c_str());
      info[EncodableValue("kind")] = EncodableValue(
          rust_tracks[i].kind == TrackKind::kVideo ? "video" : "audio");
      info[EncodableValue("enabled")] = EncodableValue(rust_tracks[i].enabled);

      tracks.push_back(EncodableValue(info));
    }
  }

  return tracks;
}

/// Disposes some media stream calling Rust `DisposeStream`.
void dispose_stream(const flutter::MethodCall<EncodableValue>& method_call,
                    Box<Webrtc>& webrtc,
                    std::unique_ptr<MethodResult<EncodableValue>> result) {
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto converted_id = std::stoi(findString(params, "streamId"));
  if (converted_id < 0) {
    result->Error("Stream id can`t be less then 0.");
    return;
  }

  webrtc->DisposeStream(converted_id);
  result->Success();
}
