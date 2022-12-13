#ifndef FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX
#define FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_frame_cryptor.h"

namespace flutter_webrtc_plugin {

class FlutterFrameCryptor {
 public:
  FlutterFrameCryptor(FlutterWebRTCBase* base) : base_(base) {}

  void FrameCryptorFactoryCreateFrameCryptor(
      const EncodableMap& constraints,
      std::unique_ptr<MethodResultProxy> result);

  void FrameCryptorSetKeyIndex(const EncodableMap& constraints,
                               std::unique_ptr<MethodResultProxy> result);

  void FrameCryptorGetKeyIndex(const EncodableMap& constraints,
                               std::unique_ptr<MethodResultProxy> result);

  void FrameCryptorSetEnabled(const EncodableMap& constraints,
                              std::unique_ptr<MethodResultProxy> result);

  void FrameCryptorGetEnabled(const EncodableMap& constraints,
                              std::unique_ptr<MethodResultProxy> result);

  void FrameCryptorDispose(const EncodableMap& constraints,
                           std::unique_ptr<MethodResultProxy> result);

  void FrameCryptorFactoryCreateKeyManager(
      const EncodableMap& constraints,
      std::unique_ptr<MethodResultProxy> result);

  void KeyManagerSetKey(const EncodableMap& constraints,
                        std::unique_ptr<MethodResultProxy> result);

  void KeyManagerSetKeys(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  void KeyManagerGetKeys(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  void KeyManagerDispose(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  // std::unique_ptr<MethodResultProxy> result);
  //   'keyManagerSetKey',
  //   'keyManagerSetKeys',
  //   'keyManagerGetKeys',
  //   'keyManagerDispose',
  //   'frameCryptorFactoryCreateFrameCryptor',
  //   'frameCryptorFactoryCreateKeyManager',
  //   'frameCryptorSetKeyIndex',
  //   'frameCryptorGetKeyIndex',
  //   'frameCryptorSetEnabled',
  //   'frameCryptorGetEnabled',
  //   'frameCryptorDispose',

 private:
  FlutterWebRTCBase* base_;
  std::map<std::string, scoped_refptr<libwebrtc::RTCFrameCryptor>>
      frame_cryptors_;
  std::map<std::string, scoped_refptr<libwebrtc::KeyManager>> key_managers_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX
