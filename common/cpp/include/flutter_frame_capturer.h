#ifndef FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX
#define FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_video_frame.h"
#include "rtc_video_renderer.h"

#include <condition_variable>
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
  // Blocks until OnFrame() has stored a frame. Returns false on timeout.
  bool WaitForFrame();
  bool SaveFrame();

  RTCVideoTrack* track_;
  std::string path_;
  std::mutex mutex_;
  std::condition_variable frame_ready_;
  scoped_refptr<RTCVideoFrame> frame_;  // Guarded by mutex_.
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX
