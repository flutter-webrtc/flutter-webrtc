#ifndef FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX
#define FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_video_frame.h"
#include "rtc_video_renderer.h"

#include <mutex>

namespace flutter_webrtc_plugin {

using namespace libwebrtc;

class FlutterFrameCapturer
    : public RTCVideoRenderer<scoped_refptr<RTCVideoFrame>> {
 public:
  FlutterFrameCapturer(RTCVideoTrack* track, std::string path);

  virtual void OnFrame(scoped_refptr<RTCVideoFrame> frame) override;

  void CaptureFrame(std::unique_ptr<MethodResultProxy> result);

 private:
  RTCVideoTrack* track_;
  std::string path_;
  std::mutex mutex_;
  scoped_refptr<RTCVideoFrame> frame_;
  volatile bool catch_frame_;

  bool SaveFrame();
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX