#ifndef FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX
#define FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_frame_cryptor.h"

namespace flutter_webrtc_plugin {

class FlutterFrameCryptorObserver : public libwebrtc::RTCFrameCryptorObserver {
 public:
  FlutterFrameCryptorObserver(BinaryMessenger* messenger,const std::string& channelName)
      : event_channel_(EventChannelProxy::Create(messenger, channelName)) {}
  void OnFrameCryptionStateChanged(
      const string participant_id,
      libwebrtc::RTCFrameCryptionState state);
 private:
  std::unique_ptr<EventChannelProxy> event_channel_;
};

class FlutterFrameCryptor {
 public:
  FlutterFrameCryptor(FlutterWebRTCBase* base) : base_(base) {}

  bool HandleFrameCryptorMethodCall(
    const MethodCallProxy& method_call,
    std::unique_ptr<MethodResultProxy> result);

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

  void KeyManagerRatchetKey(const EncodableMap& constraints,
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
  std::map<std::string, std::unique_ptr<FlutterFrameCryptorObserver>>
      frame_cryptor_observers_;
  std::map<std::string, scoped_refptr<libwebrtc::KeyManager>> key_managers_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX
