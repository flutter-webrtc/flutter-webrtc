#ifndef LOOPBACK_CAPTURER_H_
#define LOOPBACK_CAPTURER_H_

#include <memory>
#include <string>

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

// ---------------------------------------------------------------------------
// Factory function: creates the platform-appropriate loopback capturer.
// source_id: the desktop source ID string (used on Windows to resolve the
//            owning process PID when a specific window source is selected).
// Returns nullptr if loopback capture is not supported on this platform.
//
// Implemented in:
//   windows/application_loopback_capturer.cc  — Windows WASAPI
//   linux/loopback_capturer_factory.cc        — Linux stub (returns nullptr)
// All other platforms: inline null implementation below.
// ---------------------------------------------------------------------------
namespace flutter_webrtc_plugin {
#if defined(_WIN32) || defined(__linux__)
std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& source_id);
#else
inline std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& /*source_id*/) {
  return nullptr;
}
#endif
}  // namespace flutter_webrtc_plugin

#endif  // LOOPBACK_CAPTURER_H_
