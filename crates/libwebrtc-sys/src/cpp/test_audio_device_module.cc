#define WEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE 1

#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <memory>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

#include "absl/strings/string_view.h"
#include "api/array_view.h"
#include "api/make_ref_counted.h"
#include "common_audio/wav_file.h"
#include "modules/audio_device/audio_device_impl.h"
#include "modules/audio_device/include/audio_device_default.h"
#include "rtc_base/buffer.h"
#include "rtc_base/checks.h"
#include "rtc_base/event.h"
#include "rtc_base/logging.h"
#include "rtc_base/numerics/safe_conversions.h"
#include "rtc_base/platform_thread.h"
#include "rtc_base/random.h"
#include "rtc_base/synchronization/mutex.h"
#include "rtc_base/task_queue.h"
#include "rtc_base/task_utils/repeating_task.h"
#include "rtc_base/thread_annotations.h"
#include "rtc_base/time_utils.h"

#include "api/task_queue/task_queue_factory.h"
#include "modules/audio_device/audio_device_buffer.h"
#include "modules/audio_device/audio_device_generic.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/audio_device/include/audio_device_defines.h"
#include "modules/audio_device/include/test_audio_device.h"

namespace webrtc {

namespace {

constexpr int kFrameLengthUs = 10000;
constexpr int kFramesPerSecond = rtc::kNumMicrosecsPerSec / kFrameLengthUs;

size_t _SamplesPerFrame(int sampling_frequency_in_hz) {
  return rtc::CheckedDivExact(sampling_frequency_in_hz, kFramesPerSecond);
}

class TestADM : public AudioDeviceGeneric {
 public:
  // Creates a new TestADM. When capturing or playing, 10 ms audio
  // frames will be processed every 10ms / `speed`.
  // `capturer` is an object that produces audio data. Can be nullptr if this
  // device is never used for recording.
  // `renderer` is an object that receives audio data that would have been
  // played out. Can be nullptr if this device is never used for playing.
  TestADM(TaskQueueFactory* task_queue_factory,
          std::unique_ptr<TestAudioDeviceModule::Capturer> capturer,
          std::unique_ptr<TestAudioDeviceModule::Renderer> renderer,
          float speed = 1)
      : task_queue_factory_(task_queue_factory),
        capturer_(std::move(capturer)),
        renderer_(std::move(renderer)),
        process_interval_us_(kFrameLengthUs / speed),
        audio_buffer_(nullptr),
        rendering_(false),
        capturing_(false) {
    auto good_sample_rate = [](int sr) {
      return sr == 8000 || sr == 16000 || sr == 32000 || sr == 44100 ||
             sr == 48000;
    };

    if (renderer_) {
      const int sample_rate = renderer_->SamplingFrequency();
      playout_buffer_.resize(
          _SamplesPerFrame(sample_rate) * renderer_->NumChannels(), 0);
      RTC_CHECK(good_sample_rate(sample_rate));
    }
    if (capturer_) {
      RTC_CHECK(good_sample_rate(capturer_->SamplingFrequency()));
    }
  }

  TestADM(const TestADM&) = delete;
  TestADM& operator=(const TestADM&) = delete;
  ~TestADM() override = default;

  // Retrieve the currently utilized audio layer
  int32_t ActiveAudioLayer(
      AudioDeviceModule::AudioLayer& audioLayer) const override {
    return 0;
  }

  // Main initializaton and termination
  InitStatus Init() override {
    task_queue_ =
        std::make_unique<rtc::TaskQueue>(task_queue_factory_->CreateTaskQueue(
            "TestADMImpl", TaskQueueFactory::Priority::NORMAL));

    RepeatingTaskHandle::Start(task_queue_->Get(), [this]() {
      ProcessAudio();
      return TimeDelta::Micros(process_interval_us_);
    });
    return InitStatus::OK;
  }

  int32_t Terminate() override { return 0; }
  bool Initialized() const override { return true; }

  // Device enumeration
  int16_t PlayoutDevices() override { return 0; }
  int16_t RecordingDevices() override { return 0; }
  int32_t PlayoutDeviceName(uint16_t index,
                            char name[kAdmMaxDeviceNameSize],
                            char guid[kAdmMaxGuidSize]) override {
    return 0;
  }
  int32_t RecordingDeviceName(uint16_t index,
                              char name[kAdmMaxDeviceNameSize],
                              char guid[kAdmMaxGuidSize]) override {
    return 0;
  }

