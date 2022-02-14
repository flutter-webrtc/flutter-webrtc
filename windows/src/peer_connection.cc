#include <mutex>

#include "peer_connection.h"
#include "media_stream.h"
#include "flutter_webrtc.h"
#include "flutter-webrtc-native/include/api.h"
#include "flutter/standard_method_codec.h"
#include "parsing.h"

using namespace rust::cxxbridge1;

// `CreateSdpCallbackInterface` implementation forwarding completion result to
// the Flutter side via inner `flutter::MethodResult`.
class CreateSdpCallback : public CreateSdpCallbackInterface {
 public:
  // Creates a new `CreateSdpCallback`.
  CreateSdpCallback(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result_(std::move(res)) {}

  // Forwards the provided SDP to the `flutter::MethodResult` success.
  void OnSuccess(const std::string& sdp, const std::string& type_) {
    flutter::EncodableMap params;
    params[flutter::EncodableValue("sdp")] = sdp;
    params[flutter::EncodableValue("type")] = type_;
    result_->Success(flutter::EncodableValue(params));
  }

  // Forwards the provided `error` to the `flutter::MethodResult` error.
  void OnFail(const std::string& error) { result_->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result_;
};

// `SetDescriptionCallbackInterface` implementation forwarding completion result
// to the Flutter side via inner `flutter::MethodResult`.
class SetDescriptionCallBack : public SetDescriptionCallbackInterface {
 public:
  SetDescriptionCallBack(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result_(std::move(res)) {}

  // Successfully completes an inner `flutter::MethodResult`.
  void OnSuccess() { result_->Success(nullptr); }

  // Forwards the provided `error` to the `flutter::MethodResult` error.
  void OnFail(const std::string& error) { result_->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result_;
};

// `PeerConnectionObserverInterface` implementation forwarding events to the
// Flutter side via `flutter::EventSink`.
class PeerConnectionObserver : public PeerConnectionObserverInterface {
 public:
  // `PeerConnectionObserver` dependencies.
  struct Dependencies {
    // `EventSink` guard.
    std::unique_ptr<std::mutex> lock_ = std::make_unique<std::mutex>();
    // `EventSink` used to send events to the Flutter side.
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
    // Flutter `EventChannel` used to dispose the channel object.
    std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> chan_;
  };

  // Creates a new `PeerConnectionObserver`.
  PeerConnectionObserver(std::shared_ptr<Dependencies> deps)
      : deps_(std::move(deps)) {};

  ~PeerConnectionObserver() {
    if (deps_->chan_) {
      deps_->chan_->SetStreamHandler(nullptr);
    }
  }

  // Sends an `OnConnectionStateChange` event with the provided
  // `RTCPeerConnectionState` to the Dart side.
  //
  // See: https://w3.org/TR/webrtc#dom-rtcpeerconnectionstate
  void OnConnectionStateChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnConnectionStateChange";
      params[flutter::EncodableValue("state")] = new_state;
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  };

  // Sends an `OnIceCandidate` event with the provided `RTCIceCandidate` to the
  // Dart side.
  //
  // See: https://w3.org/TR/webrtc#dom-rtcicecandidate
  void OnIceCandidate(const std::string& candidate) {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceCandidate";
      params[EncodableValue("candidate")] = candidate;
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  }

  // Sends an `OnIceCandidateError` event with the provided
  // `RTCPeerConnectionIceErrorEvent` to the Dart side.
  //
  // See: https://w3.org/TR/webrtc#dom-rtcpeerconnectioniceerrorevent
  void OnIceCandidateError(const std::string& address,
                           int port,
                           const std::string& url,
                           int error_code,
                           const std::string& error_text) {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceCandidateError";
      params[flutter::EncodableValue("address")] = address;
      params[flutter::EncodableValue("errorCode")] = error_code;
      params[flutter::EncodableValue("errorText")] = error_text;
      params[flutter::EncodableValue("port")] = port;
      params[flutter::EncodableValue("url")] = url;

      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  };

  // Sends an `OnIceConnectionStateChange` event with the provided
  // `RTCIceConnectionState` to the Dart side.
  //
  // See: https://w3.org/TR/webrtc#dom-rtciceconnectionstate
  void OnIceConnectionStateChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceConnectionStateChange";
      params[flutter::EncodableValue("state")] = new_state;
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  };

  // Sends an `OnIceGatheringStateChange` event with the provided
  // `RTCIceGatheringState` to the Dart side.
  //
  // See: https://w3.org/TR/webrtc#dom-rtcicegatheringstate
  void OnIceGatheringStateChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceGatheringStateChange";
      params[flutter::EncodableValue("state")] = new_state;
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  };

  // Sends an `OnNegotiationNeededEvent` event to the Dart side.
  //
  // See: https://w3.org/TR/webrtc#event-negotiation
  void OnNegotiationNeeded() {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnNegotiationNeededEvent";
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  };

  // Sends an `OnSignalingChange` event with the provided `RTCSignalingState` to
  // the Dart side.
  //
  // See: https://w3.org/TR/webrtc#dom-rtcsignalingstate
  void OnSignalingChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*deps_->lock_);
    if (deps_->sink_) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnSignalingChange";
      params[flutter::EncodableValue("state")] = new_state;
      deps_->sink_->Success(flutter::EncodableValue(params));
    }
  }

 private:
  // `PeerConnectionObserver` dependencies.
  std::shared_ptr<Dependencies> deps_;
};

