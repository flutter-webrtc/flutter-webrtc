#include <Windows.h>
#include <sstream>
#include <string>

#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include "flutter-webrtc-native/include/api.h"
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "media_stream.h"
#include "parsing.h"
#include "peer_connection.h"

namespace flutter_webrtc_plugin {

// `OnDeviceChangeCallback` implementation forwarding the event to the Dart
// side via `EventSink`.
class DeviceChangeHandler : public OnDeviceChangeCallback {
 public:
  DeviceChangeHandler(flutter::BinaryMessenger* binary_messenger) {
    event_channel_.reset(new EventChannel<EncodableValue>(
        binary_messenger, "FlutterWebRTC/OnDeviceChange",
        &StandardMethodCodec::GetInstance()));

    auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
        // `on_listen` callback.
        [&](const flutter::EncodableValue* arguments,
            std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                events)
            -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
          event_sink_ = std::move(events);
          return nullptr;
        },
        // `on_cancel` callback.
        [&](const flutter::EncodableValue* arguments)
            -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
          event_sink_ = nullptr;
          return nullptr;
        });

    event_channel_->SetStreamHandler(std::move(handler));
  }

  // `OnDeviceChangeCallback` implementation.
  void OnDeviceChange() { event_sink_->Success(); }

 private:
  // Named channel for communicating with the Flutter application using
  // asynchronous event streams.
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;

  // Event callback. Events to be sent to Flutter application act as clients of
  // this interface for sending events.
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
};

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin)
    : FlutterVideoRendererManager::FlutterVideoRendererManager(
          plugin->textures(),
          plugin->messenger()) {
  messenger_ = plugin->messenger();
  webrtc->SetOnDeviceChanged(
      std::make_unique<DeviceChangeHandler>(plugin->messenger()));
}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("createPeerConnection") == 0) {
    CreateRTCPeerConnection(webrtc, messenger_, method_call, std::move(result));
  } else if (method.compare("getSources") == 0) {
    EnumerateDevice(webrtc, std::move(result));
  } else if (method.compare("getUserMedia") == 0) {
    GetMedia(webrtc, method_call, std::move(result), false);
  } else if (method.compare("getDisplayMedia") == 0) {
    GetMedia(webrtc, method_call, std::move(result), true);
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
  } else if (method.compare("addIceCandidate") == 0) {
    AddIceCandidate(webrtc, method_call, std::move(result));
  } else if (method.compare("getStats") == 0) {
  } else if (method.compare("createDataChannel") == 0) {
  } else if (method.compare("dataChannelSend") == 0) {
  } else if (method.compare("dataChannelClose") == 0) {
  } else if (method.compare("streamDispose") == 0) {
    DisposeStream(webrtc, method_call, std::move(result));
  } else if (method.compare("mediaStreamTrackSetEnable") == 0) {
    SetTrackEnabled(webrtc, method_call, std::move(result));
  } else if (method.compare("trackDispose") == 0) {
  } else if (method.compare("peerConnectionClose") == 0) {
  } else if (method.compare("peerConnectionDispose") == 0) {
    DisposePeerConnection(webrtc, method_call, std::move(result));
  } else if (method.compare("restartIce") == 0) {
    RestartIce(webrtc, method_call, std::move(result));
  } else if (method.compare("createVideoRenderer") == 0) {
    CreateVideoRendererTexture(std::move(result));
  } else if (method.compare("videoRendererDispose") == 0) {
    VideoRendererDispose(webrtc, method_call, std::move(result));
  } else if (method.compare("videoRendererSetSrcObject") == 0) {
    SetMediaStream(webrtc, method_call, std::move(result));
  } else if (method.compare("setVolume") == 0) {
  } else if (method.compare("getLocalDescription") == 0) {
  } else if (method.compare("getRemoteDescription") == 0) {
  } else if (method.compare("mediaStreamAddTrack") == 0) {
  } else if (method.compare("mediaStreamRemoveTrack") == 0) {
  } else if (method.compare("addTrack") == 0) {
  } else if (method.compare("removeTrack") == 0) {
  } else if (method.compare("addTransceiver") == 0) {
    AddTransceiver(webrtc, method_call, std::move(result));
  } else if (method.compare("getTransceivers") == 0) {
    GetTransceivers(webrtc, method_call, std::move(result));
  } else if (method.compare("getReceivers") == 0) {
  } else if (method.compare("rtpSenderDispose") == 0) {
  } else if (method.compare("rtpSenderReplaceTrack") == 0) {
    SenderReplaceTrack(webrtc, method_call, std::move(result));
  } else if (method.compare("rtpTransceiverStop") == 0) {
    StopTransceiver(webrtc, method_call, std::move(result));
  } else if (method.compare("rtpTransceiverDispose") == 0) {
    DisposeTransceiver(webrtc, method_call, std::move(result));
  } else if (method.compare("rtpTransceiverSetDirection") == 0) {
    SetTransceiverDirection(webrtc, method_call, std::move(result));
  } else if (method.compare("rtpTransceiverGetDirection") == 0) {
    GetTransceiverDirection(webrtc, method_call, std::move(result));
  } else if (method.compare("rtpTransceiverGetMid") == 0) {
    GetTransceiverMid(webrtc, method_call, std::move(result));
  } else if (method.compare("setConfiguration") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
