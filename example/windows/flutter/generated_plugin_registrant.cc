//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <videosdk_webrtc/flutter_web_r_t_c_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  FlutterWebRTCPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebRTCPlugin"));
}
