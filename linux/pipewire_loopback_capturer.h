#ifndef PIPEWIRE_LOOPBACK_CAPTURER_H_
#define PIPEWIRE_LOOPBACK_CAPTURER_H_

#ifdef __linux__

#include <atomic>
#include <mutex>
#include <thread>
#include <vector>

#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>

#include "loopback_capturer.h"

namespace flutter_webrtc_plugin {

// Linux PipeWire implementation of LoopbackCapturer.
//
// Connects a PW_DIRECTION_INPUT stream to the monitor of the default
// audio sink to capture all desktop audio output.
//
// Audio is captured in whatever format PipeWire negotiates (F32LE or S16LE)
// at the negotiated sample rate, then converted to int16 mono and pushed into
// a ring buffer.  A feeder thread wakes every 10 ms and delivers exactly
// 10 ms worth of int16 mono samples to the RTCAudioSource via CaptureFrame().
class PipeWireLoopbackCapturer : public LoopbackCapturer {
 public:
  PipeWireLoopbackCapturer();
  ~PipeWireLoopbackCapturer() override;

  bool Start(scoped_refptr<RTCAudioSource> source) override;
  void Stop() override;

 private:
  // PipeWire stream event callbacks (C-style, forwarded to members below).
  static void OnStateChanged(void* data, enum pw_stream_state old_state,
                             enum pw_stream_state new_state, const char* error);
  static void OnParamChanged(void* data, uint32_t id, const struct spa_pod* param);
  static void OnProcess(void* data);

  void HandleProcess();
  void FeederThread();

  // Converts a buffer of raw PW audio to int16 mono and appends to ring_buf_.
  // Called from HandleProcess() under ring_mutex_.
  void PushFrames(const void* data, uint32_t n_frames);

  // -------------------------------------------------------------------------
  // PipeWire objects — owned by the pw_thread_loop's thread.
  // -------------------------------------------------------------------------
  pw_thread_loop* thread_loop_ = nullptr;
  pw_stream*      stream_      = nullptr;

  // -------------------------------------------------------------------------
  // Audio format negotiated by PipeWire.
  // -------------------------------------------------------------------------
  enum spa_audio_format pw_format_ = SPA_AUDIO_FORMAT_UNKNOWN;
  uint32_t pw_sample_rate_         = 48000;
  uint32_t pw_channels_            = 2;

  // -------------------------------------------------------------------------
  // Ring buffer — written by the PW process callback, read by FeederThread.
  // Always stores int16 mono at pw_sample_rate_.
  // -------------------------------------------------------------------------
  std::mutex           ring_mutex_;
  std::vector<int16_t> ring_buf_;
  size_t ring_capacity_frames_ = 0;
  size_t ring_write_frame_     = 0;
  size_t ring_read_frame_      = 0;
  size_t ring_frames_avail_    = 0;

  // -------------------------------------------------------------------------
  // Feeder thread state.
  // -------------------------------------------------------------------------
  std::atomic<bool> running_{false};
  std::thread       feeder_thread_;

  // Snapshot of source_ protected by atomic start/stop sequencing.
  // Written once in Start(), read from FeederThread, cleared in Stop().
  scoped_refptr<RTCAudioSource> source_;
};

}  // namespace flutter_webrtc_plugin

#endif  // __linux__
#endif  // PIPEWIRE_LOOPBACK_CAPTURER_H_
