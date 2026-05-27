#ifdef __linux__

#include "pipewire_loopback_capturer.h"

#include <chrono>
#include <cstring>
#include <iostream>
#include <cmath>

#include <spa/param/audio/format-utils.h>
#include <spa/pod/builder.h>
#include <spa/utils/result.h>

namespace flutter_webrtc_plugin {

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Convert a float sample [-1, 1] to int16.
static inline int16_t FloatToInt16(float v) {
  if (v >  1.0f) v =  1.0f;
  if (v < -1.0f) v = -1.0f;
  return static_cast<int16_t>(v * 32767.0f);
}

// ---------------------------------------------------------------------------
// Constructor / Destructor
// ---------------------------------------------------------------------------

PipeWireLoopbackCapturer::PipeWireLoopbackCapturer() = default;

PipeWireLoopbackCapturer::~PipeWireLoopbackCapturer() {
  Stop();
}

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------

bool PipeWireLoopbackCapturer::Start(scoped_refptr<RTCAudioSource> source) {
  if (running_) return true;

  source_ = source;

  pw_init(nullptr, nullptr);

  thread_loop_ = pw_thread_loop_new("flutter-webrtc-loopback", nullptr);
  if (!thread_loop_) {
    std::cerr << "[PW Loopback] pw_thread_loop_new failed.\n";
    source_ = nullptr;
    return false;
  }

  pw_context* ctx =
      pw_context_new(pw_thread_loop_get_loop(thread_loop_), nullptr, 0);
  if (!ctx) {
    std::cerr << "[PW Loopback] pw_context_new failed.\n";
    pw_thread_loop_destroy(thread_loop_);
    thread_loop_ = nullptr;
    source_ = nullptr;
    return false;
  }

  pw_core* core = pw_context_connect(ctx, nullptr, 0);
  if (!core) {
    std::cerr << "[PW Loopback] pw_context_connect failed — PipeWire unavailable.\n";
    pw_context_destroy(ctx);
    pw_thread_loop_destroy(thread_loop_);
    thread_loop_ = nullptr;
    source_ = nullptr;
    return false;
  }

  // Build stream properties.
  pw_properties* props = pw_properties_new(
      PW_KEY_MEDIA_TYPE,     "Audio",
      PW_KEY_MEDIA_CATEGORY, "Capture",
      PW_KEY_MEDIA_ROLE,     "Screen",
      // Connect to the monitor of the default sink.
      PW_KEY_STREAM_CAPTURE_SINK, "true",
      nullptr);

  static const struct pw_stream_events kStreamEvents = {
      .version     = PW_VERSION_STREAM_EVENTS,
      .state_changed = OnStateChanged,
      .param_changed = OnParamChanged,
      .process       = OnProcess,
  };

  stream_ = pw_stream_new_simple(
      pw_thread_loop_get_loop(thread_loop_),
      "flutter-webrtc-loopback",
      props,
      &kStreamEvents,
      this);

  if (!stream_) {
    std::cerr << "[PW Loopback] pw_stream_new_simple failed.\n";
    pw_core_disconnect(core);
    pw_context_destroy(ctx);
    pw_thread_loop_destroy(thread_loop_);
    thread_loop_ = nullptr;
    source_ = nullptr;
    return false;
  }

  // Offer format params: prefer S16 at 48 kHz stereo; also accept F32.
  // PipeWire will pick the best match from the sink monitor's available formats.
  uint8_t buf1[1024], buf2[1024];
  spa_pod_builder b1 = SPA_POD_BUILDER_INIT(buf1, sizeof(buf1));
  spa_pod_builder b2 = SPA_POD_BUILDER_INIT(buf2, sizeof(buf2));

  spa_audio_info_raw info_s16 = {};
  info_s16.format   = SPA_AUDIO_FORMAT_S16;
  info_s16.rate     = 48000;
  info_s16.channels = 2;

  spa_audio_info_raw info_f32 = {};
  info_f32.format   = SPA_AUDIO_FORMAT_F32;
  info_f32.rate     = 48000;
  info_f32.channels = 2;

  const spa_pod* params[2] = {
      spa_format_audio_raw_build(&b1, SPA_PARAM_EnumFormat, &info_s16),
      spa_format_audio_raw_build(&b2, SPA_PARAM_EnumFormat, &info_f32),
  };

  int rc = pw_stream_connect(
      stream_,
      PW_DIRECTION_INPUT,
      PW_ID_ANY,
      static_cast<pw_stream_flags>(PW_STREAM_FLAG_AUTOCONNECT |
                                   PW_STREAM_FLAG_MAP_BUFFERS),
      params, 2);

  if (rc < 0) {
    std::cerr << "[PW Loopback] pw_stream_connect failed: "
              << spa_strerror(rc) << "\n";
    pw_stream_destroy(stream_);
    stream_ = nullptr;
    pw_core_disconnect(core);
    pw_context_destroy(ctx);
    pw_thread_loop_destroy(thread_loop_);
    thread_loop_ = nullptr;
    source_ = nullptr;
    return false;
  }

  // Initialise ring buffer: 500 ms of mono int16 at 48 kHz.
  {
    const size_t frames_500ms = 48000 / 2;  // 24 000 frames
    ring_capacity_frames_ = frames_500ms;
    ring_buf_.assign(ring_capacity_frames_, int16_t{0});
    ring_write_frame_  = 0;
    ring_read_frame_   = 0;
    ring_frames_avail_ = 0;
  }

  running_ = true;

  if (pw_thread_loop_start(thread_loop_) < 0) {
    std::cerr << "[PW Loopback] pw_thread_loop_start failed.\n";
    running_ = false;
    pw_stream_destroy(stream_);
    stream_ = nullptr;
    pw_core_disconnect(core);
    pw_context_destroy(ctx);
    pw_thread_loop_destroy(thread_loop_);
    thread_loop_ = nullptr;
    source_ = nullptr;
    return false;
  }

  feeder_thread_ = std::thread(&PipeWireLoopbackCapturer::FeederThread, this);
  return true;
}

// ---------------------------------------------------------------------------
// Stop
// ---------------------------------------------------------------------------

void PipeWireLoopbackCapturer::Stop() {
  if (!running_) return;
  running_ = false;

  if (feeder_thread_.joinable())
    feeder_thread_.join();

  if (thread_loop_) {
    pw_thread_loop_stop(thread_loop_);
  }
  if (stream_) {
    pw_stream_disconnect(stream_);
    pw_stream_destroy(stream_);
    stream_ = nullptr;
  }
  if (thread_loop_) {
    pw_thread_loop_destroy(thread_loop_);
    thread_loop_ = nullptr;
  }

  source_ = nullptr;
  pw_deinit();
}

// ---------------------------------------------------------------------------
// PipeWire stream callbacks
// ---------------------------------------------------------------------------

void PipeWireLoopbackCapturer::OnStateChanged(void* data,
                                               enum pw_stream_state /*old*/,
                                               enum pw_stream_state new_state,
                                               const char* error) {
  if (new_state == PW_STREAM_STATE_ERROR) {
    std::cerr << "[PW Loopback] Stream error: "
              << (error ? error : "(unknown)") << "\n";
  }
}

void PipeWireLoopbackCapturer::OnParamChanged(void* data, uint32_t id,
                                               const struct spa_pod* param) {
  if (!param || id != SPA_PARAM_Format) return;

  auto* self = static_cast<PipeWireLoopbackCapturer*>(data);

  spa_audio_info_raw info = {};
  if (spa_format_audio_raw_parse(param, &info) < 0) return;

  self->pw_format_      = info.format;
  self->pw_sample_rate_ = info.rate     ? info.rate     : 48000;
  self->pw_channels_    = info.channels ? info.channels : 2;

  // Renegotiate ring buffer capacity for the actual sample rate.
  {
    std::lock_guard<std::mutex> lock(self->ring_mutex_);
    const size_t frames_500ms         = self->pw_sample_rate_ / 2;
    self->ring_capacity_frames_       = frames_500ms;
    self->ring_buf_.assign(frames_500ms, int16_t{0});
    self->ring_write_frame_  = 0;
    self->ring_read_frame_   = 0;
    self->ring_frames_avail_ = 0;
  }

  // Negotiate buffer params back to PipeWire.
  uint8_t buf[1024];
  spa_pod_builder b = SPA_POD_BUILDER_INIT(buf, sizeof(buf));
  const spa_pod* params[1] = {
      spa_pod_builder_add_object(
          &b, SPA_TYPE_OBJECT_ParamBuffers, SPA_PARAM_Buffers,
          SPA_PARAM_BUFFERS_buffers, SPA_POD_CHOICE_RANGE_Int(2, 2, 32),
          SPA_PARAM_BUFFERS_blocks,  SPA_POD_Int(1),
          SPA_PARAM_BUFFERS_size,
          SPA_POD_CHOICE_RANGE_Int(
              /* default */ 4096 * 4,
              /* min */     256  * 4,
              /* max */     65536 * 4),
          SPA_PARAM_BUFFERS_stride, SPA_POD_Int(0)),
  };
  pw_stream_update_params(self->stream_, params, 1);
}

void PipeWireLoopbackCapturer::OnProcess(void* data) {
  static_cast<PipeWireLoopbackCapturer*>(data)->HandleProcess();
}

// ---------------------------------------------------------------------------
// HandleProcess — called on the PipeWire real-time thread.
// ---------------------------------------------------------------------------

void PipeWireLoopbackCapturer::HandleProcess() {
  if (!running_) return;

  pw_buffer* pw_buf = pw_stream_dequeue_buffer(stream_);
  if (!pw_buf) return;

  struct spa_buffer* spa_buf = pw_buf->buffer;
  struct spa_data*   d       = &spa_buf->datas[0];

  const uint32_t offset    = d->chunk ? d->chunk->offset : 0;
  const uint32_t size_b    = d->chunk ? d->chunk->size   : 0;
  const void*    audio_ptr = static_cast<const uint8_t*>(d->data) + offset;

  if (audio_ptr && size_b > 0) {
    const uint32_t bytes_per_frame =
        pw_channels_ * (pw_format_ == SPA_AUDIO_FORMAT_S16 ? 2 : 4);
    const uint32_t n_frames =
        (bytes_per_frame > 0) ? (size_b / bytes_per_frame) : 0;

    if (n_frames > 0) {
      std::lock_guard<std::mutex> lock(ring_mutex_);
      PushFrames(audio_ptr, n_frames);
    }
  }

  pw_stream_queue_buffer(stream_, pw_buf);
}

// ---------------------------------------------------------------------------
// PushFrames — converts raw PW audio to int16 mono and writes to ring_buf_.
// Must be called with ring_mutex_ held.
// ---------------------------------------------------------------------------

void PipeWireLoopbackCapturer::PushFrames(const void* raw, uint32_t n_frames) {
  const uint32_t ch = pw_channels_;

  for (uint32_t f = 0; f < n_frames; ++f) {
    // Overflow protection: drop oldest frame.
    if (ring_frames_avail_ >= ring_capacity_frames_) {
      ring_read_frame_ = (ring_read_frame_ + 1) % ring_capacity_frames_;
      --ring_frames_avail_;
    }

    int16_t mono = 0;

    if (pw_format_ == SPA_AUDIO_FORMAT_F32 ||
        pw_format_ == SPA_AUDIO_FORMAT_F32_LE) {
      const float* p = static_cast<const float*>(raw) + (f * ch);
      float sum = 0.f;
      for (uint32_t c = 0; c < ch; ++c) sum += p[c];
      mono = FloatToInt16(sum / static_cast<float>(ch));
    } else {
      // S16 (interleaved)
      const int16_t* p = static_cast<const int16_t*>(raw) + (f * ch);
      int32_t sum = 0;
      for (uint32_t c = 0; c < ch; ++c) sum += p[c];
      mono = static_cast<int16_t>(sum / static_cast<int32_t>(ch));
    }

    ring_buf_[ring_write_frame_] = mono;
    ring_write_frame_ = (ring_write_frame_ + 1) % ring_capacity_frames_;
    ++ring_frames_avail_;
  }
}

// ---------------------------------------------------------------------------
// FeederThread
//
// Wakes every 10 ms (wall-clock paced) and delivers exactly one 10 ms
// chunk of int16 mono audio to the RTCAudioSource via CaptureFrame().
//
// Uses the same pre-buffering and drift-compensation logic as the Windows
// WASAPI feeder to prevent over-delivery and ring underruns.
// ---------------------------------------------------------------------------

void PipeWireLoopbackCapturer::FeederThread() {
  using FClock = std::chrono::steady_clock;
  using FDur   = std::chrono::duration<double>;

  // Wait until the sample rate is known (param_changed fired).
  // pw_sample_rate_ is written by the PW thread before any process callbacks,
  // and we read it here only after pw_stream_connect returns successfully, so
  // this is safe without additional synchronisation.
  const int    sample_rate     = static_cast<int>(pw_sample_rate_);
  const size_t frames_per_10ms = static_cast<size_t>(sample_rate) / 100; // 480 @ 48 kHz

  // Pre-buffering: wait until ring has 160 ms of audio before first delivery.
  const size_t prebuf_frames = 16 * frames_per_10ms;  // 160 ms
  const size_t max_frames    = 20 * frames_per_10ms;  // 200 ms hard cap

  std::vector<int16_t> feed(frames_per_10ms, int16_t{0});

  bool    prebuffering        = true;
  bool    feeder_start_valid  = false;
  auto    feeder_start        = FClock::now();
  int64_t total_frames_del    = 0;

  auto next_tick = FClock::now() + std::chrono::milliseconds(10);

  while (running_) {
    std::this_thread::sleep_until(next_tick);
    next_tick += std::chrono::milliseconds(10);

    if (!running_) break;

    // Wait for the pre-buffer to fill.
    if (prebuffering) {
      std::lock_guard<std::mutex> lock(ring_mutex_);
      if (ring_frames_avail_ < prebuf_frames) continue;
      prebuffering       = false;
      feeder_start_valid = true;
      feeder_start       = FClock::now();
    }

    // Drift compensation: skip tick if we have delivered ahead of real-time.
    if (feeder_start_valid) {
      const double elapsed =
          FDur(FClock::now() - feeder_start).count();
      const int64_t expected =
          static_cast<int64_t>(elapsed * sample_rate);
      if (total_frames_del >
          expected + static_cast<int64_t>(frames_per_10ms)) {
        continue;
      }
    }

    std::fill(feed.begin(), feed.end(), int16_t{0});

    {
      std::lock_guard<std::mutex> lock(ring_mutex_);

      // Hard cap: trim ring to 200 ms.
      if (ring_frames_avail_ > max_frames) {
        const size_t drop = ring_frames_avail_ - max_frames;
        ring_read_frame_ = (ring_read_frame_ + drop) % ring_capacity_frames_;
        ring_frames_avail_ -= drop;
      }

      const size_t avail = ring_frames_avail_;
      const size_t read  = (avail >= frames_per_10ms) ? frames_per_10ms : avail;

      for (size_t i = 0; i < read; ++i) {
        feed[i]         = ring_buf_[ring_read_frame_];
        ring_read_frame_ = (ring_read_frame_ + 1) % ring_capacity_frames_;
      }
      ring_frames_avail_ -= read;
    }

    auto src = source_;
    if (src) {
      src->CaptureFrame(feed.data(), 16, sample_rate, 1, frames_per_10ms);
    }
    total_frames_del += static_cast<int64_t>(frames_per_10ms);
  }
}

}  // namespace flutter_webrtc_plugin

#endif  // __linux__
