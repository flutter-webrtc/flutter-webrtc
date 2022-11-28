#ifndef PLUGINS_FLUTTER_WEBRTC_HXX
#define PLUGINS_FLUTTER_WEBRTC_HXX

#include "flutter_common.h"

#include "flutter_data_channel.h"
#include "flutter_media_stream.h"
#include "flutter_peerconnection.h"
#include "flutter_screen_capture.h"
#include "flutter_video_renderer.h"

#include "libwebrtc.h"

namespace flutter_webrtc_plugin {

using namespace libwebrtc;

class FlutterWebRTCPlugin : public flutter::Plugin {
 public:
  virtual BinaryMessenger* messenger() = 0;

  virtual TextureRegistrar* textures() = 0;
};

class FlutterWebRTC : public FlutterWebRTCBase,
                      public FlutterVideoRendererManager,
                      public FlutterMediaStream,
                      public FlutterPeerConnection,
                      public FlutterScreenCapture,
                      public FlutterDataChannel {
 public:
  FlutterWebRTC(FlutterWebRTCPlugin* plugin);
  virtual ~FlutterWebRTC();

  void HandleMethodCall(const MethodCallProxy& method_call,
                        std::unique_ptr<MethodResultProxy> result);
};

}  // namespace flutter_webrtc_plugin

#endif  // PLUGINS_FLUTTER_WEBRTC_HXX
