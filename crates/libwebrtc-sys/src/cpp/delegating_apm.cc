#include <mutex>

#include "delegating_apm.h"
#include "rtc_base/logging.h"

PlayoutDelegatingAPM::PlayoutDelegatingAPM() = default;

PlayoutDelegatingAPM::~PlayoutDelegatingAPM() = default;

void PlayoutDelegatingAPM::AddDelegate(
    std::string deviceId,
    rtc::scoped_refptr<webrtc::AudioProcessing> delegate) {
  std::unique_lock lock(delegates_lock_);

  delegates_[deviceId] = delegate;
}

void PlayoutDelegatingAPM::RemoveDelegate(std::string deviceId) {
  std::unique_lock lock(delegates_lock_);

  delegates_.erase(deviceId);
}

int PlayoutDelegatingAPM::Initialize() {
  // Not used.
  RTC_LOG(LS_ERROR) << "`PlayoutDelegatingAPM::Initialize()` is unsupported";

  return webrtc::AudioProcessing::Error::kNoError;
}

int PlayoutDelegatingAPM::Initialize(
    const webrtc::ProcessingConfig& processing_config) {
  // Not used.
  RTC_LOG(LS_ERROR) << "`PlayoutDelegatingAPM::Initialize()` is unsupported";

  return webrtc::AudioProcessing::Error::kNoError;
}

void PlayoutDelegatingAPM::ApplyConfig(const AudioProcessing::Config& config) {
  // Ignore config change because it is set individually.
}

int PlayoutDelegatingAPM::proc_sample_rate_hz() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::proc_sample_rate_hz()` is unsupported";
  return 0;
}

int PlayoutDelegatingAPM::proc_split_sample_rate_hz() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::proc_split_sample_rate_hz()` is unsupported";
  return 0;
}

size_t PlayoutDelegatingAPM::num_input_channels() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::num_input_channels()` is unsupported";
  return 0;
}

size_t PlayoutDelegatingAPM::num_proc_channels() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::num_proc_channels()` is unsupported";
  return 0;
}

size_t PlayoutDelegatingAPM::num_output_channels() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::num_output_channels()` is unsupported";
  return 0;
}

size_t PlayoutDelegatingAPM::num_reverse_channels() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::num_reverse_channels()` is unsupported";
  return 0;
}

void PlayoutDelegatingAPM::set_output_will_be_muted(bool muted) {
  std::shared_lock lock(delegates_lock_);

  // This is only called with `true` once all send streams are muted so it's OK
  // to propagate.
  for (const auto& [_, ap] : delegates_) {
    ap->set_output_will_be_muted(muted);
  }
}

void PlayoutDelegatingAPM::SetRuntimeSetting(
    webrtc::AudioProcessing::RuntimeSetting setting) {
  // Not used.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::SetRuntimeSetting()` is unsupported";
}

bool PlayoutDelegatingAPM::PostRuntimeSetting(
    webrtc::AudioProcessing::RuntimeSetting setting) {
  // Not used.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::PostRuntimeSetting()` is unsupported";

  return true;
}

int PlayoutDelegatingAPM::ProcessStream(
    const int16_t* const src,
    const webrtc::StreamConfig& input_config,
    const webrtc::StreamConfig& output_config,
    int16_t* const dest) {
  // Not used. Captured audio is processed individually in `LocalAudioSource`.
  RTC_LOG(LS_ERROR) << "`PlayoutDelegatingAPM::ProcessStream()` is unsupported";

  return webrtc::AudioProcessing::Error::kNoError;
}

int PlayoutDelegatingAPM::ProcessStream(
    const float* const* src,
    const webrtc::StreamConfig& input_config,
    const webrtc::StreamConfig& output_config,
    float* const* dest) {
  // Not used. Captured audio is processed individually in `LocalAudioSource`.
  RTC_LOG(LS_ERROR) << "`PlayoutDelegatingAPM::ProcessStream()` is unsupported";

  return webrtc::AudioProcessing::Error::kNoError;
}

