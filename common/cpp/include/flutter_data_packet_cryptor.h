#ifndef FLUTTER_WEBRTC_RTC_DATA_PACKET_CRYPTOR_HXX
#define FLUTTER_WEBRTC_RTC_DATA_PACKET_CRYPTOR_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_data_packet_cryptor.h"

namespace flutter_webrtc_plugin {

class FlutterDataPacketCryptor {
 public:
  FlutterDataPacketCryptor(FlutterWebRTCBase* base) : base_(base) {}

  bool HandleDataPacketCryptorMethodCall(
      const MethodCallProxy& method_call,
      std::unique_ptr<MethodResultProxy> result,
      std::unique_ptr<MethodResultProxy> *outResult);

  void CreateDataPacketCryptor(const EncodableMap& constraints,
                               std::unique_ptr<MethodResultProxy> result);

  void DataPacketCryptorDispose(const EncodableMap& constraints,
                                std::unique_ptr<MethodResultProxy> result);

  void DataPacketCryptorEncrypt(const EncodableMap& constraints,
                                std::unique_ptr<MethodResultProxy> result);

  void DataPacketCryptorDecrypt(const EncodableMap& constraints,
                                std::unique_ptr<MethodResultProxy> result);

 private:
  FlutterWebRTCBase* base_;
  std::map<std::string, scoped_refptr<libwebrtc::RTCDataPacketCryptor>>
      data_packet_cryptors_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_WEBRTC_RTC_DATA_PACKET_CRYPTOR_HXX
