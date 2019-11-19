#ifndef PLUGINS_FLUTTER_WEBRTC_PLUGIN_WINDOWS_H_
#define PLUGINS_FLUTTER_WEBRTC_PLUGIN_WINDOWS_H_

#include <flutter_plugin_registrar.h>

#if defined(_WINDOWS)
#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif
#else
#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void FlutterWebRTCPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // PLUGINS_FLUTTER_WEBRTC_PLUGIN_WINDOWS_H_
