#include "include/medea_flutter_webrtc/medea_flutter_webrtc_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "medea_flutter_webrtc_plugin.h"

void MedeaFlutterWebrtcPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  medea_flutter_webrtc::MedeaFlutterWebrtcPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
