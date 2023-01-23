#include "flutter_media_stream.h"

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

FlutterMediaStream::FlutterMediaStream(FlutterWebRTCBase* base) : base_(base) {
  base_->audio_device_->OnDeviceChange([&] {
    EncodableMap info;
    info[EncodableValue("event")] = "onDeviceChange";
    base_->event_channel()->Success(EncodableValue(info), false);
  });
}

void FlutterMediaStream::GetUserMedia(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  std::string uuid = base_->GenerateUUID();
  scoped_refptr<RTCMediaStream> stream =
      base_->factory_->CreateStream(uuid.c_str());

  EncodableMap params;
  params[EncodableValue("streamId")] = EncodableValue(uuid);

  auto it = constraints.find(EncodableValue("audio"));
  if (it != constraints.end()) {
    EncodableValue audio = it->second;
    if (TypeIs<bool>(audio)) {
      if (true == GetValue<bool>(audio)) {
        GetUserAudio(constraints, stream, params);
      }
    } else if (TypeIs<EncodableMap>(audio)) {
      GetUserAudio(constraints, stream, params);
    } else {
      params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());
    }
  } else {
    params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());
  }

  it = constraints.find(EncodableValue("video"));
  params[EncodableValue("videoTracks")] = EncodableValue(EncodableList());
  if (it != constraints.end()) {
    EncodableValue video = it->second;
    if (TypeIs<bool>(video)) {
      if (true == GetValue<bool>(video)) {
        GetUserVideo(constraints, stream, params);
      }
    } else if (TypeIs<EncodableMap>(video)) {
      GetUserVideo(constraints, stream, params);
    }
  }

  base_->local_streams_[uuid] = stream;
  result->Success(EncodableValue(params));
}

void addDefaultAudioConstraints(
    scoped_refptr<RTCMediaConstraints> audioConstraints) {
  audioConstraints->AddOptionalConstraint("googNoiseSuppression", "true");
  audioConstraints->AddOptionalConstraint("googEchoCancellation", "true");
  audioConstraints->AddOptionalConstraint("echoCancellation", "true");
  audioConstraints->AddOptionalConstraint("googEchoCancellation2", "true");
  audioConstraints->AddOptionalConstraint("googDAEchoCancellation", "true");
}

std::string getSourceIdConstraint(const EncodableMap& mediaConstraints) {
  auto it = mediaConstraints.find(EncodableValue("optional"));
  if (it != mediaConstraints.end() && TypeIs<EncodableList>(it->second)) {
    EncodableList optional = GetValue<EncodableList>(it->second);
    for (size_t i = 0, size = optional.size(); i < size; i++) {
      if (TypeIs<EncodableMap>(optional[i])) {
        EncodableMap option = GetValue<EncodableMap>(optional[i]);
        auto it2 = option.find(EncodableValue("sourceId"));
        if (it2 != option.end() && TypeIs<std::string>(it2->second)) {
          return GetValue<std::string>(it2->second);
        }
      }
    }
  }
  return "";
}

std::string getDeviceIdConstraint(const EncodableMap& mediaConstraints) {
  auto it = mediaConstraints.find(EncodableValue("deviceId"));
  if (it != mediaConstraints.end() && TypeIs<std::string>(it->second)) {
    return GetValue<std::string>(it->second);
  }
  return "";
}

