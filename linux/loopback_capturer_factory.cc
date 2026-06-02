#include "loopback_capturer.h"

namespace flutter_webrtc_plugin {

// Linux loopback capture is not yet implemented.
// Returns nullptr so that GetDisplayMedia continues without audio.
std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& /*source_id*/) {
  return nullptr;
}

}  // namespace flutter_webrtc_plugin
