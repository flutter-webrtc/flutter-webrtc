#include "loopback_capturer.h"

// Linux factory for LoopbackCapturer.
//
// When the plugin build found libpulse (HAVE_LIBPULSE, set in CMakeLists.txt)
// this returns the PulseAudio monitor-capture implementation so that
// getDisplayMedia({audio: true}) streams system audio. When libpulse is
// absent the build still succeeds and this returns nullptr, matching the old
// stub behaviour (getDisplayMedia continues without an audio track).
//
// The declaration in loopback_capturer.h is non-inline for __linux__, so this
// translation unit must always define the symbol regardless of HAVE_LIBPULSE.

#if defined(__linux__) && defined(HAVE_LIBPULSE)
#include "pulse_loopback_capturer.h"
#endif

namespace flutter_webrtc_plugin {

#if defined(__linux__) && defined(HAVE_LIBPULSE)

std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& source_id) {
  return std::unique_ptr<LoopbackCapturer>(
      new PulseLoopbackCapturer(source_id));
}

#else  // libpulse not available: preserve the old nullptr behaviour.

std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& /*source_id*/) {
  return nullptr;
}

#endif

}  // namespace flutter_webrtc_plugin
