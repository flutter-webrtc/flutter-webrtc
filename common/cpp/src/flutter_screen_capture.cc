#include "flutter_screen_capture.h"

namespace flutter_webrtc_plugin {

void FlutterScreenCapture::EnumerateScreens(std::unique_ptr<MethodResult<EncodableValue>> result) {
  SourceList sources;

  sources = base_->desktop_device_->EnumerateScreens();
  
  EncodableList list;
  for (const auto& source : sources.std_vector()) {
    // std::cout << " id: " << source.id.std_string() << " title: " << source.title.std_string() << " type: " << source.type << std::endl;
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(source.id.std_string());
    info[EncodableValue("name")] = EncodableValue(source.title.std_string());
    info[EncodableValue("type")] = EncodableValue(source.type);
    list.push_back(EncodableValue(info));
  }

  result->Success(EncodableValue(list));
}

void FlutterScreenCapture::EnumerateWindows(std::unique_ptr<MethodResult<EncodableValue>> result) {
  SourceList sources;

  sources = base_->desktop_device_->EnumerateWindows();
  
  EncodableList list;
  for (const auto& source : sources.std_vector()) {
    // std::cout << " id: " << source.id.std_string() << " title: " << source.title.std_string() << " type: " << source.type << std::endl;
    EncodableMap info;
    info[EncodableValue("id")] = EncodableValue(source.id.std_string());
    info[EncodableValue("name")] = EncodableValue(source.title.std_string());
    info[EncodableValue("type")] = EncodableValue(source.type);
    list.push_back(EncodableValue(info));
  }

  result->Success(EncodableValue(list));
}

void FlutterScreenCapture::CreateCapture(libwebrtc::SourceType type, uint64_t id,
                                         const EncodableMap& constraints, 
                                         std::unique_ptr<MethodResult<EncodableValue>> result) {

  std::string uuid = base_->GenerateUUID();

  scoped_refptr<RTCMediaStream> stream = 
      base_->factory_->CreateStream(uuid.c_str());

  EncodableMap params;
  params[EncodableValue("streamId")] = EncodableValue(uuid);

  // AUDIO

  params[EncodableValue("audioTracks")] = EncodableValue(EncodableList());

  // VIDEO

  EncodableMap video_constraints;
  auto it = constraints.find(EncodableValue("video"));
  if (it != constraints.end() && TypeIs<EncodableMap>(it->second)) {
    video_constraints = GetValue<EncodableMap>(it->second);
  } 

  scoped_refptr<RTCDesktopCapturer> desktop_capturer;
  if (type == libwebrtc::SourceType::kEntireScreen) {
    desktop_capturer = base_->desktop_device_->CreateScreenCapturer(id);
  } else {
    desktop_capturer = base_->desktop_device_->CreateWindowCapturer(id);
  }

  if (!desktop_capturer.get()) return; // TODO: result->Error()

  const char* video_source_label = "screen_capture_input";

  scoped_refptr<RTCVideoSource> source = base_->factory_->CreateDesktopSource(
      desktop_capturer, video_source_label,
      base_->ParseMediaConstraints(video_constraints));

  // TODO: RTCVideoSource -> RTCVideoTrack
  
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

  base_->local_streams_[uuid] = stream;

  result->Success(EncodableValue(params));
}

}