int PlayoutDelegatingAPM::ProcessReverseStream(
    const int16_t* const src,
    const webrtc::StreamConfig& input_config,
    const webrtc::StreamConfig& output_config,
    int16_t* const dest) {
  std::shared_lock lock(delegates_lock_);

  for (const auto& [_, ap] : delegates_) {
    auto res = ap->ProcessReverseStream(src, input_config, output_config, dest);
    if (res != webrtc::AudioProcessing::Error::kNoError) {
      RTC_LOG(LS_ERROR) << "Interleaved `ProcessReverseStream` failed: " << res;
    }
  }

  return webrtc::AudioProcessing::Error::kNoError;
}

int PlayoutDelegatingAPM::ProcessReverseStream(
    const float* const* src,
    const webrtc::StreamConfig& input_config,
    const webrtc::StreamConfig& output_config,
    float* const* dest) {
  std::shared_lock lock(delegates_lock_);

  for (const auto& [_, ap] : delegates_) {
    auto res = ap->ProcessReverseStream(src, input_config, output_config, dest);
    if (res != webrtc::AudioProcessing::Error::kNoError) {
      RTC_LOG(LS_ERROR)
          << "Deinterleaved `ProcessReverseStream` failed: " << res;
    }
  }

  return webrtc::AudioProcessing::Error::kNoError;
}

int PlayoutDelegatingAPM::AnalyzeReverseStream(
    const float* const* data,
    const webrtc::StreamConfig& reverse_config) {
  std::shared_lock lock(delegates_lock_);

  for (const auto& [_, ap] : delegates_) {
    auto res = ap->AnalyzeReverseStream(data, reverse_config);
    if (res != webrtc::AudioProcessing::Error::kNoError) {
      RTC_LOG(LS_ERROR)
          << "Deinterleaved `AnalyzeReverseStream` failed: " << res;
    }
  }

  return webrtc::AudioProcessing::Error::kNoError;
}

bool PlayoutDelegatingAPM::GetLinearAecOutput(
    rtc::ArrayView<std::array<float, 160>> linear_output) const {
  // Not used.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::GetLinearAecOutput()` is unsupported";

  return false;
}

void PlayoutDelegatingAPM::set_stream_analog_level(int level) {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::set_stream_analog_level()` is unsupported";
}

int PlayoutDelegatingAPM::recommended_stream_analog_level() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::recommended_stream_analog_level()` "
      << "is unsupported";

  return 1;
}

int PlayoutDelegatingAPM::set_stream_delay_ms(int delay) {
  // TODO: `aec3` can figure out stream delay on its own, but it needs some time
  //       to do this. Providing delay might improve aec during the first few
  //       seconds of the call, so might be worth to implement this.
  // Not used.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::set_stream_delay_ms()` " << delay;
  return 0;
}

int PlayoutDelegatingAPM::stream_delay_ms() const {
  // Not used. Internal only.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::stream_delay_ms()` is unsupported";
  return 0;
}

void PlayoutDelegatingAPM::set_stream_key_pressed(bool key_pressed) {
  // Not used.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::set_stream_key_pressed()` is unsupported";
}

bool PlayoutDelegatingAPM::CreateAndAttachAecDump(
    absl::string_view file_name,
    int64_t max_log_size_bytes,
    absl::Nonnull<webrtc::TaskQueueBase*> worker_queue) {
  // Not used.
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::CreateAndAttachAecDump()` is unsupported";
  return false;
}
bool PlayoutDelegatingAPM::CreateAndAttachAecDump(
    FILE* handle,
    int64_t max_log_size_bytes,
    absl::Nonnull<webrtc::TaskQueueBase*> worker_queue) {
  RTC_LOG(LS_ERROR)
      << "`PlayoutDelegatingAPM::CreateAndAttachAecDump()` is unsupported";
  return false;
}

void PlayoutDelegatingAPM::AttachAecDump(
    std::unique_ptr<webrtc::AecDump> aec_dump) {
  // Not used.
  RTC_LOG(LS_ERROR) << "`PlayoutDelegatingAPM::AttachAecDump()` is unsupported";
}

void PlayoutDelegatingAPM::DetachAecDump() {
  // Not used.
  RTC_LOG(LS_ERROR) << "`PlayoutDelegatingAPM::DetachAecDump()` is unsupported";
}

webrtc::AudioProcessingStats PlayoutDelegatingAPM::GetStatistics() {
  // Only used by VAD, which is not used anyway.
  return {};
}

webrtc::AudioProcessing::Config PlayoutDelegatingAPM::GetConfig() const {
  // Only used for later updates of config via `ApplyConfig`.
  return {};
}