void FlutterMediaStream::GetUserAudio(const EncodableMap& constraints,
                                      scoped_refptr<RTCMediaStream> stream,
                                      EncodableMap& params) {
  bool enable_audio = false;
  scoped_refptr<RTCMediaConstraints> audioConstraints;
  std::string sourceId;
  std::string deviceId;
  auto it = constraints.find(EncodableValue("audio"));
  if (it != constraints.end()) {
    EncodableValue audio = it->second;
    if (TypeIs<bool>(audio)) {
      audioConstraints = RTCMediaConstraints::Create();
      addDefaultAudioConstraints(audioConstraints);
      enable_audio = GetValue<bool>(audio);
      sourceId = "";
      deviceId = "";
    }
    if (TypeIs<EncodableMap>(audio)) {
      EncodableMap localMap = GetValue<EncodableMap>(audio);
      sourceId = getSourceIdConstraint(localMap);
      deviceId = getDeviceIdConstraint(localMap);
      audioConstraints = base_->ParseMediaConstraints(localMap);
      enable_audio = true;
    }
  }

  // Selecting audio input device by sourceId and audio output device by
  // deviceId

  if (enable_audio) {
    char strRecordingName[256];
    char strRecordingGuid[256];
    int playout_devices = base_->audio_device_->PlayoutDevices();
    int recording_devices = base_->audio_device_->RecordingDevices();

    for (uint16_t i = 0; i < recording_devices; i++) {
      base_->audio_device_->RecordingDeviceName(i, strRecordingName,
                                                strRecordingGuid);
      if (sourceId != "" && sourceId == strRecordingGuid) {
        base_->audio_device_->SetRecordingDevice(i);
      }
    }

    char strPlayoutName[256];
    char strPlayoutGuid[256];
    for (uint16_t i = 0; i < playout_devices; i++) {
      base_->audio_device_->PlayoutDeviceName(i, strPlayoutName,
                                              strPlayoutGuid);
      if (deviceId != "" && deviceId == strPlayoutGuid) {
        base_->audio_device_->SetPlayoutDevice(i);
      }
    }

    scoped_refptr<RTCAudioSource> source =
        base_->factory_->CreateAudioSource("audio_input");
    std::string uuid = base_->GenerateUUID();
    scoped_refptr<RTCAudioTrack> track =
        base_->factory_->CreateAudioTrack(source, uuid.c_str());

    std::string track_id = track->id().std_string();

    EncodableMap track_info;
    track_info[EncodableValue("id")] = EncodableValue(track->id().std_string());
    track_info[EncodableValue("label")] =
        EncodableValue(track->id().std_string());
    track_info[EncodableValue("kind")] =
        EncodableValue(track->kind().std_string());
    track_info[EncodableValue("enabled")] = EncodableValue(track->enabled());

    EncodableList audioTracks;
    audioTracks.push_back(EncodableValue(track_info));
    params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);
    stream->AddTrack(track);

    base_->local_tracks_[track->id().std_string()] = track;
  }
}

std::string getFacingMode(const EncodableMap& mediaConstraints) {
  return mediaConstraints.find(EncodableValue("facingMode")) !=
                 mediaConstraints.end()
             ? GetValue<std::string>(
                   mediaConstraints.find(EncodableValue("facingMode"))->second)
             : "";
}

EncodableValue getConstrainInt(const EncodableMap& constraints,
                               const std::string& key) {
  EncodableValue value;
  auto it = constraints.find(EncodableValue(key));
  if (it != constraints.end()) {
    if (TypeIs<int>(it->second)) {
      return it->second;
    }

    if (TypeIs<EncodableMap>(it->second)) {
      EncodableMap innerMap = GetValue<EncodableMap>(it->second);
      auto it2 = innerMap.find(EncodableValue("ideal"));
      if (it2 != innerMap.end() && TypeIs<int>(it2->second)) {
        return it2->second;
      }
    }
  }

  return EncodableValue();
}

