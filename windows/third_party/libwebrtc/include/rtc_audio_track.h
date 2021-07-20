#ifndef LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
#define LIB_WEBRTC_RTC_AUDIO_TRACK_HXX

#include "rtc_media_track.h"
#include "rtc_types.h"

namespace libwebrtc {
class RTCAudioTrack : public RTCMediaTrack {
 protected:
  virtual ~RTCAudioTrack() {}
};

class RTCAudioTracks : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<RTCAudioTracks> Create();
  virtual void Add(scoped_refptr<RTCAudioTrack> value) = 0;
  virtual scoped_refptr<RTCAudioTrack> Get(int index) = 0;
  virtual int Size() = 0;
  virtual void Remove(int index) = 0;
  virtual void Clean() = 0;
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
