#ifndef LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
#define LIB_WEBRTC_RTC_AUDIO_TRACK_HXX

#include "rtc_types.h"
#include "rtc_media_track.h"

namespace libwebrtc {

class RTCAudioTrack : public RTCMediaTrack {
 protected:
  virtual ~RTCAudioTrack() {}
};

};  // namespace libwebrtc

#endif //LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
