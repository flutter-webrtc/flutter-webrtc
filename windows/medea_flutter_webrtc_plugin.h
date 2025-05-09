#ifndef FLUTTER_PLUGIN_MEDEA_FLUTTER_WEBRTC_PLUGIN_H_
#define FLUTTER_PLUGIN_MEDEA_FLUTTER_WEBRTC_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

#include "video_renderer.h"

namespace medea_flutter_webrtc {

class MedeaFlutterWebrtcPlugin : public flutter::Plugin,
                               public FlutterVideoRendererManager {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  MedeaFlutterWebrtcPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~MedeaFlutterWebrtcPlugin();

  // Disallow copy and assign.
  MedeaFlutterWebrtcPlugin(const MedeaFlutterWebrtcPlugin&) = delete;
  MedeaFlutterWebrtcPlugin& operator=(const MedeaFlutterWebrtcPlugin&) = delete;

  // `BinaryMessenger` is used to open `EventChannel`s to the Dart side.
  flutter::BinaryMessenger* messenger_;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace medea_flutter_webrtc

#endif  // FLUTTER_PLUGIN_MEDEA_FLUTTER_WEBRTC_PLUGIN_H_
