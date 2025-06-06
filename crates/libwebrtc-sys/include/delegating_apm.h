#ifndef BRIDGE_DELEGATING_APM_
#define BRIDGE_DELEGATING_APM_

#include <stdio.h>

#include <atomic>
#include <list>
#include <memory>
#include <optional>
#include <shared_mutex>
#include <string>
#include <unordered_map>
#include <vector>

#include "api/audio/audio_processing.h"
#include "modules/audio_processing/include/aec_dump.h"

// `AudioProcessing` that delegates playout (reverse) media to multiple inner
// `AudioProcessing`s.
class PlayoutDelegatingAPM : public webrtc::AudioProcessing {
 public:
  PlayoutDelegatingAPM();
  ~PlayoutDelegatingAPM() override;

  void AddDelegate(std::string device_id,
                   webrtc::scoped_refptr<webrtc::AudioProcessing> delegate);
  void RemoveDelegate(std::string device_id);

  int Initialize() override;
  int Initialize(const webrtc::ProcessingConfig& processing_config) override;

  void ApplyConfig(const webrtc::AudioProcessing::Config& config) override;

  int proc_sample_rate_hz() const override;
  int proc_split_sample_rate_hz() const override;
  size_t num_input_channels() const override;
  size_t num_proc_channels() const override;
  size_t num_output_channels() const override;
  size_t num_reverse_channels() const override;

  void set_output_will_be_muted(bool muted) override;

  void SetRuntimeSetting(
      webrtc::AudioProcessing::RuntimeSetting setting) override;
  bool PostRuntimeSetting(
      webrtc::AudioProcessing::RuntimeSetting setting) override;

  // Capture-side exclusive methods possibly running APM in a multi-threaded
  // manner.
  int ProcessStream(const int16_t* const src,
                    const webrtc::StreamConfig& input_config,
                    const webrtc::StreamConfig& output_config,
                    int16_t* const dest) override;
  int ProcessStream(const float* const* src,
                    const webrtc::StreamConfig& input_config,
                    const webrtc::StreamConfig& output_config,
                    float* const* dest) override;

  // Render-side exclusive methods possibly running APM in a multi-threaded
  // manner.
  int ProcessReverseStream(const int16_t* const src,
                           const webrtc::StreamConfig& input_config,
                           const webrtc::StreamConfig& output_config,
                           int16_t* const dest) override;
  int ProcessReverseStream(const float* const* src,
                           const webrtc::StreamConfig& input_config,
                           const webrtc::StreamConfig& output_config,
                           float* const* dest) override;
  int AnalyzeReverseStream(const float* const* data,
                           const webrtc::StreamConfig& reverse_config) override;

  bool GetLinearAecOutput(
      webrtc::ArrayView<std::array<float, 160>> linear_output) const override;

  void set_stream_analog_level(int level) override;
  int recommended_stream_analog_level() const override;

  int set_stream_delay_ms(int delay) override;
  int stream_delay_ms() const override;

  void set_stream_key_pressed(bool key_pressed) override;

  bool CreateAndAttachAecDump(
      absl::string_view file_name,
      int64_t max_log_size_bytes,
      absl::Nonnull<webrtc::TaskQueueBase*> worker_queue) override;
  bool CreateAndAttachAecDump(
      FILE* handle,
      int64_t max_log_size_bytes,
      absl::Nonnull<webrtc::TaskQueueBase*> worker_queue) override;
  void AttachAecDump(std::unique_ptr<webrtc::AecDump> aec_dump) override;
  void DetachAecDump() override;

  webrtc::AudioProcessingStats GetStatistics(
      bool /* has_remote_tracks */) override {
    return GetStatistics();
  }

  webrtc::AudioProcessingStats GetStatistics() override;

  webrtc::AudioProcessing::Config GetConfig() const override;

 private:
  std::shared_mutex delegates_lock_;
  std::unordered_map<std::string, webrtc::scoped_refptr<webrtc::AudioProcessing>>
      delegates_;
};

#endif  // MODULES_AUDIO_PROCESSING_AUDIO_PROCESSING_IMPL_H_
