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
  // Reads frame_ without the lock; call only after RemoveRenderer().
  bool SaveFrame();

  RTCVideoTrack* track_;
  std::string path_;
  std::mutex mutex_;
  std::condition_variable frame_ready_;
  // Guarded by mutex_ until RemoveRenderer() returns.
  scoped_refptr<RTCVideoFrame> frame_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_FRAME_CAPTURER_HXX
