#ifdef _WIN32

#include "application_loopback_capturer.h"

namespace flutter_webrtc_plugin {

// ---------------------------------------------------------------------------
// CreateLoopbackCapturer — Windows factory implementation
// Creates an ApplicationLoopbackCapturer and, if source_id refers to a window
// (identified by its HWND as a decimal string), sets the target PID so that
// only that application's audio is captured.  Falls back to all-system audio
// when source_id is "0" or the HWND can no longer be resolved.
// ---------------------------------------------------------------------------
std::unique_ptr<LoopbackCapturer> CreateLoopbackCapturer(
    const std::string& source_id) {
  auto* cap = new ApplicationLoopbackCapturer();
  if (source_id != "0") {
    try {
      HWND hwnd = reinterpret_cast<HWND>(
          static_cast<uintptr_t>(std::stoull(source_id)));
      if (hwnd && IsWindow(hwnd)) {
        DWORD pid = 0;
        GetWindowThreadProcessId(hwnd, &pid);
        if (pid != 0) {
          cap->SetTargetProcessId(pid);
        }
      }
    } catch (...) {
      // Non-numeric ID or stale HWND — fall back to all-system audio.
    }
  }
  return std::unique_ptr<LoopbackCapturer>(cap);
}

}  // namespace flutter_webrtc_plugin

#endif  // _WIN32
