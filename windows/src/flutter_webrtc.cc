#include <Windows.h>
#include <sstream>
#include <string>

#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin)
    : FlutterVideoRendererManager::FlutterVideoRendererManager(
          plugin->textures(),
          plugin->messenger()) {
  messenger_ = plugin->messenger();
}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
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

}  // namespace flutter_webrtc_plugin
