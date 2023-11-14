#ifndef BRIDGE_MOUSE_CURSOR_MONITOR_MAC_H_
#define BRIDGE_MOUSE_CURSOR_MONITOR_MAC_H_

#if __APPLE__

#include "modules/desktop_capture/mouse_cursor_monitor.h"

namespace bridge {

// Captures mouse shape and position.
// Wraps `webrtc::MouseCursorMonitor` wrapping `Capture` calls with @autorelease
// block to prevent memory leaking.
class MouseCursorMonitorMac : public webrtc::MouseCursorMonitor {
 public:
  // Creates a new `MouseCursorMonitorMac`.
  MouseCursorMonitorMac(
      std::unique_ptr<webrtc::MouseCursorMonitor> mouse_monitor);

  // Initializes the monitor with the `callback`, which must remain valid until
  // the capturer is destroyed.
  virtual void Init(Callback* callback, Mode mode) override;

  // Captures the current cursor shape and position
  void Capture() override;

 private:
  // Inner `MouseCursorMonitor` that this `MouseCursorMonitorMac` delegates
  // calls to.
  std::unique_ptr<webrtc::MouseCursorMonitor> mouse_monitor_;
};

}  // namespace bridge

#endif // __APPLE__

#endif // BRIDGE_MOUSE_CURSOR_MONITOR_MAC_H_
