#ifndef LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
#define LIB_WEBRTC_RTC_AUDIO_TRACK_HXX

#include "rtc_media_track.h"
#include "rtc_types.h"

namespace libwebrtc {

/**
 * The RTCAudioTrack class represents an audio track in WebRTC.
 * Audio tracks are used to transmit audio data over a WebRTC peer connection.
 * This class is a subclass of the RTCMediaTrack class, which provides a base
 * interface for all media tracks in WebRTC.
 */
class RTCAudioTrack : public RTCMediaTrack {
 public:
  // volume in [0-10]
  virtual void SetVolume(double volume) = 0;

 protected:
  /**
   * The destructor for the RTCAudioTrack class.
   */
  virtual ~RTCAudioTrack() {}
};
}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
