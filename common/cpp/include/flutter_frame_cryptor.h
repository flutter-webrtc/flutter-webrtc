#ifndef FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX
#define FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_frame_cryptor.h"

namespace flutter_webrtc_plugin {

class FlutterFrameCryptorObserver : public libwebrtc::RTCFrameCryptorObserver {
 public:
  FlutterFrameCryptorObserver(BinaryMessenger* messenger, TaskRunner* task_runner, const std::string& channelName)
      : event_channel_(EventChannelProxy::Create(messenger, task_runner, channelName)) {}
  void OnFrameCryptionStateChanged(
      const string participant_id,
      libwebrtc::RTCFrameCryptionState state);
 private:
  std::unique_ptr<EventChannelProxy> event_channel_;
};

class FlutterFrameCryptor {
 public:
  FlutterFrameCryptor(FlutterWebRTCBase* base) : base_(base) {}

  // Since this takes ownership of result, ownership will be passed back to 'outResult' if this function fails
  bool HandleFrameCryptorMethodCall(
    const MethodCallProxy& method_call,
    std::unique_ptr<MethodResultProxy> result,
    std::unique_ptr<MethodResultProxy> *outResult);

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

  void FrameCryptorFactoryCreateKeyProvider(
      const EncodableMap& constraints,
      std::unique_ptr<MethodResultProxy> result);

  void KeyProviderSetSharedKey(const EncodableMap& constraints,
                        std::unique_ptr<MethodResultProxy> result);

  void KeyProviderRatchetSharedKey(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  void KeyProviderExportSharedKey(const EncodableMap& constraints,
                        std::unique_ptr<MethodResultProxy> result);

  void KeyProviderSetKey(const EncodableMap& constraints,
                        std::unique_ptr<MethodResultProxy> result);

  void KeyProviderRatchetKey(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  void KeyProviderExportKey(const EncodableMap& constraints,
                        std::unique_ptr<MethodResultProxy> result);

  void KeyProviderSetSifTrailer(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  void KeyProviderDispose(const EncodableMap& constraints,
                         std::unique_ptr<MethodResultProxy> result);

  // std::unique_ptr<MethodResultProxy> result);
  //   'keyProviderSetKey',
  //   'keyProviderSetKeys',
  //   'keyProviderGetKeys',
  //   'keyProviderDispose',
  //   'frameCryptorFactoryCreateFrameCryptor',
  //   'frameCryptorFactoryCreateKeyProvider',
  //   'frameCryptorSetKeyIndex',
  //   'frameCryptorGetKeyIndex',
  //   'frameCryptorSetEnabled',
  //   'frameCryptorGetEnabled',
  //   'frameCryptorDispose',

 private:
  FlutterWebRTCBase* base_;
  std::map<std::string, scoped_refptr<libwebrtc::RTCFrameCryptor>>
      frame_cryptors_;
  std::map<std::string, scoped_refptr<FlutterFrameCryptorObserver>>
      frame_cryptor_observers_;
  std::map<std::string, scoped_refptr<libwebrtc::KeyProvider>> key_providers_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_WEBRTC_RTC_FRAME_CRYPTOR_HXX
