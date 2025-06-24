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
 public:
  enum SourceType { kMicrophone, kCustom };

 public:
  virtual void CaptureFrame(const void* audio_data, int bits_per_sample,
                            int sample_rate, size_t number_of_channels,
                            size_t number_of_frames) = 0;

  virtual SourceType GetSourceType() const = 0;

 protected:
  /**
   * The destructor for the RTCAudioSource class.
   */
  virtual ~RTCAudioSource() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_AUDIO_TRACK_HXX