void FlutterMediaStream::GetUserVideo(const EncodableMap& constraints,
                                      scoped_refptr<RTCMediaStream> stream,
                                      EncodableMap& params) {
  EncodableMap video_constraints;
  EncodableMap video_mandatory;
  auto it = constraints.find(EncodableValue("video"));
  if (it != constraints.end() && TypeIs<EncodableMap>(it->second)) {
    video_constraints = GetValue<EncodableMap>(it->second);
    if (video_constraints.find(EncodableValue("mandatory")) !=
        video_constraints.end()) {
      video_mandatory = GetValue<EncodableMap>(
          video_constraints.find(EncodableValue("mandatory"))->second);
    }
  }

  std::string facing_mode = getFacingMode(video_constraints);
  // bool isFacing = facing_mode == "" || facing_mode != "environment";
  std::string sourceId = getSourceIdConstraint(video_constraints);

  EncodableValue widthValue = getConstrainInt(video_constraints, "width");

  if (widthValue == EncodableValue())
    widthValue = findEncodableValue(video_mandatory, "minWidth");

  if (widthValue == EncodableValue())
    widthValue = findEncodableValue(video_mandatory, "width");

  EncodableValue heightValue = getConstrainInt(video_constraints, "height");

  if (heightValue == EncodableValue())
    heightValue = findEncodableValue(video_mandatory, "minHeight");

  if (heightValue == EncodableValue())
    heightValue = findEncodableValue(video_mandatory, "height");

  EncodableValue fpsValue = getConstrainInt(video_constraints, "frameRate");

  if (fpsValue == EncodableValue())
    fpsValue = findEncodableValue(video_mandatory, "minFrameRate");

  if (fpsValue == EncodableValue())
    fpsValue = findEncodableValue(video_mandatory, "frameRate");

  scoped_refptr<RTCVideoCapturer> video_capturer;
  char strNameUTF8[256];
  char strGuidUTF8[256];
  int nb_video_devices = base_->video_device_->NumberOfDevices();

  int32_t width = toInt(widthValue, DEFAULT_WIDTH);
  int32_t height = toInt(heightValue, DEFAULT_HEIGHT);
  int32_t fps = toInt(fpsValue, DEFAULT_FPS);

  for (int i = 0; i < nb_video_devices; i++) {
    base_->video_device_->GetDeviceName(i, strNameUTF8, 256, strGuidUTF8, 256);
    if (sourceId != "" && sourceId == strGuidUTF8) {
      video_capturer =
          base_->video_device_->Create(strNameUTF8, i, width, height, fps);
      break;
    }
  }

  if (nb_video_devices == 0)
    return;

  if (!video_capturer.get()) {
    base_->video_device_->GetDeviceName(0, strNameUTF8, 128, strGuidUTF8, 128);
    video_capturer =
        base_->video_device_->Create(strNameUTF8, 0, width, height, fps);
  }

  if (!video_capturer.get())
    return;

  const char* video_source_label = "video_input";
  scoped_refptr<RTCVideoSource> source = base_->factory_->CreateVideoSource(
      video_capturer, video_source_label,
      base_->ParseMediaConstraints(video_constraints));

  std::string uuid = base_->GenerateUUID();
  scoped_refptr<RTCVideoTrack> track =
      base_->factory_->CreateVideoTrack(source, uuid.c_str());

  EncodableList videoTracks;
  EncodableMap info;
  info[EncodableValue("id")] = EncodableValue(track->id().std_string());
  info[EncodableValue("label")] = EncodableValue(track->id().std_string());
  info[EncodableValue("kind")] = EncodableValue(track->kind().std_string());
  info[EncodableValue("enabled")] = EncodableValue(track->enabled());
  videoTracks.push_back(EncodableValue(info));
  params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

  stream->AddTrack(track);

  base_->local_tracks_[track->id().std_string()] = track;
}