namespace flutter_webrtc_plugin {

using namespace flutter;

// Converts a Rust `RtcRtpTransceiver` into a Dart `EncodableMap`.
EncodableMap TransceiverToMap(RtcRtpTransceiver transceiver) {
  EncodableMap info;

  info[EncodableValue("transceiverId")] =
      EncodableValue(std::to_string(transceiver.id));
  info[EncodableValue("mid")] = EncodableValue(std::string(transceiver.mid));
  info[EncodableValue("direction")] =
      EncodableValue(std::string(transceiver.direction));
  info[EncodableValue("sender")] = EncodableValue(EncodableMap());
  info[EncodableValue("receiver")] = EncodableValue(EncodableMap());

  return info;
}

// Calls Rust `CreatePeerConnection()` and writes newly created peer ID to the
// provided `MethodResult`.
void CreateRTCPeerConnection(
    Box<Webrtc>& webrtc,
    flutter::BinaryMessenger* messenger,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  auto ctx = std::make_shared<PeerConnectionObserver::Dependencies>();
  auto observer = std::make_unique<PeerConnectionObserver>(ctx);

  rust::String error;
  uint64_t id = webrtc->CreatePeerConnection(std::move(observer), error);
  if (error == "") {
    std::string peer_id = std::to_string(id);
    auto event_channel = std::make_unique<EventChannel<EncodableValue>>(
        messenger, "FlutterWebRTC/peerConnectionEvent" + peer_id,
        &StandardMethodCodec::GetInstance());

    std::weak_ptr<PeerConnectionObserver::Dependencies> weak_deps(ctx);
    auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
        [=](const flutter::EncodableValue* arguments,
            std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
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

      EncodableMap params;
      params[EncodableValue("peerConnectionId")] = peer_id;
      result->Success(EncodableValue(params));
    } else {
     result->Error(std::string(error));
  }
}

// Calls Rust `CreateOffer()` and writes the returned session description to the
// provided `MethodResult`.
void CreateOffer(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");
  const EncodableMap constraints = findMap(params, "constraints");
  const EncodableMap mandatory = findMap(constraints, "mandatory");
  const EncodableList list = findList(constraints, "optional");

  bool voice_activity_detection = true;
  bool ice_restart = false;
  bool use_rtp_mux = true;

  auto iter = list.begin();
  if (iter != list.end()) {
    voice_activity_detection = GetValue<bool>((*iter));
    ++iter;
  }
  if (iter != list.end()) {
    ice_restart = GetValue<bool>((*iter));
    ++iter;
  }
  if (iter != list.end()) {
    use_rtp_mux = GetValue<bool>((*iter));
    ++iter;
  }

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<CreateSdpCallbackInterface>(
      new CreateSdpCallback(shared_result));

  rust::String error = webrtc->CreateOffer(std::stoi(peerConnectionId),
                                           voice_activity_detection,
                                           ice_restart,
                                           use_rtp_mux,
                                           std::move(callback));

  if (error != "") {
    shared_result->Error("createAnswerOffer", std::string(error));
  }
}

// Calls Rust `CreateAnswer()` and writes the returned session description to
// the provided `MethodResult`.
void CreateAnswer(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");
  const EncodableMap constraints = findMap(params, "constraints");
  const EncodableMap mandatory = findMap(constraints, "mandatory");
  const EncodableList list = findList(constraints, "optional");

  bool voice_activity_detection = true;
  bool ice_restart = false;
  bool use_rtp_mux = true;

  auto iter = list.begin();
  if (iter != list.end()) {
    voice_activity_detection = GetValue<bool>((*iter));
    ++iter;
  }
  if (iter != list.end()) {
    ice_restart = GetValue<bool>((*iter));
    ++iter;
  }
  if (iter != list.end()) {
    use_rtp_mux = GetValue<bool>((*iter));
    ++iter;
  }

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<CreateSdpCallbackInterface>(
      new CreateSdpCallback(shared_result));

  rust::String error = webrtc->CreateAnswer(std::stoi(peerConnectionId),
                                            voice_activity_detection,
                                            ice_restart,
                                            use_rtp_mux,
                                            std::move(callback));

  if (error != "") {
    shared_result->Error("createAnswerOffer", std::string(error));
  }
}

// Calls Rust `SetLocalDescription()`.
void SetLocalDescription(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");

  const EncodableMap constraints = findMap(params, "description");
  rust::String type = findString(constraints, "type");
  rust::String sdp = findString(constraints, "sdp");

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error = webrtc->SetLocalDescription(std::stoi(peerConnectionId),
                                                   type,
                                                   sdp,
                                                   std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
}

// Calls Rust `SetRemoteDescription()`.
void SetRemoteDescription(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");

  const EncodableMap constraints = findMap(params, "description");
  rust::String type = findString(constraints, "type");
  rust::String sdp = findString(constraints, "sdp");

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error = webrtc->SetRemoteDescription(std::stoi(peerConnectionId),
                                                    type,
                                                    sdp,
                                                    std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
}

// Calls Rust `AddTransceiver()`.
void AddTransceiver(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto transceiver = webrtc->AddTransceiver(
      std::stoi(findString(params, "peerConnectionId")),
      findString(params, "mediaType"),
      findString(findMap(params, "transceiverInit"), "direction"));

  result->Success(EncodableValue(TransceiverToMap(transceiver)));
}

// Calls Rust `GetTransceivers()`.
void GetTransceivers(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto transceivers = webrtc->GetTransceivers(
      std::stoi(findString(params, "peerConnectionId")));

  EncodableList infos;
  for (auto transceiver : transceivers) {
    infos.push_back(TransceiverToMap(transceiver));
  }

  EncodableMap map;
  map[EncodableValue("transceivers")] = EncodableValue(infos);

  result->Success(EncodableValue(map));
}

// Calls Rust `StopTransceivers()`.
void StopTransceiver(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  rust::String error = webrtc->StopTransceiver(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")));

  if (error.empty()) {
    result->Success();
  } else {
    result->Error("Failed to stop transceiver", std::string(error));
  }
}

// Calls Rust `DisposeTransceiver()`.
void DisposeTransceiver(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  webrtc->DisposeTransceiver(std::stoi(findString(params, "peerConnectionId")),
                             std::stoi(findString(params, "transceiverId")));

  result->Success();
}

// Calls Rust `SetTransceiverDirection()`.
void SetTransceiverDirection(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  rust::String error = webrtc->SetTransceiverDirection(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")),
      findString(params, "direction"));

  if (error.empty()) {
    result->Success();
  } else {
    result->Error("Failed to change transceiver direction", std::string(error));
  }
}

// Calls Rust `GetTransceiverDirection()`.
void GetTransceiverDirection(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto direction = (std::string) webrtc->GetTransceiverDirection(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")));

  EncodableMap map;
  map[EncodableValue("result")] = EncodableValue(direction);

  result->Success(map);
}

// Calls Rust `GetTransceiverMid()`.
void GetTransceiverMid(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto mid = (std::string) webrtc->GetTransceiverMid(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")));

  EncodableMap map;
  map[EncodableValue("mid")] = EncodableValue(mid);

  result->Success(map);
}

}  // namespace flutter_webrtc_plugin