  // Device selection
  int32_t SetPlayoutDevice(uint16_t index) override { return 0; }
  int32_t SetPlayoutDevice(
      AudioDeviceModule::WindowsDeviceType device) override {
    return 0;
  }
  int32_t SetRecordingDevice(uint16_t index) override { return 0; }
  int32_t SetRecordingDevice(
      AudioDeviceModule::WindowsDeviceType device) override {
    return 0;
  }

  // Audio transport initialization
  int32_t PlayoutIsAvailable(bool& available) override {
    MutexLock lock(&lock_);
    available = renderer_ != nullptr;
    return 0;
  }

  int32_t InitPlayout() override {
    MutexLock lock(&lock_);

    if (rendering_) {
      return -1;
    }

    if (audio_buffer_ != nullptr && renderer_ != nullptr) {
      // Update webrtc audio buffer with the selected parameters
      audio_buffer_->SetPlayoutSampleRate(renderer_->SamplingFrequency());
      audio_buffer_->SetPlayoutChannels(renderer_->NumChannels());
    }
    rendering_initialized_ = true;
    return 0;
  }
  bool PlayoutIsInitialized() const override {
    MutexLock lock(&lock_);
    return rendering_initialized_;
  }
  int32_t RecordingIsAvailable(bool& available) override {
    MutexLock lock(&lock_);
    available = capturer_ != nullptr;
    return 0;
  }
  int32_t InitRecording() override {
    MutexLock lock(&lock_);

    if (capturing_) {
      return -1;
    }

    if (audio_buffer_ != nullptr && capturer_ != nullptr) {
      // Update webrtc audio buffer with the selected parameters
      audio_buffer_->SetRecordingSampleRate(capturer_->SamplingFrequency());
      audio_buffer_->SetRecordingChannels(capturer_->NumChannels());
    }
    capturing_initialized_ = true;
    return 0;
  }
  bool RecordingIsInitialized() const override {
    MutexLock lock(&lock_);
    return capturing_initialized_;
  }

  // Audio transport control
  int32_t StartPlayout() override {
    MutexLock lock(&lock_);
    RTC_CHECK(renderer_);
    rendering_ = true;
    return 0;
  }

  int32_t StopPlayout() override {
    MutexLock lock(&lock_);
    rendering_ = false;
    return 0;
  }
  bool Playing() const override {
    MutexLock lock(&lock_);
    return rendering_;
  }
  int32_t StartRecording() override {
    MutexLock lock(&lock_);
    capturing_ = true;
    return 0;
  }
  int32_t StopRecording() override {
    MutexLock lock(&lock_);
    capturing_ = false;
    return 0;
  }
  bool Recording() const override {
    MutexLock lock(&lock_);
    return capturing_;
  }

  // Audio mixer initialization
  int32_t InitSpeaker() override { return 0; }
  bool SpeakerIsInitialized() const override { return true; }
  int32_t InitMicrophone() override { return 0; }
  bool MicrophoneIsInitialized() const override { return true; }

  // Speaker volume controls
  int32_t SpeakerVolumeIsAvailable(bool& available) override { return 0; }
  int32_t SetSpeakerVolume(uint32_t volume) override { return 0; }
  int32_t SpeakerVolume(uint32_t& volume) const override { return 0; }
  int32_t MaxSpeakerVolume(uint32_t& maxVolume) const override { return 0; }
  int32_t MinSpeakerVolume(uint32_t& minVolume) const override { return 0; }

  // Microphone volume controls
  int32_t MicrophoneVolumeIsAvailable(bool& available) override { return 0; }
  int32_t SetMicrophoneVolume(uint32_t volume) override { return 0; }
  int32_t MicrophoneVolume(uint32_t& volume) const override { return 0; }
  int32_t MaxMicrophoneVolume(uint32_t& maxVolume) const override { return 0; }
  int32_t MinMicrophoneVolume(uint32_t& minVolume) const override { return 0; }

  // Speaker mute control
  int32_t SpeakerMuteIsAvailable(bool& available) override { return 0; }
  int32_t SetSpeakerMute(bool enable) override { return 0; }
  int32_t SpeakerMute(bool& enabled) const override { return 0; }

  // Microphone mute control
  int32_t MicrophoneMuteIsAvailable(bool& available) override { return 0; }
  int32_t SetMicrophoneMute(bool enable) override { return 0; }
  int32_t MicrophoneMute(bool& enabled) const override { return 0; }

