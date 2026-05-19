#ifndef APPLICATION_LOOPBACK_CAPTURER_H_
#define APPLICATION_LOOPBACK_CAPTURER_H_

#ifdef _WIN32

#include <atomic>
#include <thread>
#include <vector>

#include <audioclient.h>
#include <mmdeviceapi.h>
#include <windows.h>

#include "loopback_capturer.h"

namespace flutter_webrtc_plugin {

// Windows WASAPI implementation of LoopbackCapturer.
//
// Primary path  (Win10 20H1+ / Build 19041):
//   Uses ApplicationLoopbackAudio API (AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK)
//   with PID=0 + EXCLUDE mode, which captures the full system render mix.
//
// Fallback path (any Windows version):
//   Uses classic WASAPI loopback (AUDCLNT_STREAMFLAGS_LOOPBACK) on the
//   default render endpoint, which has the same system-wide capture effect.
class ApplicationLoopbackCapturer : public LoopbackCapturer {
 public:
  ApplicationLoopbackCapturer();
  ~ApplicationLoopbackCapturer() override;

  bool Start(scoped_refptr<RTCAudioSource> source) override;
  void Stop() override;

 private:
  // Returns a fully-initialised IAudioClient ready for Start(), or nullptr.
  // Also populates mix_format_.
  IAudioClient* TryInitApplicationLoopback();
  IAudioClient* TryInitClassicLoopback();

  void CaptureThread();

  // Convert IEEE-float 32-bit samples to int16_t PCM in |out|.
  static void F32ToI16(const float* src, int16_t* dst, size_t count);

  scoped_refptr<RTCAudioSource> source_;
  std::atomic<bool> running_{false};
  std::thread capture_thread_;

  IAudioClient* audio_client_ = nullptr;
  IAudioCaptureClient* capture_client_ = nullptr;
  WAVEFORMATEX* mix_format_ = nullptr;

  // Event signalled by WASAPI when a buffer period has elapsed.
  HANDLE buffer_ready_event_ = INVALID_HANDLE_VALUE;

  // Reusable conversion buffer (avoids per-frame allocation).
  std::vector<int16_t> conv_buf_;
};

}  // namespace flutter_webrtc_plugin

#endif  // _WIN32
#endif  // APPLICATION_LOOPBACK_CAPTURER_H_