void FlutterMediaStream::GetSources(std::unique_ptr<MethodResultProxy> result) {
  EncodableList sources;

  int nb_audio_devices = base_->audio_device_->RecordingDevices();
  char strNameUTF8[RTCAudioDevice::kAdmMaxDeviceNameSize + 1] = {0};
  char strGuidUTF8[RTCAudioDevice::kAdmMaxGuidSize + 1] = {0};

  for (uint16_t i = 0; i < nb_audio_devices; i++) {
    base_->audio_device_->RecordingDeviceName(i, strNameUTF8, strGuidUTF8);
    EncodableMap audio;
    audio[EncodableValue("label")] = EncodableValue(std::string(strNameUTF8));
    audio[EncodableValue("deviceId")] =
        EncodableValue(std::string(strGuidUTF8));
    audio[EncodableValue("facing")] = "";
    audio[EncodableValue("kind")] = "audioinput";
    sources.push_back(EncodableValue(audio));
  }

  nb_audio_devices = base_->audio_device_->PlayoutDevices();
  for (uint16_t i = 0; i < nb_audio_devices; i++) {
    base_->audio_device_->PlayoutDeviceName(i, strNameUTF8, strGuidUTF8);
    EncodableMap audio;
    audio[EncodableValue("label")] = EncodableValue(std::string(strNameUTF8));
    audio[EncodableValue("deviceId")] =
        EncodableValue(std::string(strGuidUTF8));
    audio[EncodableValue("facing")] = "";
    audio[EncodableValue("kind")] = "audiooutput";
    sources.push_back(EncodableValue(audio));
  }

  int nb_video_devices = base_->video_device_->NumberOfDevices();
  for (int i = 0; i < nb_video_devices; i++) {
    base_->video_device_->GetDeviceName(i, strNameUTF8, 128, strGuidUTF8, 128);
    EncodableMap video;
    video[EncodableValue("label")] = EncodableValue(std::string(strNameUTF8));
    video[EncodableValue("deviceId")] =
        EncodableValue(std::string(strGuidUTF8));
    video[EncodableValue("facing")] = i == 1 ? "front" : "back";
    video[EncodableValue("kind")] = "videoinput";
    sources.push_back(EncodableValue(video));
  }
  EncodableMap params;
  params[EncodableValue("sources")] = EncodableValue(sources);
  result->Success(EncodableValue(params));
}

void FlutterMediaStream::SelectAudioOutput(
    const std::string& device_id,
    std::unique_ptr<MethodResultProxy> result) {
  char strPlayoutName[256];
  char strPlayoutGuid[256];
  int playout_devices = base_->audio_device_->PlayoutDevices();
  bool found = false;
  for (uint16_t i = 0; i < playout_devices; i++) {
    base_->audio_device_->PlayoutDeviceName(i, strPlayoutName, strPlayoutGuid);
    if (device_id != "" && device_id == strPlayoutGuid) {
      base_->audio_device_->SetPlayoutDevice(i);
      found = true;
      break;
    }
  }
  if (!found) {
    result->Error("Bad Arguments", "Not found device id: " + device_id);
    return;
  }
  result->Success();
}

void FlutterMediaStream::SelectAudioInput(
    const std::string& device_id,
    std::unique_ptr<MethodResultProxy> result) {
  char strPlayoutName[256];
  char strPlayoutGuid[256];
  int playout_devices = base_->audio_device_->RecordingDevices();
  bool found = false;
  for (uint16_t i = 0; i < playout_devices; i++) {
    base_->audio_device_->RecordingDeviceName(i, strPlayoutName,
                                              strPlayoutGuid);
    if (device_id != "" && device_id == strPlayoutGuid) {
      base_->audio_device_->SetRecordingDevice(i);
      found = true;
      break;
    }
  }
  if (!found) {
    result->Error("Bad Arguments", "Not found device id: " + device_id);
    return;
  }
  result->Success();
}

