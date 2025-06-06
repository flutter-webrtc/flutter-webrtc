#ifndef BRIDGE_AUDIO_DEVICE_RECORDER_H_
#define BRIDGE_AUDIO_DEVICE_RECORDER_H_

#include <AL/al.h>
#include <AL/alc.h>
#include <mutex>

#include "api/media_stream_interface.h"
#include "libwebrtc-sys/include/local_audio_source.h"
#include "rtc_base/thread.h"

constexpr auto kPlayoutFrequency = 48000;
constexpr auto kRecordingFrequency = 48000;
constexpr auto kRecordingChannels = 1;
constexpr std::int64_t kBufferSizeMs = 10;
constexpr auto kProcessInterval = 10;
constexpr auto kALMaxValues = 6;
constexpr auto kQueryExactTimeEach = 20;
constexpr auto kDefaultPlayoutLatency = std::chrono::duration<double>(20.0);
constexpr auto kDefaultRecordingLatency = std::chrono::milliseconds(20);
constexpr auto kRestartAfterEmptyData = 200;  // Two seconds with no data.
constexpr auto kPlayoutPart = (kPlayoutFrequency * kBufferSizeMs + 999) / 1000;
constexpr auto kBuffersFullCount = 7;
constexpr auto kBuffersKeepReadyCount = 5;
constexpr auto kRecordingPart =
    (kRecordingFrequency * kBufferSizeMs + 999) / 1000;

// Audio recording from an audio device and propagation of the recorded audio
// data to a `bridge::LocalAudioSource`.
class AudioDeviceRecorder {
 public:
  AudioDeviceRecorder(std::string deviceId,
                      webrtc::scoped_refptr<webrtc::AudioProcessing> ap);

  // Captures a new batch of audio samples and propagates it to the inner
  // `bridge::LocalAudioSource`.
  bool ProcessRecordedPart(bool firstInCycle);

  // Stops audio capture freeing the captured device.
  void StopCapture();

  // Starts recording audio from the captured device.
  void StartCapture();

  // Returns the `bridge::LocalAudioSource` that this `AudioDeviceRecorder`
  // writes the recorded audio to.
  webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource();

 private:
  void openRecordingDevice();
  bool checkDeviceFailed();
  void closeRecordingDevice();
  void restartRecording();
  bool validateRecordingDeviceId();

  webrtc::scoped_refptr<bridge::LocalAudioSource> _source;
  webrtc::scoped_refptr<webrtc::AudioProcessing> _audio_processing;
  ALCdevice* _device;
  std::string _deviceId;
  std::recursive_mutex _mutex;
  bool _recordingFailed = false;
  bool _recording = false;
  int _recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
  std::vector<char>* _recordedSamples =
      new std::vector<char>(_recordBufferSize, 0);
  int _emptyRecordingData = 0;
};

#endif  // BRIDGE_AUDIO_DEVICE_RECORDER_H_
