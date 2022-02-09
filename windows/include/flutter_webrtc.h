#pragma once

#include "flutter/encodable_value.h"
#include "flutter/method_call.h"
#include "flutter/texture_registrar.h"
#include "flutter_webrtc_native.h"
#include "video_renderer.h"

using namespace flutter;
using namespace rust::cxxbridge1;

namespace flutter_webrtc_plugin {

class FlutterWebRTCPlugin : public flutter::Plugin {
 public:
  virtual flutter::BinaryMessenger* messenger() = 0;

  virtual flutter::TextureRegistrar* textures() = 0;
};

class FlutterWebRTC : public FlutterVideoRendererManager {
 public:
  FlutterWebRTC(FlutterWebRTCPlugin* plugin);
  virtual ~FlutterWebRTC();

  Box<Webrtc> webrtc = Init();

  // `BinaryMessenger` is used to open `EventChannel`s to the Dart side.
  flutter::BinaryMessenger* messenger_;

  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);
};

}  // namespace flutter_webrtc_plugin
