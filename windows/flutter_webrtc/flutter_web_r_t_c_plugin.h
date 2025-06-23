#ifndef PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_
#define PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

namespace flutter_webrtc_plugin {
class FlutterWebRTC;
}  // namespace flutter_webrtc_plugin

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void FlutterWebRTCPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

FLUTTER_PLUGIN_EXPORT flutter_webrtc_plugin::FlutterWebRTC* FlutterWebRTCPluginSharedInstance();

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_
