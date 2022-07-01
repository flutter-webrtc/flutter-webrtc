#ifndef LIB_WEBRTC_RTC_DESKTOP_DEVICE_HXX
#define LIB_WEBRTC_RTC_DESKTOP_DEVICE_HXX

#include "rtc_types.h"
#include "rtc_video_device.h"


namespace libwebrtc {

class RTCDesktopCapturer : public RefCountInterface {
 public:
  virtual ~RTCDesktopCapturer() {}
};

class RTCDesktopDevice : public RefCountInterface {
 public:
  virtual scoped_refptr<RTCDesktopCapturer> CreateScreenCapturer(uint64_t screen_id) = 0;
  virtual scoped_refptr<RTCDesktopCapturer> CreateWindowCapturer(uint64_t window_id) = 0;

  virtual bool GetScreenList(SourceList& sources) = 0;
  virtual bool GetWindowList(SourceList& sources) = 0;
  virtual SourceList EnumerateWindows() = 0;
  virtual SourceList EnumerateScreens() = 0;

 protected:
  virtual ~RTCDesktopDevice() {}
};

} // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_VIDEO_DEVICE_HXX