// Linux system-audio (loopback) capture for flutter_webrtc.
//
// Mirrors windows/application_loopback_capturer.cc but uses the PulseAudio
// simple API to record the default sink's monitor source. Compiled only when
// the plugin build found libpulse (HAVE_LIBPULSE, set in linux/CMakeLists.txt);
// otherwise this translation unit is empty and CreateLoopbackCapturer falls
// back to returning nullptr (getDisplayMedia continues without system audio),
// so a missing libpulse degrades gracefully instead of breaking the build.
//
// PipeWire ships a PulseAudio compatibility layer, so this covers both the
// PulseAudio and PipeWire stacks through the same libpulse API.

#if defined(__linux__) && defined(HAVE_LIBPULSE)

#include "pulse_loopback_capturer.h"

#include <pulse/error.h>
#include <pulse/introspect.h>
#include <pulse/mainloop.h>
#include <pulse/simple.h>

#include <chrono>
#include <cstdint>
#include <iostream>
#include <vector>

namespace flutter_webrtc_plugin {

namespace {

// Frame contract fed to RTCAudioSource::CaptureFrame, matching the value the
// Windows capturer feeds downstream: 16-bit PCM, 48 kHz, 2 channels, 480
// samples per channel = one 10 ms frame.
constexpr int    kBitsPerSample = 16;
constexpr int    kSampleRate    = 48000;
constexpr size_t kChannels      = 2;
constexpr size_t kFramesPer10ms = kSampleRate / 100;  // 480
// Bytes for one 10 ms stereo s16 frame: 480 * 2 * 2 = 1920.
constexpr size_t kFrameBytes = kFramesPer10ms * kChannels * sizeof(int16_t);

// ---------------------------------------------------------------------------
// Introspection helpers.
//
// The pulse simple API cannot query which sink is default, so a short-lived
// asynchronous context resolves it. Two callbacks fill in the results and set
// a "done" flag that the pa_mainloop_iterate loop polls.
// ---------------------------------------------------------------------------
struct MonitorProbe {
  pa_mainloop* mainloop = nullptr;
  pa_context*  context  = nullptr;
  std::string  default_sink_name;
  std::string  monitor_source_name;
  int          op_pending = 0;     // outstanding introspection ops
  bool         failed     = false;
};

void SinkInfoCallback(pa_context* /*c*/, const pa_sink_info* info, int eol,
                      void* userdata) {
  auto* p = static_cast<MonitorProbe*>(userdata);
  if (eol < 0) {
    p->failed = true;
    p->op_pending = 0;
    return;
  }
  if (eol > 0) {
    // End of list for this query.
    if (p->op_pending > 0) --p->op_pending;
    return;
  }
  if (info && info->monitor_source_name) {
    p->monitor_source_name = info->monitor_source_name;
  }
}

void ServerInfoCallback(pa_context* c, const pa_server_info* info,
                        void* userdata) {
  auto* p = static_cast<MonitorProbe*>(userdata);
  if (!info || !info->default_sink_name) {
    p->failed = true;
    if (p->op_pending > 0) --p->op_pending;
    return;
  }
  p->default_sink_name = info->default_sink_name;
  // Chain the sink-info query for the default sink to read its
  // monitor_source_name (the canonical monitor name, more robust than blindly
  // appending ".monitor"). Only count the op as pending if it actually issued;
  // if pa_context_get_sink_info_by_name returns null, SinkInfoCallback never
  // fires, and a phantom pending count would wedge the drain loop forever. We
  // already captured default_sink_name above, so the "<sink>.monitor" fallback
  // still yields a usable monitor name in that case.
  pa_operation* op = pa_context_get_sink_info_by_name(
      c, info->default_sink_name, SinkInfoCallback, p);
  if (op) {
    ++p->op_pending;
    pa_operation_unref(op);
  }
  // Retire the server-info op.
  if (p->op_pending > 0) --p->op_pending;
}

}  // namespace

// ---------------------------------------------------------------------------
// PulseLoopbackCapturer
// ---------------------------------------------------------------------------

PulseLoopbackCapturer::PulseLoopbackCapturer(const std::string& source_id)
    : source_id_(source_id) {}

PulseLoopbackCapturer::~PulseLoopbackCapturer() {
  Stop();
}

std::string PulseLoopbackCapturer::ResolveDefaultMonitorSource() {
  MonitorProbe probe;
  probe.mainloop = pa_mainloop_new();
  if (!probe.mainloop) return std::string();

  probe.context = pa_context_new(pa_mainloop_get_api(probe.mainloop),
                                 "flutter_webrtc_loopback_probe");
  if (!probe.context) {
    pa_mainloop_free(probe.mainloop);
    return std::string();
  }

  if (pa_context_connect(probe.context, nullptr, PA_CONTEXT_NOFLAGS, nullptr) <
      0) {
    pa_context_unref(probe.context);
    pa_mainloop_free(probe.mainloop);
    return std::string();
  }

  // Cap the whole introspection so a misbehaving pulse/pipewire daemon (a
  // callback that never arrives, a wedged socket) degrades to "no audio track"
  // instead of blocking the Flutter platform thread inside getDisplayMedia.
  // pa_mainloop_iterate(block=1) can park on the fd indefinitely, so we run it
  // non-blocking (block=0) and pace with a short 5 ms sleep, checking a
  // steady-clock deadline each pass instead of blocking on any single iterate.
  const auto deadline =
      std::chrono::steady_clock::now() + std::chrono::seconds(3);
  auto past_deadline = [&deadline]() {
    return std::chrono::steady_clock::now() >= deadline;
  };

  // Drive the mainloop until the context is ready or fails.
  bool connected = false;
  while (!connected && !probe.failed) {
    if (past_deadline()) {
      probe.failed = true;
      break;
    }
    // block=0 = non-blocking prepare/poll/dispatch; we drive the poll cadence
    // ourselves via a short sleep so the deadline stays responsive.
    if (pa_mainloop_iterate(probe.mainloop, /*block=*/0, nullptr) < 0) {
      probe.failed = true;
      break;
    }
    pa_context_state_t st = pa_context_get_state(probe.context);
    if (st == PA_CONTEXT_READY) {
      connected = true;
    } else if (st == PA_CONTEXT_FAILED || st == PA_CONTEXT_TERMINATED) {
      probe.failed = true;
    } else {
      std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }
  }

  if (connected && !probe.failed) {
    probe.op_pending = 1;  // the server-info op
    pa_operation* op = pa_context_get_server_info(probe.context,
                                                  ServerInfoCallback, &probe);
    if (!op) {
      probe.failed = true;
    } else {
      pa_operation_unref(op);
      // Iterate until all chained ops drain (op_pending reaches 0), failure, or
      // the deadline. The deadline is the backstop for a callback that never
      // fires despite op_pending never reaching zero.
      while (probe.op_pending > 0 && !probe.failed) {
        if (past_deadline()) {
          probe.failed = true;
          break;
        }
        if (pa_mainloop_iterate(probe.mainloop, /*block=*/0, nullptr) < 0) {
          probe.failed = true;
          break;
        }
        if (probe.op_pending > 0)
          std::this_thread::sleep_for(std::chrono::milliseconds(5));
      }
    }
  }

  pa_context_disconnect(probe.context);
  pa_context_unref(probe.context);
  pa_mainloop_free(probe.mainloop);

  if (probe.failed) return std::string();

  // Prefer the canonical monitor_source_name; fall back to "<sink>.monitor".
  if (!probe.monitor_source_name.empty()) return probe.monitor_source_name;
  if (!probe.default_sink_name.empty())
    return probe.default_sink_name + ".monitor";
  return std::string();
}

bool PulseLoopbackCapturer::Start(scoped_refptr<RTCAudioSource> source) {
  if (running_) return true;

  source_ = source;

  monitor_source_name_ = ResolveDefaultMonitorSource();
  if (monitor_source_name_.empty()) {
    std::cerr << "[LoopbackCapturer] Could not resolve default sink monitor "
                 "source; system-audio capture unavailable.\n";
    source_ = nullptr;
    return false;
  }

  const pa_sample_spec ss = {
      /*format=*/PA_SAMPLE_S16LE,
      /*rate=*/kSampleRate,
      /*channels=*/static_cast<uint8_t>(kChannels),
  };

  // Ask pulse for ~10 ms fragments so pa_simple_read returns one frame at a
  // time, giving a natural 100 Hz cadence. -1 leaves other attributes at the
  // server default.
  pa_buffer_attr attr;
  attr.maxlength = static_cast<uint32_t>(-1);
  attr.tlength   = static_cast<uint32_t>(-1);
  attr.prebuf    = static_cast<uint32_t>(-1);
  attr.minreq    = static_cast<uint32_t>(-1);
  attr.fragsize  = static_cast<uint32_t>(kFrameBytes);

  int error = 0;
  simple_ = pa_simple_new(
      /*server=*/nullptr,
      /*name=*/"flutter_webrtc",
      /*dir=*/PA_STREAM_RECORD,
      /*dev=*/monitor_source_name_.c_str(),  // capture the sink's monitor
      /*stream_name=*/"System audio loopback",
      &ss,
      /*map=*/nullptr,
      &attr,
      &error);

  if (!simple_) {
    std::cerr << "[LoopbackCapturer] pa_simple_new failed on '"
              << monitor_source_name_ << "': " << pa_strerror(error) << "\n";
    source_ = nullptr;
    return false;
  }

  running_ = true;
  capture_thread_ = std::thread(&PulseLoopbackCapturer::CaptureThread, this);
  // std::cout << "[LoopbackCapturer] Capturing monitor '"
  //           << monitor_source_name_ << "' (" << kSampleRate << " Hz, "
  //           << kChannels << " ch, s16le).\n";
  return true;
}

void PulseLoopbackCapturer::Stop() {
  if (!running_) return;
  running_ = false;

  // The capture thread may be blocked inside pa_simple_read. A default-sink
  // monitor delivers frames continuously (silence included) while any sink is
  // running, so the read returns within ~10 ms and the join completes
  // promptly. KNOWN CAVEAT: if the sink is fully suspended (no stream playing
  // and module-suspend-on-idle has parked it) the monitor may stop producing
  // data and pa_simple_read can block until playback resumes. The simple API
  // exposes no cancel; a PipeWire-native or async pa_stream backend would let
  // us unblock explicitly. Documented, not mitigated here.
  if (capture_thread_.joinable()) {
    capture_thread_.join();
  }

  if (simple_) {
    pa_simple_free(simple_);
    simple_ = nullptr;
  }
  source_ = nullptr;
  // std::cout << "[LoopbackCapturer] Capture stopped.\n";
}

// ---------------------------------------------------------------------------
// CaptureThread
// Blocking pa_simple_read paces the loop: each read returns exactly one 10 ms
// stereo s16 frame at real time, which is fed straight to CaptureFrame with no
// intermediate ring buffer (unlike the Windows path). No sample-format
// conversion is needed because pulse resamples/converts to the requested
// S16LE / 48 kHz / stereo spec server-side.
// ---------------------------------------------------------------------------
void PulseLoopbackCapturer::CaptureThread() {
  std::vector<int16_t> buf(kFramesPer10ms * kChannels, int16_t{0});

  while (running_) {
    int error = 0;
    if (pa_simple_read(simple_, buf.data(), kFrameBytes, &error) < 0) {
      // Device gone / server disconnect / read error: stop gracefully.
      std::cerr << "[LoopbackCapturer] pa_simple_read error: "
                << pa_strerror(error) << " -- stopping capture.\n";
      break;
    }
    if (!running_) break;

    if (source_) {
      source_->CaptureFrame(buf.data(), kBitsPerSample, kSampleRate, kChannels,
                            kFramesPer10ms);
    }
  }
}

}  // namespace flutter_webrtc_plugin

#endif  // __linux__ && HAVE_LIBPULSE
