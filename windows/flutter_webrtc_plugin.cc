#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

#include <flutter/standard_message_codec.h>

#include "flutter_webrtc.h"

const char *kChannelName = "FlutterWebRTC.Method";

namespace flutter_webrtc_plugin {

// A webrtc plugin for windows/linux.
class FlutterWebRTCPluginImpl : public FlutterWebRTCPlugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrar *registrar) {
    auto channel = std::make_unique<flutter::MethodChannel<EncodableValue>>(
        registrar->messenger(), kChannelName,
        &flutter::StandardMethodCodec::GetInstance());

    auto *channel_pointer = channel.get();

    // Uses new instead of make_unique due to private constructor.
    std::unique_ptr<FlutterWebRTCPluginImpl> plugin(
        new FlutterWebRTCPluginImpl(registrar, std::move(channel)));

    channel_pointer->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  virtual ~FlutterWebRTCPluginImpl() {}

  flutter::BinaryMessenger *messenger() { return messenger_; }

  flutter::TextureRegistrar *textures() { return textures_; }

 private:
  // Creates a plugin that communicates on the given channel.
  FlutterWebRTCPluginImpl(
      flutter::PluginRegistrar *registrar,
      std::unique_ptr<flutter::MethodChannel<EncodableValue>> channel)
      : channel_(std::move(channel)),
        messenger_(registrar->messenger()),
        textures_(registrar->texture_registrar()) {
    webrtc_ = std::make_unique<FlutterWebRTC>(this);
  }

  // Called when a method is called on |channel_|;
  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
    // handle method call and forward to webrtc native sdk.
    webrtc_->HandleMethodCall(method_call, std::move(result));
  }

 private:
  std::unique_ptr<flutter::MethodChannel<EncodableValue>> channel_;
  std::unique_ptr<FlutterWebRTC> webrtc_;
  flutter::BinaryMessenger *messenger_;
  flutter::TextureRegistrar *textures_;
};

}  // namespace flutter_webrtc_plugin

void FlutterWebRTCPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  static auto *plugin_registrar = new flutter::PluginRegistrar(registrar);
  flutter_webrtc_plugin::FlutterWebRTCPluginImpl::RegisterWithRegistrar(
      plugin_registrar);
}
