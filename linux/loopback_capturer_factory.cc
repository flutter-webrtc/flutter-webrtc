#include "loopback_capturer.h"
#include "pipewire_loopback_capturer.h"

namespace flutter_webrtc_plugin {

// PipeWire availability is checked lazily inside Start().
// If the PipeWire daemon is not running, Start() returns false and
// GetDisplayMedia continues without an audio track (existing fallback path).
std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& /*source_id*/) {
  return std::make_unique<PipeWireLoopbackCapturer>();
}

}  // namespace flutter_webrtc_plugin
