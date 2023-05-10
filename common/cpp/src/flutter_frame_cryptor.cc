#include "flutter_frame_cryptor.h"

#include "base/scoped_ref_ptr.h"

namespace flutter_webrtc_plugin {

libwebrtc::Algorithm AlgorithmFromInt(int algorithm) {
  switch (algorithm) {
    case 0:
      return libwebrtc::Algorithm::kAesGcm;
    case 1:
      return libwebrtc::Algorithm::kAesCbc;
    default:
      return libwebrtc::Algorithm::kAesGcm;
  }
}

std::string frameCryptionStateToString(libwebrtc::RTCFrameCryptionState state) {
  switch (state) {
    case RTCFrameCryptionState::kNew:
      return "new";
    case RTCFrameCryptionState::kOk:
      return "ok";
    case RTCFrameCryptionState::kDecryptionFailed:
      return "decryptionFailed";
    case RTCFrameCryptionState::kEncryptionFailed:
      return "encryptionFailed";
    case RTCFrameCryptionState::kInternalError:
      return "internalError";
    case RTCFrameCryptionState::kKeyRatcheted:
      return "keyRatcheted";
    case RTCFrameCryptionState::kMissingKey:
      return "missingKey";
  }
  return "";
}

void FlutterFrameCryptorObserver::OnFrameCryptionStateChanged(
    const string participant_id,
    libwebrtc::RTCFrameCryptionState state) {
  EncodableMap params;
  params[EncodableValue("event")] = EncodableValue("frameCryptionStateChanged");
  params[EncodableValue("participantId")] = EncodableValue(participant_id.std_string());
  params[EncodableValue("state")] =
      EncodableValue(frameCryptionStateToString(state));
  event_channel_->Success(EncodableValue(params));
}

bool FlutterFrameCryptor::HandleFrameCryptorMethodCall(
    const MethodCallProxy& method_call,
    std::unique_ptr<MethodResultProxy> result) {
  const std::string& method_name = method_call.method_name();
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null arguments received");
    return true;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  if (method_name == "frameCryptorFactoryCreateFrameCryptor") {
    FrameCryptorFactoryCreateFrameCryptor(params, std::move(result));
    return true;
  } else if (method_name == "frameCryptorSetKeyIndex") {
    FrameCryptorSetKeyIndex(params, std::move(result));
    return true;
  } else if (method_name == "frameCryptorGetKeyIndex") {
    FrameCryptorGetKeyIndex(params, std::move(result));
    return true;
  } else if (method_name == "frameCryptorSetEnabled") {
    FrameCryptorSetEnabled(params, std::move(result));
    return true;
  } else if (method_name == "frameCryptorGetEnabled") {
    FrameCryptorGetEnabled(params, std::move(result));
    return true;
  } else if (method_name == "frameCryptorDispose") {
    FrameCryptorDispose(params, std::move(result));
    return true;
  } else if (method_name == "frameCryptorFactoryCreateKeyProvider") {
    FrameCryptorFactoryCreateKeyProvider(params, std::move(result));
    return true;
  } else if (method_name == "keyProviderSetKey") {
    KeyProviderSetKey(params, std::move(result));
    return true;
  } else if (method_name == "keyProviderRatchetKey") {
    KeyProviderRatchetKey(params, std::move(result));
    return true;
  } else if (method_name == "keyProviderDispose") {
    KeyProviderDispose(params, std::move(result));
    return true;
  }

  return false;
}

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

  auto algorithm = findInt(constraints, "algorithm");
  auto participantId = findString(constraints, "participantId");
  auto keyProviderId = findString(constraints, "keyProviderId");

  if (type == "sender") {
    auto sender = base_->GetRtpSenderById(pc, rtpSenderId);
    if (nullptr == sender.get()) {
      result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                    "sender is null");
      return;
    }
    std::string uuid = base_->GenerateUUID();
    auto keyProvider = key_providers_[keyProviderId];
    if (keyProvider == nullptr) {
      result->Error("FrameCryptorFactoryCreateFrameCryptorFailed",
                    "keyProvider is null");
      return;
    }
    auto frameCryptor =
        libwebrtc::FrameCryptorFactory::frameCryptorFromRtpSender(
            string(participantId), sender, AlgorithmFromInt(algorithm),
            keyProvider);
    std::string event_channel = "FlutterWebRTC/frameCryptorEvent" + uuid;

    std::unique_ptr<FlutterFrameCryptorObserver> observer(
        new FlutterFrameCryptorObserver(base_->messenger_, event_channel));

