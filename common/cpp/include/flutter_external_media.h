#ifndef FLUTTER_WEBRTC_EXTERNAL_MEDIA_HXX
#define FLUTTER_WEBRTC_EXTERNAL_MEDIA_HXX
#include "flutter_webrtc_base.h"
namespace flutter_webrtc_plugin {
// Platform-thread-only sources fed by the caller; never owns capture devices.
class FlutterExternalMedia {
 public:
  explicit FlutterExternalMedia(FlutterWebRTCBase* base);
  ~FlutterExternalMedia();
  void ExternalMediaMethod(const MethodCallProxy& call,
                           std::unique_ptr<MethodResultProxy> result);
 private:
  struct State;
  std::unique_ptr<State> state_;
};
}  // namespace flutter_webrtc_plugin
#endif
