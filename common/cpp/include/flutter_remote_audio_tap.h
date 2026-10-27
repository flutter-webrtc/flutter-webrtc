#ifndef FLUTTER_WEBRTC_REMOTE_AUDIO_TAP_HXX
#define FLUTTER_WEBRTC_REMOTE_AUDIO_TAP_HXX

#include <map>
#include <memory>
#include <string>

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

class RemoteAudioTap;

// Experimental: delivers the decoded PCM of a remote audio track (before the
// playout mixer applies the track volume) to Dart, optionally with the native
// playout of that track silenced. See Documentation/remote-audio-tap.md.
class FlutterRemoteAudioTap {
 public:
  explicit FlutterRemoteAudioTap(FlutterWebRTCBase* base);
  ~FlutterRemoteAudioTap();

  void RemoteAudioTapMethod(const MethodCallProxy& method_call,
                            std::unique_ptr<MethodResultProxy> result);

 private:
  FlutterWebRTCBase* base_;
  std::map<std::string, std::unique_ptr<RemoteAudioTap>> taps_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_WEBRTC_REMOTE_AUDIO_TAP_HXX
