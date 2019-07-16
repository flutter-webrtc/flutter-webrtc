#ifndef FLUTTER_WEBRTC_RTC_GET_USERMEDIA_HXX
#define FLUTTER_WEBRTC_RTC_GET_USERMEDIA_HXX

#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

class FlutterMediaStream {
 public:
  FlutterMediaStream(FlutterWebRTCBase *base) : base_(base) {}

  void GetUserMedia(const EncodableMap &constraints,
                    std::unique_ptr<MethodResult<EncodableValue>> result);

  void GetUserAudio(const EncodableMap &constraints,
                    scoped_refptr<RTCMediaStream> stream, EncodableMap &params);

  void GetUserVideo(const EncodableMap &constraints,
                    scoped_refptr<RTCMediaStream> stream, EncodableMap &params);

  void GetSources(std::unique_ptr<MethodResult<EncodableValue>> result);

  void MediaStreamGetTracks(
      const std::string &stream_id,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void MediaStreamDispose(const std::string &stream_id,
                          std::unique_ptr<MethodResult<EncodableValue>> result);

  void MediaStreamTrackSetEnable(
      const std::string &track_id,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void MediaStreamTrackSwitchCamera(
      const std::string &track_id,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void MediaStreamTrackDispose(
      const std::string &track_id,
      std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase *base_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_GET_USERMEDIA_HXX