    frameCryptor->RegisterRTCFrameCryptorObserver(observer.get());

    frame_cryptors_[uuid] = frameCryptor;
    frame_cryptor_observers_[uuid] = std::move(observer);
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
    auto keyProvider = key_providers_[keyProviderId];
    auto frameCryptor =
        libwebrtc::FrameCryptorFactory::frameCryptorFromRtpReceiver(
            string(participantId), receiver, AlgorithmFromInt(algorithm),
            keyProvider);

    std::string event_channel = "FlutterWebRTC/frameCryptorEvent" + uuid;

    std::unique_ptr<FlutterFrameCryptorObserver> observer(
        new FlutterFrameCryptorObserver(base_->messenger_, event_channel));

    frameCryptor->RegisterRTCFrameCryptorObserver(observer.get());

    frame_cryptors_[uuid] = frameCryptor;
    frame_cryptor_observers_[uuid] = std::move(observer);
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
  auto frameCryptorId = findString(constraints, "frameCryptorId");
  if (frameCryptorId == std::string()) {
    result->Error("FrameCryptorGetKeyIndexFailed", "frameCryptorId is null");
    return;
  }
  auto frameCryptor = frame_cryptors_[frameCryptorId];
  if (nullptr == frameCryptor.get()) {
    result->Error("FrameCryptorGetKeyIndexFailed", "frameCryptor is null");
    return;
  }
  auto key_index = findInt(constraints, "keyIndex");
  auto res = frameCryptor->SetKeyIndex(key_index);
  EncodableMap params;
  params[EncodableValue("result")] = res;
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::FrameCryptorGetKeyIndex(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto frameCryptorId = findString(constraints, "frameCryptorId");
  if (frameCryptorId == std::string()) {
    result->Error("FrameCryptorGetKeyIndexFailed", "frameCryptorId is null");
    return;
  }
  auto frameCryptor = frame_cryptors_[frameCryptorId];
  if (nullptr == frameCryptor.get()) {
    result->Error("FrameCryptorGetKeyIndexFailed", "frameCryptor is null");
    return;
  }
  EncodableMap params;
  params[EncodableValue("keyIndex")] = frameCryptor->key_index();
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::FrameCryptorSetEnabled(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto frameCryptorId = findString(constraints, "frameCryptorId");
  if (frameCryptorId == std::string()) {
    result->Error("FrameCryptorSetEnabledFailed", "frameCryptorId is null");
    return;
  }
  auto frameCryptor = frame_cryptors_[frameCryptorId];
  if (nullptr == frameCryptor.get()) {
    result->Error("FrameCryptorSetEnabledFailed", "frameCryptor is null");
    return;
  }
  auto enabled = findBoolean(constraints, "enabled");
  frameCryptor->SetEnabled(enabled);
  EncodableMap params;
  params[EncodableValue("result")] = enabled;
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::FrameCryptorGetEnabled(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto frameCryptorId = findString(constraints, "frameCryptorId");
  if (frameCryptorId == std::string()) {
    result->Error("FrameCryptorGetEnabledFailed", "frameCryptorId is null");
    return;
  }
  auto frameCryptor = frame_cryptors_[frameCryptorId];
  if (nullptr == frameCryptor.get()) {
    result->Error("FrameCryptorGetEnabledFailed", "frameCryptor is null");
    return;
  }
  EncodableMap params;
  params[EncodableValue("enabled")] = frameCryptor->enabled();
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::FrameCryptorDispose(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto frameCryptorId = findString(constraints, "frameCryptorId");
  if (frameCryptorId == std::string()) {
    result->Error("FrameCryptorDisposeFailed", "frameCryptorId is null");
    return;
  }
  auto frameCryptor = frame_cryptors_[frameCryptorId];
  if (nullptr == frameCryptor.get()) {
    result->Error("FrameCryptorDisposeFailed", "frameCryptor is null");
    return;
  }
  frameCryptor->DeRegisterRTCFrameCryptorObserver();
  frame_cryptors_.erase(frameCryptorId);
  frame_cryptor_observers_.erase(frameCryptorId);
  EncodableMap params;
  params[EncodableValue("result")] = "success";
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::FrameCryptorFactoryCreateKeyProvider(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  libwebrtc::KeyProviderOptions options;
  

  auto keyProviderOptions = findMap(constraints, "keyProviderOptions");
  if (keyProviderOptions == EncodableMap()) {
    result->Error("FrameCryptorFactoryCreateKeyProviderFailed", "keyProviderOptions is null");
    return;
  }

  auto sharedKey = findBoolean(keyProviderOptions, "sharedKey");
  options.shared_key = sharedKey;


  auto uncryptedMagicBytes = findVector(keyProviderOptions, "uncryptedMagicBytes");
  if (uncryptedMagicBytes.size() != 0) {
    options.uncrypted_magic_bytes = uncryptedMagicBytes;
  }

  auto ratchetSalt = findVector(keyProviderOptions, "ratchetSalt");
  if (ratchetSalt.size() == 0) {
    result->Error("FrameCryptorFactoryCreateKeyProviderFailed",
                  "ratchetSalt is null");
    return;
  }

  options.ratchet_salt = ratchetSalt;

  auto ratchetWindowSize = findInt(keyProviderOptions, "ratchetWindowSize");
  if (ratchetWindowSize  == -1) {
    result->Error("FrameCryptorFactoryCreateKeyProviderFailed",
                  "ratchetSalt is null");
    return;
  }

  options.ratchet_window_size = ratchetWindowSize;

  auto keyProvider = libwebrtc::KeyProvider::Create(&options);
  if (nullptr == keyProvider.get()) {
    result->Error("FrameCryptorFactoryCreateKeyProviderFailed",
                  "createKeyProvider failed");
    return;
  }
  auto uuid = base_->GenerateUUID();
  key_providers_[uuid] = keyProvider;
  EncodableMap params;
  params[EncodableValue("keyProviderId")] = uuid;
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::KeyProviderSetKey(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto keyProviderId = findString(constraints, "keyProviderId");
  if (keyProviderId == std::string()) {
    result->Error("KeyProviderSetKeyFailed", "keyProviderId is null");
    return;
  }

  auto keyProvider = key_providers_[keyProviderId];
  if (nullptr == keyProvider.get()) {
    result->Error("KeyProviderSetKeyFailed", "keyProvider is null");
    return;
  }

  auto key = findVector(constraints, "key");
  if (key.size() == 0) {
    result->Error("KeyProviderSetKeyFailed", "key is null");
    return;
  }
  auto key_index = findInt(constraints, "keyIndex");
  if (key_index == -1) {
    result->Error("KeyProviderSetKeyFailed", "keyIndex is null");
    return;
  }

  auto participant_id = findString(constraints, "participantId");
  if (participant_id == std::string()) {
    result->Error("KeyProviderSetKeyFailed", "participantId is null");
    return;
  }

  keyProvider->SetKey(participant_id, key_index, vector<uint8_t>(key));
  EncodableMap params;
  params[EncodableValue("result")] = true;
  result->Success(EncodableValue(params));
}

void FlutterFrameCryptor::KeyProviderRatchetKey(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto keyProviderId = findString(constraints, "keyProviderId");
  if (keyProviderId == std::string()) {
    result->Error("KeyProviderSetKeysFailed", "keyProviderId is null");
    return;
  }

  auto keyProvider = key_providers_[keyProviderId];
  if (nullptr == keyProvider.get()) {
    result->Error("KeyProviderSetKeysFailed", "keyProvider is null");
    return;
  }

  auto participant_id = findString(constraints, "participantId");
  if (participant_id == std::string()) {
    result->Error("KeyProviderSetKeyFailed", "participantId is null");
    return;
  }

  auto key_index = findInt(constraints, "keyIndex");
  if (key_index == -1) {
    result->Error("KeyProviderSetKeyFailed", "keyIndex is null");
    return;
  }

  auto newMaterial = keyProvider->RatchetKey(participant_id, key_index);

  EncodableMap params;
  params[EncodableValue("result")] = EncodableValue(newMaterial.std_vector());
  result->Success(EncodableValue(params));
}


void FlutterFrameCryptor::KeyProviderDispose(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  auto keyProviderId = findString(constraints, "keyProviderId");
  if (keyProviderId == std::string()) {
    result->Error("KeyProviderDisposeFailed", "keyProviderId is null");
    return;
  }

  auto keyProvider = key_providers_[keyProviderId];
  if (nullptr == keyProvider.get()) {
    result->Error("KeyProviderDisposeFailed", "keyProvider is null");
    return;
  }
  key_providers_.erase(keyProviderId);
  EncodableMap params;
  params[EncodableValue("result")] = "success";
  result->Success(EncodableValue(params));
}

}  // namespace flutter_webrtc_plugin