void FlutterMediaStream::MediaStreamGetTracks(
    const std::string& stream_id,
    std::unique_ptr<MethodResultProxy> result) {
  scoped_refptr<RTCMediaStream> stream = base_->MediaStreamForId(stream_id);

  if (stream) {
    EncodableMap params;
    EncodableList audioTracks;

    auto audio_tracks = stream->audio_tracks();
    for (auto track : audio_tracks.std_vector()) {
      base_->local_tracks_[track->id().std_string()] = track;
      EncodableMap info;
      info[EncodableValue("id")] = EncodableValue(track->id().std_string());
      info[EncodableValue("label")] = EncodableValue(track->id().std_string());
      info[EncodableValue("kind")] = EncodableValue(track->kind().std_string());
      info[EncodableValue("enabled")] = EncodableValue(track->enabled());
      info[EncodableValue("remote")] = EncodableValue(true);
      info[EncodableValue("readyState")] = "live";
      audioTracks.push_back(EncodableValue(info));
    }
    params[EncodableValue("audioTracks")] = EncodableValue(audioTracks);

    EncodableList videoTracks;
    auto video_tracks = stream->video_tracks();
    for (auto track : video_tracks.std_vector()) {
      base_->local_tracks_[track->id().std_string()] = track;
      EncodableMap info;
      info[EncodableValue("id")] = EncodableValue(track->id().std_string());
      info[EncodableValue("label")] = EncodableValue(track->id().std_string());
      info[EncodableValue("kind")] = EncodableValue(track->kind().std_string());
      info[EncodableValue("enabled")] = EncodableValue(track->enabled());
      info[EncodableValue("remote")] = EncodableValue(true);
      info[EncodableValue("readyState")] = "live";
      videoTracks.push_back(EncodableValue(info));
    }

    params[EncodableValue("videoTracks")] = EncodableValue(videoTracks);

    result->Success(EncodableValue(params));
  } else {
    result->Error("MediaStreamGetTracksFailed",
                  "MediaStreamGetTracks() media stream is null !");
  }
}

void FlutterMediaStream::MediaStreamDispose(
    const std::string& stream_id,
    std::unique_ptr<MethodResultProxy> result) {
  scoped_refptr<RTCMediaStream> stream = base_->MediaStreamForId(stream_id);

  if (!stream) {
    result->Error("MediaStreamDisposeFailed",
                  "stream [" + stream_id + "] not found!");
    return;
  }

  vector<scoped_refptr<RTCAudioTrack>> audio_tracks = stream->audio_tracks();

  for (auto track : audio_tracks.std_vector()) {
    stream->RemoveTrack(track);
    base_->local_tracks_.erase(track->id().std_string());
  }

  vector<scoped_refptr<RTCVideoTrack>> video_tracks = stream->video_tracks();
  for (auto track : video_tracks.std_vector()) {
    stream->RemoveTrack(track);
    base_->local_tracks_.erase(track->id().std_string());
  }

  base_->RemoveStreamForId(stream_id);
  result->Success();
}

void FlutterMediaStream::CreateLocalMediaStream(
    std::unique_ptr<MethodResultProxy> result) {
  std::string uuid = base_->GenerateUUID();
  scoped_refptr<RTCMediaStream> stream =
      base_->factory_->CreateStream(uuid.c_str());

  EncodableMap params;
  params[EncodableValue("streamId")] = EncodableValue(uuid);

  base_->local_streams_[uuid] = stream;
  result->Success(EncodableValue(params));
}

void FlutterMediaStream::MediaStreamTrackSetEnable(
    const std::string& track_id,
    std::unique_ptr<MethodResultProxy> result) {
  result->Success();
}

void FlutterMediaStream::MediaStreamTrackSwitchCamera(
    const std::string& track_id,
    std::unique_ptr<MethodResultProxy> result) {
  result->Success();
}

void FlutterMediaStream::MediaStreamTrackDispose(
    const std::string& track_id,
    std::unique_ptr<MethodResultProxy> result) {
  for (auto it : base_->local_streams_) {
    auto stream = it.second;
    auto audio_tracks = stream->audio_tracks();
    for (auto track : audio_tracks.std_vector()) {
      if (track->id().std_string() == track_id) {
        stream->RemoveTrack(track);
      }
    }
    auto video_tracks = stream->video_tracks();
    for (auto track : video_tracks.std_vector()) {
      if (track->id().std_string() == track_id) {
        stream->RemoveTrack(track);
      }
    }
  }
  base_->RemoveMediaTrackForId(track_id);
  result->Success();
}
}  // namespace flutter_webrtc_plugin