  // Stereo support
  int32_t StereoPlayoutIsAvailable(bool& available) override {
    available = false;
    return 0;
  }
  int32_t SetStereoPlayout(bool enable) override { return 0; }
  int32_t StereoPlayout(bool& enabled) const override { return 0; }
  int32_t StereoRecordingIsAvailable(bool& available) override {
    available = false;
    return 0;
  }
  int32_t SetStereoRecording(bool enable) override { return 0; }
  int32_t StereoRecording(bool& enabled) const override { return 0; }

  // Delay information and control
  int32_t PlayoutDelay(uint16_t& delayMS) const override {
    delayMS = 0;
    return 0;
  }

  // Android only
  bool BuiltInAECIsAvailable() const override { return false; }
  bool BuiltInAGCIsAvailable() const override { return false; }
  bool BuiltInNSIsAvailable() const override { return false; }

  // Windows Core Audio and Android only.
  int32_t EnableBuiltInAEC(bool enable) override { return -1; }
  int32_t EnableBuiltInAGC(bool enable) override { return -1; }
  int32_t EnableBuiltInNS(bool enable) override { return -1; }

  // Play underrun count.
  int32_t GetPlayoutUnderrunCount() const override { return -1; }

// iOS only.
// TODO(henrika): add Android support.
#if defined(WEBRTC_IOS)
  int GetPlayoutAudioParameters(AudioParameters* params) const override {
    return -1;
  }
  int GetRecordAudioParameters(AudioParameters* params) const override {
    return -1;
  }
#endif  // WEBRTC_IOS

  void AttachAudioBuffer(AudioDeviceBuffer* audio_buffer) override {
    MutexLock lock(&lock_);
    RTC_DCHECK(audio_buffer || audio_buffer_);
    audio_buffer_ = audio_buffer;

    if (renderer_ != nullptr) {
      audio_buffer_->SetPlayoutSampleRate(renderer_->SamplingFrequency());
      audio_buffer_->SetPlayoutChannels(renderer_->NumChannels());
    }
    if (capturer_ != nullptr) {
      audio_buffer_->SetRecordingSampleRate(capturer_->SamplingFrequency());
      audio_buffer_->SetRecordingChannels(capturer_->NumChannels());
    }
  }

 private:
  void ProcessAudio() {
    MutexLock lock(&lock_);
    if (audio_buffer_ == nullptr) {
      return;
    }
    if (capturing_ && capturer_ != nullptr) {
      // Capture 10ms of audio. 2 bytes per sample.
      const bool keep_capturing = capturer_->Capture(&recording_buffer_);
      if (recording_buffer_.size() > 0) {
        audio_buffer_->SetRecordedBuffer(
            recording_buffer_.data(),
            recording_buffer_.size() / capturer_->NumChannels(),
            absl::make_optional(rtc::TimeNanos()));
        audio_buffer_->DeliverRecordedData();
      }
      if (!keep_capturing) {
        capturing_ = false;
      }
    }
    if (rendering_) {
      const int sampling_frequency = renderer_->SamplingFrequency();
      int32_t samples_per_channel = audio_buffer_->RequestPlayoutData(
          _SamplesPerFrame(sampling_frequency));
      audio_buffer_->GetPlayoutData(playout_buffer_.data());
      size_t samples_out = samples_per_channel * renderer_->NumChannels();
      RTC_CHECK_LE(samples_out, playout_buffer_.size());
      const bool keep_rendering = renderer_->Render(
          rtc::ArrayView<const int16_t>(playout_buffer_.data(), samples_out));
      if (!keep_rendering) {
        rendering_ = false;
      }
    }
  }

  TaskQueueFactory* const task_queue_factory_;
  const std::unique_ptr<TestAudioDeviceModule::Capturer> capturer_
      RTC_GUARDED_BY(lock_);
  const std::unique_ptr<TestAudioDeviceModule::Renderer> renderer_
      RTC_GUARDED_BY(lock_);
  const int64_t process_interval_us_;

  mutable Mutex lock_;
  AudioDeviceBuffer* audio_buffer_ RTC_GUARDED_BY(lock_) = nullptr;
  bool rendering_ RTC_GUARDED_BY(lock_) = false;
  bool capturing_ RTC_GUARDED_BY(lock_) = false;
  bool rendering_initialized_ RTC_GUARDED_BY(lock_) = false;
  bool capturing_initialized_ RTC_GUARDED_BY(lock_) = false;

