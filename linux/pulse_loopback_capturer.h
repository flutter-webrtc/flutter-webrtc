#ifndef PULSE_LOOPBACK_CAPTURER_H_
#define PULSE_LOOPBACK_CAPTURER_H_

#ifdef __linux__

#include <atomic>
#include <string>
#include <thread>

#include "loopback_capturer.h"

// Forward-declare the libpulse simple handle so this header does not require
// the pulse dev headers to be present just to include it. The .cc pulls in
// <pulse/simple.h> behind the HAVE_LIBPULSE guard.
struct pa_simple;

namespace flutter_webrtc_plugin {

// Linux PulseAudio / PipeWire (pulse compat) implementation of
// LoopbackCapturer.
//
// Captures the default sink's MONITOR source so that "system audio" (whatever
// is currently playing out of the default output) is streamed into the WebRTC
// RTCAudioSource, mirroring the Windows WASAPI ApplicationLoopbackCapturer.
//
// Design note vs. Windows:
//   The Windows capturer needs a ring buffer + a separate feeder thread + drift
//   compensation because WASAPI loopback delivers irregularly batched packets
//   and reports the render engine's native mix format (float32 / int24 / etc).
//   On PulseAudio we request the exact target format (S16LE, 48 kHz, stereo)
//   from the server and let pa_simple_read block-and-pace the capture: each
//   read returns exactly one 10 ms frame (480 stereo samples) at real time, so
//   the blocking read IS the clock. That removes the need for the ring buffer,
//   the feeder thread, and the drift logic. One capture thread suffices.
//
//   A PipeWire-native backend (libpipewire pw_stream on the monitor node) is a
//   possible future alternative; libpulse is chosen here for portability
//   because PipeWire ships a PulseAudio compatibility layer and pure-PulseAudio
//   systems are still common. `parec --device=<sink>.monitor` proved the path
//   works in the spike.
class PulseLoopbackCapturer : public LoopbackCapturer {
 public:
  explicit PulseLoopbackCapturer(const std::string& source_id);
  ~PulseLoopbackCapturer() override;

  bool Start(scoped_refptr<RTCAudioSource> source) override;
  void Stop() override;

 private:
  // Capture thread: pa_simple_read loop feeding CaptureFrame.
  void CaptureThread();

  // Resolves the default sink's monitor source name via a short-lived
  // introspection context (pa_mainloop + pa_context). Returns the empty
  // string on failure. The simple API alone cannot query server defaults, so
  // this runs first, then the capture stream is opened on the resolved name.
  std::string ResolveDefaultMonitorSource();

  // Desktop source ID passed from getDisplayMedia. On Windows this selects a
  // per-window PID; on Linux there is no equivalent per-window system-audio
  // isolation via the pulse monitor, so it is retained only for interface
  // parity and currently unused (whole default-sink monitor is captured).
  std::string source_id_;

  scoped_refptr<RTCAudioSource> source_;
  std::atomic<bool> running_{false};
  std::thread capture_thread_;

  // libpulse simple record handle bound to the monitor source.
  pa_simple* simple_ = nullptr;

  // Resolved monitor source name (e.g. "alsa_output....monitor").
  std::string monitor_source_name_;
};

}  // namespace flutter_webrtc_plugin

#endif  // __linux__
#endif  // PULSE_LOOPBACK_CAPTURER_H_
