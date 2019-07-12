#include "flutter_media_stream.h"

#define DEFAULT_WIDTH 1280
#define DEFAULT_HEIGHT 720
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

void FlutterMediaStream::GetUserMedia(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  std::string uuid = base_->GenerateUUID();
  scoped_refptr<RTCMediaStream> stream =
      base_->factory_->CreateStream(uuid.c_str());

  
  EncodableMap params;
  params[EncodableValue("streamId")] = uuid;

  auto it = constraints.find(EncodableValue("audio"));
  if (it != constraints.end()) {
    EncodableValue audio = it->second;
    switch (audio.type()) {
    case EncodableValue::Type::kBool:
        if (audio.BoolValue()) {
          GetUserAudio(constraints, stream, params);
        }
        break;
      case EncodableValue::Type::kMap:
        GetUserAudio(constraints, stream, params);
        break;
      default:
        break;
    }
  }

  it = constraints.find(EncodableValue("video"));
  if (it != constraints.end()) {
      EncodableValue video = it->second;
      switch (video.type()) {
      case EncodableValue::Type::kBool:
          if (video.BoolValue()) {
              GetUserVideo(constraints, stream, params);
          }
          break;
      case EncodableValue::Type::kMap:
          GetUserVideo(constraints, stream, params);
          break;
      default:
          break;
      }
  }

  base_->media_streams_[uuid] = stream;
  result->Success(&EncodableValue(params));
}

void addDefaultAudioConstraints(
    scoped_refptr<RTCMediaConstraints> audioConstraints) {
  audioConstraints->AddOptionalConstraint("googNoiseSuppression", "true");
  audioConstraints->AddOptionalConstraint("googEchoCancellation", "true");
  audioConstraints->AddOptionalConstraint("echoCancellation", "true");
  audioConstraints->AddOptionalConstraint("googEchoCancellation2", "true");
  audioConstraints->AddOptionalConstraint("googDAEchoCancellation", "true");
}

void FlutterMediaStream::GetUserAudio(const EncodableMap& constraints,
                                      scoped_refptr<RTCMediaStream> stream,
                                      EncodableMap& params) {

  bool enable_audio = false;
  scoped_refptr<RTCMediaConstraints> audioConstraints;
  auto it = constraints.find(EncodableValue("audio"));
  if (it != constraints.end()) {
      if (it->second.IsBool()) {
          audioConstraints = RTCMediaConstraints::Create();
          addDefaultAudioConstraints(audioConstraints);
          enable_audio = it->second.BoolValue();
      }
      if(it->second.IsMap()){
          audioConstraints = base_->ParseMediaConstraints(it->second.MapValue());
          enable_audio = true;
      }
  }
  
  // TODO: Select audio device by sourceId,

  if (enable_audio) {
      scoped_refptr<RTCAudioSource> source =
          base_->factory_->CreateAudioSource("audio_input");
      std::string uuid = base_->GenerateUUID();
      scoped_refptr<RTCAudioTrack> track =
          base_->factory_->CreateAudioTrack(source, uuid.c_str());

      EncodableMap track_info;
      track_info[EncodableValue("id")] = track->id();
      track_info[EncodableValue("label")] = track->id();
      track_info[EncodableValue("kind")] = track->kind();
      track_info[EncodableValue("enabled")] = track->enabled();

      EncodableList audioTracks;
      audioTracks.push_back(EncodableValue(track_info));
      params[EncodableValue("audioTracks")] = audioTracks;
      stream->AddTrack(track);
  }
}

std::string getFacingMode(const EncodableMap& mediaConstraints) {
    return mediaConstraints.find(EncodableValue("facingMode")) != mediaConstraints.end()
        ? mediaConstraints.find(EncodableValue("facingMode"))->second.StringValue()
             : "";
}

std::string getSourceIdConstraint(const EncodableMap& mediaConstraints) {
  auto it = mediaConstraints.find(EncodableValue("optional"));
  if ( it != mediaConstraints.end() &&
      it->second.IsList()) {
    EncodableList optional = it->second.ListValue();
    for (size_t i = 0, size = optional.size(); i < size; i++) {
      if (optional[i].IsMap()) {
        EncodableMap option = optional[i].MapValue();
        auto it2 = option.find(EncodableValue("sourceId"));
        if (it2 != option.end() && it2->second.IsString()) {
          return it2->second.StringValue();
        }
      }
    }
  }
  return "";
}