  std::vector<int16_t> playout_buffer_ RTC_GUARDED_BY(lock_);
  rtc::BufferT<int16_t> recording_buffer_ RTC_GUARDED_BY(lock_);
  std::unique_ptr<rtc::TaskQueue> task_queue_;
};


class TestADMImpl : public AudioDeviceModuleImpl {
 public:
  TestADMImpl(
      TaskQueueFactory* task_queue_factory,
      std::unique_ptr<TestAudioDeviceModule::Capturer> capturer,
      std::unique_ptr<TestAudioDeviceModule::Renderer> renderer,
      float speed = 1)
      : AudioDeviceModuleImpl(
            AudioLayer::kDummyAudio,
            std::make_unique<TestADM>(task_queue_factory,
                                              std::move(capturer),
                                              std::move(renderer),
                                              speed),
            task_queue_factory,
            /*create_detached=*/true) {}

  ~TestADMImpl() override = default;
};

// A fake capturer that generates pulses with random samples between
// -max_amplitude and +max_amplitude.
class TestPulsedNoiseCapturerImpl final
    : public TestAudioDeviceModule::PulsedNoiseCapturer {
 public:
  // Assuming 10ms audio packets.
  TestPulsedNoiseCapturerImpl(int16_t max_amplitude,
                              int sampling_frequency_in_hz,
                              int num_channels)
      : sampling_frequency_in_hz_(sampling_frequency_in_hz),
        fill_with_zero_(false),
        random_generator_(1),
        max_amplitude_(max_amplitude),
        num_channels_(num_channels) {
    RTC_DCHECK_GT(max_amplitude, 0);
  }

  int SamplingFrequency() const override { return sampling_frequency_in_hz_; }

  int NumChannels() const override { return num_channels_; }

  bool Capture(rtc::BufferT<int16_t>* buffer) override {
    fill_with_zero_ = !fill_with_zero_;
    int16_t max_amplitude;
    {
      MutexLock lock(&lock_);
      max_amplitude = max_amplitude_;
    }
    buffer->SetData(_SamplesPerFrame(sampling_frequency_in_hz_) * num_channels_,
                    [&](rtc::ArrayView<int16_t> data) {
                      if (fill_with_zero_) {
                        std::fill(data.begin(), data.end(), 0);
                      } else {
                        std::generate(data.begin(), data.end(), [&]() {
                          return random_generator_.Rand(-max_amplitude,
                                                        max_amplitude);
                        });
                      }
                      return data.size();
                    });
    return true;
  }

  void SetMaxAmplitude(int16_t amplitude) override {
    MutexLock lock(&lock_);
    max_amplitude_ = amplitude;
  }

 private:
  int sampling_frequency_in_hz_;
  bool fill_with_zero_;
  Random random_generator_;
  Mutex lock_;
  int16_t max_amplitude_ RTC_GUARDED_BY(lock_);
  const int num_channels_;
};

class TestDiscardRenderer final : public TestAudioDeviceModule::Renderer {
 public:
  explicit TestDiscardRenderer(int sampling_frequency_in_hz, int num_channels)
      : sampling_frequency_in_hz_(sampling_frequency_in_hz),
        num_channels_(num_channels) {}

  int SamplingFrequency() const override { return sampling_frequency_in_hz_; }

  int NumChannels() const override { return num_channels_; }

  bool Render(rtc::ArrayView<const int16_t> data) override { return true; }

 private:
  int sampling_frequency_in_hz_;
  const int num_channels_;
};

}  // namespace

rtc::scoped_refptr<AudioDeviceModule> CreateTestAdm(
    TaskQueueFactory* task_queue_factory,
    std::unique_ptr<TestAudioDeviceModule::Capturer> capturer,
    std::unique_ptr<TestAudioDeviceModule::Renderer> renderer,
    float speed) {
  return rtc::make_ref_counted<TestADMImpl>(
      task_queue_factory, std::move(capturer), std::move(renderer), speed);
}

std::unique_ptr<TestAudioDeviceModule::PulsedNoiseCapturer>
CreatePulsedNoiseCapturer(int16_t max_amplitude,
                           int sampling_frequency_in_hz,
                           int num_channels) {
  return std::make_unique<TestPulsedNoiseCapturerImpl>(
      max_amplitude, sampling_frequency_in_hz, num_channels);
}

std::unique_ptr<TestAudioDeviceModule::Renderer> CreateDiscardRenderer(
    int sampling_frequency_in_hz,
    int num_channels) {
  return std::make_unique<TestDiscardRenderer>(sampling_frequency_in_hz,
                                               num_channels);
}

}  // namespace webrtc
