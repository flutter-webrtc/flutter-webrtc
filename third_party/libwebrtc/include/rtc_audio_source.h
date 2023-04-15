#ifndef LIB_WEBRTC_RTC_AUDIO_SOURCE_HXX
#define LIB_WEBRTC_RTC_AUDIO_SOURCE_HXX

#include "rtc_types.h"

namespace libwebrtc {

/**
 * The RTCAudioSource class is a base class for audio sources in WebRTC.
 * Audio sources represent the source of audio data in WebRTC, such as a
 * microphone or a file. This class provides a base interface for audio
 * sources to implement, allowing them to be used with WebRTC's audio
 * processing and transmission mechanisms.
 */
class RTCAudioSource : public RefCountInterface {
 protected:
  /**
   * The destructor for the RTCAudioSource class.
   */
  virtual ~RTCAudioSource() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
