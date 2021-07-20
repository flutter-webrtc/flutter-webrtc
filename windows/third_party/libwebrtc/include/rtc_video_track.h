#ifndef LIB_WEBRTC_RTC_VIDEO_TRACK_HXX
#define LIB_WEBRTC_RTC_VIDEO_TRACK_HXX

#include "rtc_types.h"

#include "rtc_media_track.h"
#include "rtc_video_frame.h"
#include "rtc_video_renderer.h"

namespace libwebrtc {

class RTCVideoTrack : public RTCMediaTrack {
 public:
  virtual void AddRenderer(
      RTCVideoRenderer<scoped_refptr<RTCVideoFrame>>* renderer) = 0;

  virtual void RemoveRenderer(
      RTCVideoRenderer<scoped_refptr<RTCVideoFrame>>* renderer) = 0;

 protected:
  ~RTCVideoTrack() {}
};


class RTCVideoTracks : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<RTCVideoTracks> Create();
  virtual void Add(scoped_refptr<RTCVideoTrack> value) = 0;
  virtual scoped_refptr<RTCVideoTrack> Get(int index) = 0;
  virtual int Size() = 0;
  virtual void Remove(int index) = 0;
  virtual void Clean() = 0;
};
}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_VIDEO_TRACK_HXX
