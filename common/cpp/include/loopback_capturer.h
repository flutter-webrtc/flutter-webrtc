#ifndef LOOPBACK_CAPTURER_H_
#define LOOPBACK_CAPTURER_H_

#include "rtc_audio_source.h"
#include "rtc_types.h"

namespace flutter_webrtc_plugin {

using namespace libwebrtc;

// Platform-independent interface for loopback (system) audio capture.
//
// Concrete implementations:
//   windows/application_loopback_capturer.h  — Windows WASAPI
//   linux/  (future)                         — PulseAudio / PipeWire
class LoopbackCapturer {
 public:
  virtual ~LoopbackCapturer() = default;

  // Start capturing system audio and pushing PCM frames into |source|.
  // Returns false if the platform capture path could not be initialised.
  virtual bool Start(scoped_refptr<RTCAudioSource> source) = 0;

  // Stop capturing and clean up platform resources.
  virtual void Stop() = 0;
};

}  // namespace flutter_webrtc_plugin

#endif  // LOOPBACK_CAPTURER_H_
