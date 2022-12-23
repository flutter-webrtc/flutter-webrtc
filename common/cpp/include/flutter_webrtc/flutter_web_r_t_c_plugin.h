#ifndef PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_
#define PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_

#if defined(_WINDOWS)

#include <flutter_plugin_registrar.h>
#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void FlutterWebRTCPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#else

#include <flutter_linux/flutter_linux.h>
G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _FlutterWebrtcPlugin FlutterWebrtcPlugin;
typedef struct {
  GObjectClass parent_class;
} FlutterWebrtcPluginClass;

FLUTTER_PLUGIN_EXPORT GType flutter_webrtc_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void flutter_web_r_t_c_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif

#endif  // PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_
