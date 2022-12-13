#include "flutter_frame_cryptor.h"

#include "base/scoped_ref_ptr.h"

namespace flutter_webrtc_plugin {

void FlutterFrameCryptor::FrameCryptorFactoryCreateFrameCryptor(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto type = findString(constraints, "type");
  if (type == std::string()) {
    result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                  "type is null");
    return;
  }

  auto peerConnectionId = findString(constraints, "peerConnectionId");
  if (peerConnectionId == std::string()) {
    result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                  "peerConnectionId is null");
    return;
  }

  RTCPeerConnection* pc = base_->PeerConnectionForId(peerConnectionId);
  if (pc == nullptr) {
    result->Error(
        "FrameCryptorFactoryCreateFrameCryptorFailed",
        "FrameCryptorFactoryCreateFrameCryptor() peerConnection is null");
    return;
  }

  auto rtpSenderId = findString(constraints, "rtpSenderId");
  auto rtpReceiverId = findString(constraints, "rtpReceiverId");

  if (rtpReceiverId == std::string() && rtpSenderId == std::string()) {
    result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                  "rtpSenderId or rtpReceiverId is null");
    return;
  }

  //auto algorithm = findInt(constraints, "algorithm");

  auto keyManagerId = findString(constraints, "keyManagerId");

  if (type == "sender") {
    auto sender = base_->GetRtpSenderById(pc, rtpSenderId);
    if (nullptr == sender.get()) {
      result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                    "sender is null");
      return;
    }
    std::string uuid = base_->GenerateUUID();
    auto keyManager = key_managers_[keyManagerId];
    auto frameCryptor =
        libwebrtc::FrameCryptorFactory::frameCryptorFromRtpSender(
            sender, libwebrtc::Algorithm::kAesGcm, keyManager);

    frame_cryptors_[uuid] = frameCryptor;
    EncodableMap params;
    params[EncodableValue("frameCryptorId")] = uuid;

    result->Success(EncodableValue(params));
  } else if (type == "receiver") {
    auto receiver = base_->GetRtpReceiverById(pc, rtpReceiverId);
    if (nullptr == receiver.get()) {
      result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                    "receiver is null");
      return;
    }
    std::string uuid = base_->GenerateUUID();
    auto keyManager = key_managers_[keyManagerId];
    auto frameCryptor =
        libwebrtc::FrameCryptorFactory::frameCryptorFromRtpReceiver(
            receiver, libwebrtc::Algorithm::kAesGcm, keyManager);

    frame_cryptors_[uuid] = frameCryptor;
    EncodableMap params;
    params[EncodableValue("frameCryptorId")] = uuid;

    result->Success(EncodableValue(params));
  } else {
    result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                  "type is not sender or receiver");
  }
}

void FlutterFrameCryptor::FrameCryptorSetKeyIndex(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::FrameCryptorGetKeyIndex(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::FrameCryptorSetEnabled(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::FrameCryptorGetEnabled(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::FrameCryptorDispose(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::FrameCryptorFactoryCreateKeyManager(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::KeyManagerSetKey(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::KeyManagerSetKeys(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::KeyManagerGetKeys(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

void FlutterFrameCryptor::KeyManagerDispose(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  result->NotImplemented();
}

}  // namespace flutter_webrtc_plugin