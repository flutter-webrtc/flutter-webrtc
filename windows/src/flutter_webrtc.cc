#include <Windows.h>
#include <sstream>
#include <string>

#include "flutter_webrtc.h"
#include "media_stream.h"

#include <flutter_webrtc_native.h>
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "flutter_peer_connection.h"

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("createPeerConnection") == 0) {
    CreateRTCPeerConnection(webrtc, method_call, std::move(result));
  } else if (method.compare("getSources") == 0) {
    enumerate_device(webrtc, std::move(result));
  } else if (method.compare("getUserMedia") == 0) {
    get_user_media(method_call, webrtc, std::move(result));
  } else if (method.compare("getDisplayMedia") == 0) {
  } else if (method.compare("mediaStreamGetTracks") == 0) {
  } else if (method.compare("createOffer") == 0) {
    CreateOffer(webrtc, method_call, std::move(result));
  } else if (method.compare("createAnswer") == 0) {
    CreateAnswer(webrtc, method_call, std::move(result));
  } else if (method.compare("addStream") == 0) {
  } else if (method.compare("removeStream") == 0) {
  } else if (method.compare("setLocalDescription") == 0) {
    SetLocalDescription(webrtc, method_call, std::move(result));
  } else if (method.compare("setRemoteDescription") == 0) {
    SetRemoteDescription(webrtc, method_call, std::move(result));
  } else if (method.compare("addCandidate") == 0) {
  } else if (method.compare("getStats") == 0) {
  } else if (method.compare("createDataChannel") == 0) {
  } else if (method.compare("dataChannelSend") == 0) {
  } else if (method.compare("dataChannelClose") == 0) {
  } else if (method.compare("streamDispose") == 0) {
    dispose_stream(method_call, webrtc, std::move(result));
  } else if (method.compare("mediaStreamTrackSetEnable") == 0) {
  } else if (method.compare("trackDispose") == 0) {
  } else if (method.compare("peerConnectionClose") == 0) {
  } else if (method.compare("peerConnectionDispose") == 0) {
  } else if (method.compare("createVideoRenderer") == 0) {
  } else if (method.compare("videoRendererDispose") == 0) {
  } else if (method.compare("videoRendererSetSrcObject") == 0) {
  } else if (method.compare("setVolume") == 0) {
  } else if (method.compare("getLocalDescription") == 0) {
  } else if (method.compare("getRemoteDescription") == 0) {
  } else if (method.compare("mediaStreamAddTrack") == 0) {
  } else if (method.compare("mediaStreamRemoveTrack") == 0) {
  } else if (method.compare("addTrack") == 0) {
  } else if (method.compare("removeTrack") == 0) {
  } else if (method.compare("addTransceiver") == 0) {
  } else if (method.compare("getTransceivers") == 0) {
  } else if (method.compare("getReceivers") == 0) {
  } else if (method.compare("getSenders") == 0) {
  } else if (method.compare("rtpSenderDispose") == 0) {
  } else if (method.compare("rtpSenderSetTrack") == 0) {
  } else if (method.compare("rtpSenderReplaceTrack") == 0) {
  } else if (method.compare("rtpSenderSetParameters") == 0) {
  } else if (method.compare("rtpTransceiverStop") == 0) {
  } else if (method.compare("rtpTransceiverSetDirection") == 0) {
  } else if (method.compare("setConfiguration") == 0) {
  } else if (method.compare("captureFrame") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
