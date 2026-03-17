#include "flutter_data_packet_cryptor.h"

#include "base/scoped_ref_ptr.h"

namespace flutter_webrtc_plugin {

bool FlutterDataPacketCryptor::HandleDataPacketCryptorMethodCall(
    const MethodCallProxy& method_call,
    std::unique_ptr<MethodResultProxy> result,
    std::unique_ptr<MethodResultProxy>* outResult) {
  const std::string& method_name = method_call.method_name();
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null arguments received");
    return true;
  }
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  if (method_name == "createDataPacketCryptor") {
    CreateDataPacketCryptor(params, std::move(result));
    return true;
  } else if (method_name == "dataPacketCryptorDispose") {
    DataPacketCryptorDispose(params, std::move(result));
    return true;
  } else if (method_name == "dataPacketCryptorEncrypt") {
    DataPacketCryptorEncrypt(params, std::move(result));
    return true;
  } else if (method_name == "dataPacketCryptorDecrypt") {
    DataPacketCryptorDecrypt(params, std::move(result));
    return true;
  }
  *outResult = std::move(result);
  return false;
}

libwebrtc::FrameCryptorAlgorithm KeyDerivationAlgorithmFromInt(int algorithm) {
  switch (algorithm) {
    case 0:
      return libwebrtc::FrameCryptorAlgorithm::kAesGcm;
    case 1:
      return libwebrtc::FrameCryptorAlgorithm::kAesCbc;
    default:
      return libwebrtc::FrameCryptorAlgorithm::kAesGcm;
  }
}

void FlutterDataPacketCryptor::CreateDataPacketCryptor(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  std::string keyProviderId = findString(constraints, "keyProviderId");
  if (keyProviderId.empty()) {
    result->Error("createDataPacketCryptor",
                  "createDataPacketCryptor() keyProviderId is null or empty");
    return;
  }
  int algorithm = findInt(constraints, "algorithm");

  if (algorithm < 0) {
    result->Error("createDataPacketCryptor",
                  "createDataPacketCryptor() algorithm is invalid");
    return;
  }

  auto keyProvider = base_->key_providers_[keyProviderId];
  if (keyProvider == nullptr) {
    result->Error("createDataPacketCryptor",
                  "createDataPacketCryptor() keyProvider is null");
    return;
  }
  std::string uuid = base_->GenerateUUID();
  data_packet_cryptors_[uuid] = libwebrtc::RTCDataPacketCryptor::Create(
      keyProvider, KeyDerivationAlgorithmFromInt(algorithm));
  EncodableMap params;
  params[EncodableValue("dataCryptorId")] = uuid;
  result->Success(EncodableValue(params));
}
void FlutterDataPacketCryptor::DataPacketCryptorDispose(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  std::string dataCryptorId = findString(constraints, "dataCryptorId");
  if (dataCryptorId.empty()) {
    result->Error("dataPacketCryptorDispose",
                  "dataPacketCryptorDispose() dataCryptorId is null or empty");
    return;
  }
  auto dataCryptor = data_packet_cryptors_[dataCryptorId];
  if (dataCryptor == nullptr) {
    result->Error("dataPacketCryptorDispose",
                  "dataPacketCryptorDispose() dataCryptor is null");
    return;
  }
  data_packet_cryptors_.erase(dataCryptorId);

  result->Success();
}

void FlutterDataPacketCryptor::DataPacketCryptorEncrypt(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  std::string dataCryptorId = findString(constraints, "dataCryptorId");
  if (dataCryptorId.empty()) {
    result->Error("dataPacketCryptorEncrypt",
                  "dataPacketCryptorEncrypt() dataCryptorId is null or empty");
    return;
  }

  auto dataCryptor = data_packet_cryptors_[dataCryptorId];
  if (dataCryptor == nullptr) {
    result->Error("dataPacketCryptorEncrypt",
                  "dataPacketCryptorEncrypt() dataCryptor is null");
    return;
  }

  std::string participantId = findString(constraints, "participantId");
  if (participantId.empty()) {
    result->Error("dataPacketCryptorEncrypt",
                  "dataPacketCryptorEncrypt() participantId is null or empty");
    return;
  }
  int keyIndex = findInt(constraints, "keyIndex");
  if (keyIndex == -1) {
    result->Error("dataPacketCryptorEncrypt",
                  "dataPacketCryptorEncrypt() keyIndex is null");
    return;
  }
  auto data = findVector(constraints, "data");
  if (data.size() == 0) {
    result->Error("dataPacketCryptorEncrypt",
                  "dataPacketCryptorEncrypt() data is null or empty");
    return;
  }
  auto encryptedPacket =
      dataCryptor->encrypt(participantId, keyIndex, vector<uint8_t>(data));

  if (encryptedPacket == nullptr) {
    result->Error("dataPacketCryptorEncrypt",
                  "dataPacketCryptorEncrypt() encryption failed");
    return;
  }

  EncodableMap params;
  params[EncodableValue("data")] =
      EncodableValue(encryptedPacket->data().std_vector());
  params[EncodableValue("iv")] =
      EncodableValue(encryptedPacket->iv().std_vector());
  params[EncodableValue("keyIndex")] =
      EncodableValue(encryptedPacket->key_index());
  result->Success(EncodableValue(params));
}

void FlutterDataPacketCryptor::DataPacketCryptorDecrypt(
    const EncodableMap& constraints,
    std::unique_ptr<MethodResultProxy> result) {
  std::string dataCryptorId = findString(constraints, "dataCryptorId");
  if (dataCryptorId.empty()) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() dataCryptorId is null or empty");
    return;
  }
  auto dataCryptor = data_packet_cryptors_[dataCryptorId];
  if (dataCryptor == nullptr) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() dataCryptor is null");
    return;
  }
  std::string participantId = findString(constraints, "participantId");
  if (participantId.empty()) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() participantId is null or empty");
    return;
  }
  int keyIndex = findInt(constraints, "keyIndex");
  if (keyIndex == -1) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() keyIndex is null");
    return;
  }
  auto encryptedData = findVector(constraints, "data");
  if (encryptedData.size() == 0) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() encrypted data is null or empty");
    return;
  }
  auto iv = findVector(constraints, "iv");
  if (iv.size() == 0) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() iv is null or empty");
    return;
  }
  auto decryptedData =
      dataCryptor->decrypt(participantId, keyIndex,
                           libwebrtc::EncryptedPacket::Create(
                               vector<uint8_t>(encryptedData),
                               vector<uint8_t>(iv), (uint8_t)keyIndex));
  if (encryptedData.size() != 0 && decryptedData.size() == 0) {
    result->Error("dataPacketCryptorDecrypt",
                  "dataPacketCryptorDecrypt() decryption failed");
    return;
  }

  EncodableMap params;
  params[EncodableValue("data")] = EncodableValue(decryptedData.std_vector());
  result->Success(EncodableValue(params));
}

}  // namespace flutter_webrtc_plugin