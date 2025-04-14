#include <iostream>

#include "api/make_ref_counted.h"
#include "audio_device_recorder.h"
#include "rtc_base/logging.h"

namespace recorder {

template <typename Callback>
void EnumerateDevices(ALCenum specifier, Callback&& callback) {
  auto devices = alcGetString(nullptr, specifier);
  while (*devices != 0) {
    callback(devices);
    while (*devices != 0) {
      ++devices;
    }
    ++devices;
  }
}

std::string GetDefaultDeviceId(ALCenum specifier) {
  const auto device = alcGetString(nullptr, specifier);
  return device ? std::string(device) : std::string();
}

bool CheckDeviceFailed(ALCdevice* device) {
  if (auto code = alcGetError(device); code != ALC_NO_ERROR) {
    RTC_LOG(LS_ERROR) << "OpenAL Error " << code << ": "
                      << (const char*)alcGetString(device, code);
    return true;
  }

  return false;
}
}  // namespace recorder

AudioDeviceRecorder::AudioDeviceRecorder(
    std::string deviceId,
    rtc::scoped_refptr<webrtc::AudioProcessing> ap) {
  _device = alcCaptureOpenDevice(deviceId.empty() ? nullptr : deviceId.c_str(),
                                 kRecordingFrequency, AL_FORMAT_MONO16,
                                 kRecordingFrequency);
  _source = bridge::LocalAudioSource::Create(cricket::AudioOptions(), ap);
  _deviceId = deviceId;
}

bool AudioDeviceRecorder::ProcessRecordedPart(bool isFirstInCycle) {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  auto samples = ALint();
  alcGetIntegerv(_device, ALC_CAPTURE_SAMPLES, 1, &samples);

  if (recorder::CheckDeviceFailed(_device)) {
    _recordingFailed = true;
    return false;
  }

  if (samples <= 0) {
    if (isFirstInCycle) {
      ++_emptyRecordingData;
      if (_emptyRecordingData == kRestartAfterEmptyData) {
        restartRecording();
      }
    }
    return false;
  } else if (samples < kRecordingPart) {
    // Not enough data for 10 milliseconds.
    return false;
  }

  _emptyRecordingData = 0;
  alcCaptureSamples(_device, _recordedSamples->data(), kRecordingPart);

  if (recorder::CheckDeviceFailed(_device)) {
    restartRecording();
    return false;
  }

  _source->OnData(_recordedSamples->data(),  // audio_data
                  16,
                  kRecordingFrequency,  // sample_rate
                  kRecordingChannels, kRecordingFrequency * 10 / 1000);

  return true;
}

void AudioDeviceRecorder::StopCapture() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  if (!_recording) {
    return;
  }

  _recording = false;
  if (_recordingFailed) {
    return;
  }
  if (_device) {
    alcCaptureStop(_device);
  }
}

void AudioDeviceRecorder::StartCapture() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  if (_recording) {
    return;
  }

  _recording = true;
  if (_recordingFailed) {
    return;
  }

  alcCaptureStart(_device);
  if (recorder::CheckDeviceFailed(_device)) {
    _recordingFailed = true;
    return;
  }

  if (_recordingFailed) {
    closeRecordingDevice();
  }
}

rtc::scoped_refptr<bridge::LocalAudioSource> AudioDeviceRecorder::GetSource() {
  return _source;
}

bool AudioDeviceRecorder::validateRecordingDeviceId() {
  auto valid = false;
  recorder::EnumerateDevices(ALC_CAPTURE_DEVICE_SPECIFIER,
                             [&](const char* device) {
                               if (!valid && _deviceId == std::string(device)) {
                                 valid = true;
                               }
                             });
  if (valid) {
    return true;
  }
  const auto defaultDeviceId =
      recorder::GetDefaultDeviceId(ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
  if (!defaultDeviceId.empty()) {
    _deviceId = defaultDeviceId;
    return true;
  }
  return false;
}

void AudioDeviceRecorder::restartRecording() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  if (!_recording) {
    return;
  }

  closeRecordingDevice();

  if (!validateRecordingDeviceId()) {
    _recording = true;
    _recordingFailed = true;
    return;
  }

  openRecordingDevice();
  if (_device && !_recordingFailed) {
    StartCapture();
  }

  return;
}

void AudioDeviceRecorder::closeRecordingDevice() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  if (_device) {
    alcCaptureCloseDevice(_device);
    _device = nullptr;
  }
}

void AudioDeviceRecorder::openRecordingDevice() {
  if (_device && !_recordingFailed) {
    return;
  }

  _device = alcCaptureOpenDevice(
      _deviceId.empty() ? nullptr : _deviceId.c_str(), kRecordingFrequency,
      AL_FORMAT_MONO16, kRecordingFrequency);

  if (!_device) {
    _recordingFailed = true;
  } else {
    _recordingFailed = false;
  }
}
