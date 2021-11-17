#include "flutter_webrtc.h"

#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include <flutter_webrtc_native.hpp>

namespace flutter_webrtc_plugin {

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin *plugin) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("getSystemTime") == 0) {
    int64_t millis = flutter_webrtc_native::SystemTimeMillis();

    result->Success(std::to_string(millis));
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
