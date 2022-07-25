#include "medea_flutter_webrtc_plugin.h"

// This must be included before any other Windows headers.
#include <windows.h>

// For `getPlatformVersion` remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

const char* kChannelName = "FlutterWebRtc/VideoRendererFactory/0";

namespace medea_flutter_webrtc {

void MedeaFlutterWebrtcPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<MedeaFlutterWebrtcPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

MedeaFlutterWebrtcPlugin::MedeaFlutterWebrtcPlugin(
    flutter::PluginRegistrarWindows* registrar)
    : FlutterVideoRendererManager::FlutterVideoRendererManager(
          registrar->texture_registrar(),
          registrar->messenger()) {
  messenger_ = registrar->messenger();
}

MedeaFlutterWebrtcPlugin::~MedeaFlutterWebrtcPlugin() {}

void MedeaFlutterWebrtcPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method.compare("create") == 0) {
    CreateVideoRendererTexture(std::move(result));
  } else if (method.compare("dispose") == 0) {
    VideoRendererDispose(method_call, std::move(result));
  } else if (method.compare("createFrameHandler") == 0) {
    CreateFrameHandler(method_call, std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace medea_flutter_webrtc
