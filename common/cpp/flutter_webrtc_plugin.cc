#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

#include "flutter_common.h"
#include "flutter_webrtc.h"

const char* kChannelName = "FlutterWebRTC.Method";

//#if defined(_WINDOWS)

namespace flutter_webrtc_plugin {

// A webrtc plugin for windows/linux.
class FlutterWebRTCPluginImpl : public FlutterWebRTCPlugin {
 public:
  static void RegisterWithRegistrar(PluginRegistrar* registrar) {
    auto channel = std::make_unique<MethodChannel>(
        registrar->messenger(), kChannelName,
        &flutter::StandardMethodCodec::GetInstance());

    auto* channel_pointer = channel.get();

    // Uses new instead of make_unique due to private constructor.
    std::unique_ptr<FlutterWebRTCPluginImpl> plugin(
        new FlutterWebRTCPluginImpl(registrar, std::move(channel)));

    channel_pointer->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto& call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  virtual ~FlutterWebRTCPluginImpl() {}

  BinaryMessenger* messenger() { return messenger_; }

  TextureRegistrar* textures() { return textures_; }

 private:
  // Creates a plugin that communicates on the given channel.
  FlutterWebRTCPluginImpl(PluginRegistrar* registrar,
                          std::unique_ptr<MethodChannel> channel)
      : channel_(std::move(channel)),
        messenger_(registrar->messenger()),
        textures_(registrar->texture_registrar()) {
    webrtc_ = std::make_unique<FlutterWebRTC>(this);
  }

  // Called when a method is called on |channel_|;
  void HandleMethodCall(const MethodCall& method_call,
                        std::unique_ptr<MethodResult> result) {
    // handle method call and forward to webrtc native sdk.
    auto method_call_proxy = MethodCallProxy::Create(method_call);
    webrtc_->HandleMethodCall(*method_call_proxy.get(), MethodResultProxy::Create(std::move(result)));
  }

 private:
  std::unique_ptr<MethodChannel> channel_;
  std::unique_ptr<FlutterWebRTC> webrtc_;
  BinaryMessenger* messenger_;
  TextureRegistrar* textures_;
};

}  // namespace flutter_webrtc_plugin

void flutter_web_r_t_c_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  static auto *plugin_registrar = new flutter::PluginRegistrar(registrar);
  flutter_webrtc_plugin::FlutterWebRTCPluginImpl::RegisterWithRegistrar(plugin_registrar);
}

/*
#else

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

namespace flutter_webrtc_plugin {

// A webrtc plugin for windows/linux.
class FlutterWebRTCPluginImpl : public FlutterWebRTCPlugin {
 public:
   static void FlutterWebRTCMethodCallCB(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
     FlutterWebRTCPluginImpl* impl = static_cast<FlutterWebRTCPluginImpl *>(user_data);
     impl->HandleMethodCall(method_call);
   }

  static void FlutterWebRTCPluginImplDestroyNotify(gpointer data) {
    FlutterWebRTCPluginImpl* impl = static_cast<FlutterWebRTCPluginImpl *>(data);
    delete impl;
  }

  static void RegisterWithRegistrar(FlPluginRegistrar *registrar) {
    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    FlMethodChannel *channel = fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                                      kChannelName,
                                                      FL_METHOD_CODEC(codec));

    FlutterWebRTCPluginImpl* impl = new FlutterWebRTCPluginImpl(registrar, channel);
    fl_method_channel_set_method_call_handler(channel,
                                              FlutterWebRTCMethodCallCB,
                                              impl, FlutterWebRTCPluginImplDestroyNotify);
  }

  virtual ~FlutterWebRTCPluginImpl() {
    g_object_unref(channel_);
  }

  void HandleMethodCall(FlMethodCall *method_call) {
    // handle method call and forward to webrtc native sdk.
     auto method_call_proxy = MethodCallProxy::Create(*method_call);
    webrtc_->HandleMethodCall(*method_call_proxy.get(), nullptr);
  }

  FlBinaryMessenger *messenger() { return messenger_; }
  FlTextureRegistrar *textures() { return textures_; }

  static void TextureRegistrarWeakNotifyCB(gpointer user_data, GObject* where_the_object_was) {
    FlutterWebRTCPluginImpl *thiz = reinterpret_cast<FlutterWebRTCPluginImpl *>(user_data);
    thiz->textures_ = nullptr;
  }

 protected:
  // Creates a plugin that communicates on the given channel.
  FlutterWebRTCPluginImpl(FlPluginRegistrar *registrar, FlMethodChannel *channel)
      : channel_(channel),
        messenger_(fl_plugin_registrar_get_messenger(registrar)),
        textures_(fl_plugin_registrar_get_texture_registrar(registrar)) {

    g_object_weak_ref(G_OBJECT(textures_), TextureRegistrarWeakNotifyCB, this);
    webrtc_ = std::make_unique<FlutterWebRTC>(this);
  }

 private:
  FlMethodChannel *channel_;
  std::unique_ptr<FlutterWebRTC> webrtc_;
  // TODO: review life-cycle
  FlBinaryMessenger *messenger_;
  FlTextureRegistrar *textures_;
};

}  // namespace flutter_webrtc_plugin

void flutter_web_r_t_c_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  flutter_webrtc_plugin::FlutterWebRTCPluginImpl::RegisterWithRegistrar(registrar);
}

#endif
*/
