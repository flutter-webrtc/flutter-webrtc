#if __APPLE__

#include "mouse_cursor_monitor_mac.h"

namespace bridge {

// Creates a new `MouseCursorMonitorMac`.
MouseCursorMonitorMac::MouseCursorMonitorMac(
    std::unique_ptr<webrtc::MouseCursorMonitor> mouse_monitor) {
  mouse_monitor_ = std::move(mouse_monitor);
}

// Initializes the monitor with the `callback`, which must remain valid until
// the capturer is destroyed.
void MouseCursorMonitorMac::Init(webrtc::MouseCursorMonitor::Callback* callback,
                                 webrtc::MouseCursorMonitor::Mode mode) {
  mouse_monitor_->Init(callback, mode);
}

// Captures current cursor shape and position.
void MouseCursorMonitorMac::Capture() {
  @autoreleasepool {
    mouse_monitor_->Capture();
  }
}

}  // namespace bridge

#endif
