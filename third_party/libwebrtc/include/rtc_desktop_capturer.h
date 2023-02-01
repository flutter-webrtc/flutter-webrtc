#ifndef LIB_WEBRTC_RTC_DESKTOP_CAPTURER_HXX
#define LIB_WEBRTC_RTC_DESKTOP_CAPTURER_HXX

#include "rtc_desktop_media_list.h"
#include "rtc_types.h"
#include "rtc_video_device.h"

namespace libwebrtc {

class DesktopCapturerObserver;

class RTCDesktopCapturer : public RefCountInterface {
 public:
  enum CaptureState { CS_RUNNING, CS_STOPPED, CS_FAILED };

 public:
  virtual void RegisterDesktopCapturerObserver(
      DesktopCapturerObserver* observer) = 0;

  virtual void DeRegisterDesktopCapturerObserver() = 0;

  virtual CaptureState Start(uint32_t fps) = 0;
  virtual CaptureState Start(uint32_t fps,
                             uint32_t x,
                             uint32_t y,
                             uint32_t w,
                             uint32_t h) = 0;
  virtual void Stop() = 0;

  virtual bool IsRunning() = 0;

  virtual scoped_refptr<MediaSource> source() = 0;

  virtual ~RTCDesktopCapturer() {}
};

class DesktopCapturerObserver {
 public:
  virtual void OnStart(scoped_refptr<RTCDesktopCapturer> capturer) = 0;
  virtual void OnPaused(scoped_refptr<RTCDesktopCapturer> capturer) = 0;
  virtual void OnStop(scoped_refptr<RTCDesktopCapturer> capturer) = 0;
  virtual void OnError(scoped_refptr<RTCDesktopCapturer> capturer) = 0;

 protected:
  ~DesktopCapturerObserver() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_DESKTOP_CAPTURER_HXX