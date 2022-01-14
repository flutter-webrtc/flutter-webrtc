#ifndef PLUGINS_FLUTTER_WEBRTC_HXX
#define PLUGINS_FLUTTER_WEBRTC_HXX

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <flutter_webrtc_native.h>

#include <string.h>
#include <list>
#include <map>
#include <memory>

using namespace flutter;
using namespace rust::cxxbridge1;

namespace flutter_webrtc_plugin {
class FlutterWebRTCPlugin : public flutter::Plugin {
 public:
  virtual flutter::BinaryMessenger *messenger() = 0;

  virtual flutter::TextureRegistrar *textures() = 0;
};

class FlutterWebRTC {
 public:
  FlutterWebRTC(FlutterWebRTCPlugin *plugin);
  virtual ~FlutterWebRTC();

  Box<Webrtc> webrtc = Init();

  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);
};

}  // namespace flutter_webrtc_plugin

#endif  // PLUGINS_FLUTTER_WEBRTC_HXX