void FlutterMediaStream::GetUserVideo(
    const EncodableMap& constraints,
    scoped_refptr<RTCMediaStream> stream,
    EncodableMap& params) {

  EncodableMap video_constraints;
  EncodableMap video_mandatory;
  auto it = constraints.find(EncodableValue("video"));
  if (it != constraints.end() && it->second.IsMap()) {
    EncodableMap video_map = it->second.MapValue();
    if (video_map.find(EncodableValue("mandatory")) != video_map.end()) {
        video_mandatory = video_map.find(EncodableValue("mandatory"))->second.MapValue();
    }
  }

  std::string facing_mode = getFacingMode(video_constraints);
  boolean isFacing = facing_mode == "" || facing_mode != "environment";
  std::string sourceId = getSourceIdConstraint(video_constraints);
  /*
  int width = video_mandatory["minWidth"].isNumeric()
                  ? video_mandatory["minWidth"].asInt()
                  : DEFAULT_WIDTH;
  int height = video_mandatory["minHeight"].isNumeric()
                   ? video_mandatory["minHeight"].asInt()
                   : DEFAULT_HEIGHT;
  int fps = video_mandatory["minFrameRate"].isNumeric()
                ? video_mandatory["minFrameRate"].asInt()
                : DEFAULT_FPS;
 */
  scoped_refptr<RTCVideoCapturer> video_capturer;
  char strNameUTF8[128];
  char strGuidUTF8[128];
  int nb_video_devices = base_->video_device_->NumberOfDevices();

  for (int i = 0; i < nb_video_devices; i++) {
    base_->video_device_->GetDeviceName(i, strNameUTF8, 128, strGuidUTF8, 128);
    if (sourceId != "" && sourceId == strGuidUTF8) {
      video_capturer = base_->video_device_->Create(strNameUTF8, i);
      break;
	}
  }

  if (nb_video_devices == 0) return;

  if (!video_capturer.get()) {
    base_->video_device_->GetDeviceName(0, strNameUTF8, 128, strGuidUTF8, 128);
    video_capturer = base_->video_device_->Create(strNameUTF8, 0);
  }
  const char *video_source_label = "video_input";
  scoped_refptr<RTCVideoSource> source = base_->factory_->CreateVideoSource(
      video_capturer, video_source_label,
      base_->ParseMediaConstraints(video_constraints));

  std::string uuid = base_->GenerateUUID();
  scoped_refptr<RTCVideoTrack> track =
      base_->factory_->CreateVideoTrack(source, uuid.c_str());
  EncodableList videoTracks;
  EncodableMap info;
  info[EncodableValue("id")] = track->id();
  info[EncodableValue("label")] = track->id();
  info[EncodableValue("kind")] = track->kind();
  info[EncodableValue("enabled")] = track->enabled();
  videoTracks.push_back(EncodableValue(info));
  params[EncodableValue("videoTracks")] = videoTracks;
  stream->AddTrack(track);
}

void FlutterMediaStream::GetSources(
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  EncodableList array;

  int nb_audio_devices = base_->audio_device_->RecordingDevices();
  char strNameUTF8[128];
  char strGuidUTF8[128];

  for (int i = 0; i < nb_audio_devices; i++) {
    base_->audio_device_->RecordingDeviceName(i, strNameUTF8, strGuidUTF8);
    EncodableMap audio;
    audio[EncodableValue("label")] = std::string(strNameUTF8);
    audio[EncodableValue("deviceId")] = std::string(strGuidUTF8);
    audio[EncodableValue("facing")] = "";
    audio[EncodableValue("kind")] = "audioinput";

    array.push_back(EncodableValue(audio));
  }

  nb_audio_devices = base_->audio_device_->PlayoutDevices();
  for (int i = 0; i < nb_audio_devices; i++) {
    base_->audio_device_->PlayoutDeviceName(i, strNameUTF8, strGuidUTF8);
    EncodableMap audio;
    audio[EncodableValue("label")] = std::string(strGuidUTF8);
    audio[EncodableValue("deviceId")] = std::string(strNameUTF8);
    audio[EncodableValue("facing")] = "";
    audio[EncodableValue("kind")] = "audiooutput";
    array.push_back(EncodableValue(audio));
  }

  int nb_video_devices = base_->video_device_->NumberOfDevices();
  for (int i = 0; i < nb_video_devices; i++) {
    base_->video_device_->GetDeviceName(i, strNameUTF8, 128, strGuidUTF8, 128);
    EncodableMap video;
    video[EncodableValue("label")] = std::string(strGuidUTF8);
    video[EncodableValue("deviceId")] = std::string(strNameUTF8);
    video[EncodableValue("facing")] = i == 1 ? "front" : "back";
    video[EncodableValue("kind")] = "videoinput";
    array.push_back(EncodableValue(video));
  }
  result->Success(&EncodableValue(array));
}

void FlutterMediaStream::MediaStreamGetTracks(
    const std::string &stream_id,
    std::unique_ptr<MethodResult<EncodableValue>> result) {
  scoped_refptr<RTCMediaStream> stream = base_->MediaStreamForId(stream_id);

  if (stream) {
    EncodableMap params;
    EncodableList audioTracks;
    for (auto track : stream->GetAudioTracks()) {
      EncodableMap info;
      info[EncodableValue("id")] = track->id();
      info[EncodableValue("label")] = track->id();
      info[EncodableValue("kind")] = track->kind();
      info[EncodableValue("enabled")] = track->enabled();
      info[EncodableValue("remote")] = true;
      info[EncodableValue("readyState")] = "live";
      audioTracks.push_back(EncodableValue(info));
    }
    params[EncodableValue("audioTracks")] = audioTracks;

    EncodableList videoTracks;
    for (auto track : stream->GetVideoTracks()) {
      EncodableMap info;
      info[EncodableValue("id")] = track->id();
      info[EncodableValue("label")] = track->id();
      info[EncodableValue("kind")] = track->kind();
      info[EncodableValue("enabled")] = track->enabled();
      info[EncodableValue("remote")] = true;
      info[EncodableValue("readyState")] = "live";
      videoTracks.push_back(EncodableValue("info"));
    }
    params[EncodableValue("videoTracks")] = videoTracks;

    result->Success(&EncodableValue("params"));
  } else {
    result->Error("MediaStreamGetTracksFailed",
                  "MediaStreamGetTracks() media stream is null !");
  }
}

void FlutterMediaStream::MediaStreamDispose(
    const std::string &stream_id,
    std::unique_ptr<MethodResult<EncodableValue>> result) {}

void FlutterMediaStream::MediaStreamTrackSetEnable(
    const std::string &track_id,
    std::unique_ptr<MethodResult<EncodableValue>> result) {}

void FlutterMediaStream::MediaStreamTrackSwitchCamera(
    const std::string &track_id,
    std::unique_ptr<MethodResult<EncodableValue>> result) {}

void FlutterMediaStream::MediaStreamTrackDispose(
    const std::string &track_id,
    std::unique_ptr<MethodResult<EncodableValue>> result) {}
};  // namespace flutter_webrtc_plugin
