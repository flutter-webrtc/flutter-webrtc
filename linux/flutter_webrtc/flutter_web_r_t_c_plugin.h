#ifndef PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_
#define PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_

#include <flutter_linux/flutter_linux.h>
G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

namespace flutter_webrtc_plugin {
class FlutterWebRTC;
}  // namespace flutter_webrtc_plugin

typedef struct _FlutterWebrtcPlugin FlutterWebrtcPlugin;
typedef struct {
  GObjectClass parent_class;
} FlutterWebrtcPluginClass;

FLUTTER_PLUGIN_EXPORT GType flutter_webrtc_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void flutter_web_r_t_c_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT flutter_webrtc_plugin::FlutterWebRTC* flutter_webrtc_plugin_get_shared_instance();

G_END_DECLS

#endif  // PLUGINS_FLUTTER_WEBRTC_PLUGIN_CPP_H_
