#ifndef PLUGINS_FLUTTER_WEBRTC_HXX
#define PLUGINS_FLUTTER_WEBRTC_HXX

#include "flutter_common.h"

#include "flutter_data_channel.h"
#include "flutter_frame_cryptor.h"
#include "flutter_media_stream.h"
#include "flutter_peerconnection.h"
#include "flutter_screen_capture.h"
#include "flutter_video_renderer.h"

#include "libwebrtc.h"
#include "rtc_logging.h"

namespace flutter_webrtc_plugin {

using namespace libwebrtc;

class FlutterWebRTCPlugin : public flutter::Plugin {
 public:
  virtual BinaryMessenger* messenger() = 0;

  virtual TextureRegistrar* textures() = 0;

  virtual TaskRunner* task_runner() = 0;
};

class FlutterWebRTC : public FlutterWebRTCBase,
                      public FlutterVideoRendererManager,
                      public FlutterMediaStream,
                      public FlutterPeerConnection,
                      public FlutterScreenCapture,
                      public FlutterDataChannel,
                      public FlutterFrameCryptor {
 public:
  FlutterWebRTC(FlutterWebRTCPlugin* plugin);
  virtual ~FlutterWebRTC();

  void HandleMethodCall(const MethodCallProxy& method_call,
                        std::unique_ptr<MethodResultProxy> result);

 private:
  void initLoggerCallback(RTCLoggingSeverity severity);
  RTCLoggingSeverity str2LogSeverity(std::string str);
};

}  // namespace flutter_webrtc_plugin

#endif  // PLUGINS_FLUTTER_WEBRTC_HXX
