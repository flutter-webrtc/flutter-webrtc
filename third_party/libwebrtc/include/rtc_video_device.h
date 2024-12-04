#ifndef LIB_WEBRTC_RTC_VIDEO_DEVICE_HXX
#define LIB_WEBRTC_RTC_VIDEO_DEVICE_HXX

#include "rtc_types.h"

namespace libwebrtc {

class RTCVideoCapturer : public RefCountInterface {
 public:
  virtual ~RTCVideoCapturer() {}

  virtual bool StartCapture() = 0;

  virtual bool CaptureStarted() = 0;

  virtual void StopCapture() = 0;
};

class RTCVideoDevice : public RefCountInterface {
 public:
  virtual uint32_t NumberOfDevices() = 0;

  virtual int32_t GetDeviceName(uint32_t deviceNumber, char* deviceNameUTF8,
                                uint32_t deviceNameLength,
                                char* deviceUniqueIdUTF8,
                                uint32_t deviceUniqueIdUTF8Length,
                                char* productUniqueIdUTF8 = 0,
                                uint32_t productUniqueIdUTF8Length = 0) = 0;

  virtual scoped_refptr<RTCVideoCapturer> Create(const char* name,
                                                 uint32_t index, size_t width,
                                                 size_t height,
                                                 size_t target_fps) = 0;

 protected:
  virtual ~RTCVideoDevice() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_VIDEO_DEVICE_HXX
