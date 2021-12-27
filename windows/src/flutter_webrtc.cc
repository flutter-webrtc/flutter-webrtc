#include <sstream>

#include "flutter_webrtc.h"

#include <flutter_webrtc_native.h>
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("createPeerConnection") == 0) {
  } else if (method_call.method_name().compare("getSources") == 0) {
    rust::Vec<MediaDeviceInfo> devices = EnumerateDevices();

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
          throw std::exception("Invalid MediaDeviceKind");
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
  } else if (method_call.method_name().compare("getUserMedia") == 0) {
  } else if (method_call.method_name().compare("getDisplayMedia") == 0) {
  } else if (method_call.method_name().compare("mediaStreamGetTracks") == 0) {
  } else if (method_call.method_name().compare("createOffer") == 0) {
  } else if (method_call.method_name().compare("createAnswer") == 0) {
  } else if (method_call.method_name().compare("addStream") == 0) {
  } else if (method_call.method_name().compare("removeStream") == 0) {
  } else if (method_call.method_name().compare("setLocalDescription") == 0) {
  } else if (method_call.method_name().compare("setRemoteDescription") == 0) {
  } else if (method_call.method_name().compare("addCandidate") == 0) {
  } else if (method_call.method_name().compare("getStats") == 0) {
  } else if (method_call.method_name().compare("createDataChannel") == 0) {
  } else if (method_call.method_name().compare("dataChannelSend") == 0) {
  } else if (method_call.method_name().compare("dataChannelClose") == 0) {
  } else if (method_call.method_name().compare("streamDispose") == 0) {
  } else if (method_call.method_name().compare("mediaStreamTrackSetEnable") ==
             0) {
  } else if (method_call.method_name().compare("trackDispose") == 0) {
  } else if (method_call.method_name().compare("peerConnectionClose") == 0) {
  } else if (method_call.method_name().compare("createVideoRenderer") == 0) {
  } else if (method_call.method_name().compare("videoRendererDispose") == 0) {
  } else if (method_call.method_name().compare("videoRendererSetSrcObject") ==
             0) {
  } else if (method_call.method_name().compare(
                 "mediaStreamTrackSwitchCamera") == 0) {
  } else if (method_call.method_name().compare("setVolume") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
