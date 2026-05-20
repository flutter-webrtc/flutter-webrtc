#ifndef APPLICATION_LOOPBACK_CAPTURER_H_
#define APPLICATION_LOOPBACK_CAPTURER_H_

#ifdef _WIN32

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <thread>
#include <vector>

#include <audioclient.h>
#include <mmdeviceapi.h>
#include <windows.h>

#include "loopback_capturer.h"

namespace flutter_webrtc_plugin {

// Windows WASAPI implementation of LoopbackCapturer.
//
// Captures audio via ApplicationLoopbackAudio (Win10 20H1+ / Build 19041).
// Default (target_pid_ == 0): EXCLUDE self PID → captures all system audio.
// Specific PID (SetTargetProcessId): INCLUDE that PID → captures only that app.
class ApplicationLoopbackCapturer : public LoopbackCapturer {
 public:
  ApplicationLoopbackCapturer();
  ~ApplicationLoopbackCapturer() override;

  // Call before Start() to isolate audio from a specific process.
  // Pass 0 (default) to capture all system audio.
  void SetTargetProcessId(DWORD pid) { target_pid_ = pid; }

  bool Start(scoped_refptr<RTCAudioSource> source) override;
  void Stop() override;

 private:
  // Returns a fully-initialised IAudioClient ready for Start(), or nullptr.
  // Also populates mix_format_.
  IAudioClient* TryInitApplicationLoopback();

  void CaptureThread();
  void FeederThread();

  scoped_refptr<RTCAudioSource> source_;
  std::atomic<bool> running_{false};
  std::thread capture_thread_;
  std::thread feeder_thread_;

  IAudioClient* audio_client_ = nullptr;
  IAudioCaptureClient* capture_client_ = nullptr;
  WAVEFORMATEX* mix_format_ = nullptr;

  // Event signalled by WASAPI when a buffer period has elapsed.
  HANDLE buffer_ready_event_ = INVALID_HANDLE_VALUE;

  // Ring buffer used to decouple the WASAPI capture thread from the
  // WebRTC feeder thread.  CaptureThread writes here; FeederThread reads.
  std::mutex ring_mutex_;
  std::condition_variable ring_cv_;  // signalled when ring has >= 10 ms of data
  std::vector<int16_t> ring_buf_;   // capacity: ring_capacity_frames_ * cached_out_channels_
  size_t ring_capacity_frames_ = 0;
  size_t ring_write_frame_     = 0;
  size_t ring_read_frame_      = 0;
  size_t ring_frames_avail_    = 0;

  // Audio format cached from mix_format_ for use by FeederThread.
  int    cached_sample_rate_   = 0;
  size_t cached_out_channels_  = 0;

  // 0 = capture all system audio (EXCLUDE self).
  // Non-zero = capture only that process (INCLUDE mode).
  DWORD  target_pid_           = 0;
};

}  // namespace flutter_webrtc_plugin

#endif  // _WIN32
#endif  // APPLICATION_LOOPBACK_CAPTURER_H_
