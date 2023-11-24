/*
 * This file is modified version of the one from Desktop App Toolkit, a set of
 * libraries for developing nice desktop applications.
 * https://github.com/desktop-app/lib_webrtc/blob/openal/webrtc/details/webrtc_openal_adm.cpp
 *
 * Copyright (c) 2014-2023 The Desktop App Toolkit Authors.
 *
 * Desktop App Toolkit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * It is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * In addition, as a special exception, the copyright holders give permission
 * to link the code of portions of this program with the OpenSSL library.
 *
 * Full license: https://github.com/desktop-app/legal/blob/master/LICENSE
 */

#include <iostream>

#include <algorithm>
#include <cfenv>
#include <chrono>
#include <cmath>
#include <thread>
#include <vector>
#include "adm.h"
#include "api/make_ref_counted.h"
#include "common_audio/wav_file.h"
#include "modules/audio_device/include/test_audio_device.h"
#include "rtc_base/checks.h"
#include "rtc_base/logging.h"
#include "rtc_base/platform_thread.h"

constexpr auto kPlayoutFrequency = 48000;
constexpr auto kRecordingFrequency = 48000;
constexpr auto kRecordingChannels = 1;
constexpr std::int64_t kBufferSizeMs = 10;
constexpr auto kRecordingPart =
    (kRecordingFrequency * kBufferSizeMs + 999) / 1000;
constexpr auto kProcessInterval = 10;
constexpr auto kALMaxValues = 6;
constexpr auto kQueryExactTimeEach = 20;
constexpr auto kDefaultPlayoutLatency = std::chrono::duration<double>(20.0);
constexpr auto kDefaultRecordingLatency = std::chrono::milliseconds(20);
constexpr auto kRestartAfterEmptyData = 50;  // Half a second with no data.
constexpr auto kPlayoutPart = (kPlayoutFrequency * kBufferSizeMs + 999) / 1000;
constexpr auto kBuffersFullCount = 7;
constexpr auto kBuffersKeepReadyCount = 5;

auto kAL_EVENT_CALLBACK_FUNCTION_SOFT = ALenum();
auto kAL_EVENT_CALLBACK_USER_PARAM_SOFT = ALenum();
auto kAL_EVENT_TYPE_BUFFER_COMPLETED_SOFT = ALenum();
auto kAL_EVENT_TYPE_SOURCE_STATE_CHANGED_SOFT = ALenum();
auto kAL_EVENT_TYPE_DISCONNECTED_SOFT = ALenum();
auto kAL_SAMPLE_OFFSET_CLOCK_SOFT = ALenum();
auto kAL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT = ALenum();

auto kALC_DEVICE_LATENCY_SOFT = ALenum();

using AL_INT64_TYPE = std::int64_t;

using ALEVENTPROCSOFT = void (*)(ALenum eventType,
                                 ALuint object,
                                 ALuint param,
                                 ALsizei length,
                                 const ALchar* message,
                                 void* userParam);
using ALEVENTCALLBACKSOFT = void (*)(ALEVENTPROCSOFT callback, void* userParam);
using ALCSETTHREADCONTEXT = ALCboolean (*)(ALCcontext* context);
using ALGETSOURCEI64VSOFT = void (*)(ALuint source,
                                     ALenum param,
                                     AL_INT64_TYPE* values);
using ALCGETINTEGER64VSOFT = void (*)(ALCdevice* device,
                                      ALCenum pname,
                                      ALsizei size,
                                      AL_INT64_TYPE* values);

ALEVENTCALLBACKSOFT alEventCallbackSOFT /* = nullptr*/;
ALCSETTHREADCONTEXT alcSetThreadContext /* = nullptr*/;
ALGETSOURCEI64VSOFT alGetSourcei64vSOFT /* = nullptr*/;
ALCGETINTEGER64VSOFT alcGetInteger64vSOFT /* = nullptr*/;

struct OpenALAudioDeviceModule::Data {
  Data() {
    _playoutThread = rtc::Thread::Create();
    _recordingThread = rtc::Thread::Create();
    rtc::Thread::Current()->AllowInvokesToThread(_playoutThread.get());
    rtc::Thread::Current()->AllowInvokesToThread(_recordingThread.get());
  }

  std::unique_ptr<rtc::Thread> _playoutThread;
  std::unique_ptr<rtc::Thread> _recordingThread;
  ALuint source = 0;
  int queuedBuffersCount = 0;
  std::array<ALuint, kBuffersFullCount> buffers = {{0}};
  std::array<bool, kBuffersFullCount> queuedBuffers = {{false}};
  int playBufferSize = kPlayoutPart * sizeof(int16_t) * 2;
  std::vector<char>* playoutSamples = new std::vector<char>(playBufferSize, 0);
  int recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
  std::vector<char>* recordedSamples =
      new std::vector<char>(recordBufferSize, 0);
  int64_t exactDeviceTimeCounter = 0;
  int64_t lastExactDeviceTime = 0;
  std::int64_t lastExactDeviceTimeWhen = 0;
  bool playing = false;
  int emptyRecordingData = 0;
  bool recording = false;
};

// Main initialization and termination.
int32_t OpenALAudioDeviceModule::Init() {
  if (webrtc::AudioDeviceModuleImpl::Init() != 0) {
    return -1;
  }

  if (_initialized) {
    return 0;
  }
  alcSetThreadContext =
      (ALCSETTHREADCONTEXT)alcGetProcAddress(nullptr, "alcSetThreadContext");
  if (!alcSetThreadContext) {
    return -1;
  }
  alEventCallbackSOFT =
      (ALEVENTCALLBACKSOFT)alcGetProcAddress(nullptr, "alEventCallbackSOFT");

  alGetSourcei64vSOFT =
      (ALGETSOURCEI64VSOFT)alcGetProcAddress(nullptr, "alGetSourcei64vSOFT");

  alcGetInteger64vSOFT =
      (ALCGETINTEGER64VSOFT)alcGetProcAddress(nullptr, "alcGetInteger64vSOFT");

#define RESOLVE_ENUM(ENUM) k##ENUM = alcGetEnumValue(nullptr, #ENUM)
  RESOLVE_ENUM(AL_EVENT_CALLBACK_FUNCTION_SOFT);
  RESOLVE_ENUM(AL_EVENT_CALLBACK_FUNCTION_SOFT);
  RESOLVE_ENUM(AL_EVENT_CALLBACK_USER_PARAM_SOFT);
  RESOLVE_ENUM(AL_EVENT_TYPE_BUFFER_COMPLETED_SOFT);
  RESOLVE_ENUM(AL_EVENT_TYPE_SOURCE_STATE_CHANGED_SOFT);
  RESOLVE_ENUM(AL_EVENT_TYPE_DISCONNECTED_SOFT);
  RESOLVE_ENUM(AL_SAMPLE_OFFSET_CLOCK_SOFT);
  RESOLVE_ENUM(AL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT);
  RESOLVE_ENUM(ALC_DEVICE_LATENCY_SOFT);
#undef RESOLVE_ENUM

  _initialized = true;

  return 0;
};

OpenALAudioDeviceModule::~OpenALAudioDeviceModule() {}

rtc::scoped_refptr<OpenALAudioDeviceModule> OpenALAudioDeviceModule::Create(
    AudioLayer audio_layer,
    webrtc::TaskQueueFactory* task_queue_factory) {
  return OpenALAudioDeviceModule::CreateForTest(audio_layer, task_queue_factory);
}

rtc::scoped_refptr<OpenALAudioDeviceModule> OpenALAudioDeviceModule::CreateForTest(
    AudioLayer audio_layer,
    webrtc::TaskQueueFactory* task_queue_factory) {
  // The "AudioDeviceModule::kWindowsCoreAudio2" audio layer has its own
  // dedicated factory method which should be used instead.
  if (audio_layer == AudioDeviceModule::kWindowsCoreAudio2) {
    return nullptr;
  }

  // Create the generic reference counted (platform independent) implementation.
  auto audio_device =
      rtc::make_ref_counted<OpenALAudioDeviceModule>(audio_layer,
                                                     task_queue_factory);

  // Ensure that the current platform is supported.
  if (audio_device->CheckPlatform() == -1) {
    return nullptr;
  }

  // Create the platform-dependent implementation.
  if (audio_device->CreatePlatformSpecificObjects() == -1) {
    return nullptr;
  }

  // Ensure that the generic audio buffer can communicate with the platform
  // specific parts.
  if (audio_device->AttachAudioBuffer() == -1) {
    return nullptr;
  }

  return audio_device;
}

OpenALAudioDeviceModule::OpenALAudioDeviceModule(AudioLayer audio_layer,
                                   webrtc::TaskQueueFactory* task_queue_factory)
    : webrtc::AudioDeviceModuleImpl(audio_layer, task_queue_factory) {
  GetAudioDeviceBuffer()->SetPlayoutSampleRate(kPlayoutFrequency);
  GetAudioDeviceBuffer()->SetPlayoutChannels(_playoutChannels);
}

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

int DevicesCount(ALCenum specifier) {
  auto result = 0;
  EnumerateDevices(specifier, [&](const char* device) { ++result; });

  return result;
}

std::string GetDefaultDeviceId(ALCenum specifier) {
  const auto device = alcGetString(nullptr, specifier);
  return device ? std::string(device) : std::string();
}

int DeviceName(ALCenum specifier,
               int index,
               std::string* name,
               std::string* guid) {
  EnumerateDevices(specifier, [&](const char* device_name_str) {
    if (index < 0) {
      return;
    } else if (index > 0) {
      --index;
      return;
    }

    auto device_name = std::string(device_name_str);
    if (name) {
      if (guid) {
        *guid = device_name;
      }
      const auto prefix = std::string("OpenAL Soft on ");
      if (device_name.rfind(prefix, 0) == 0) {
        device_name = device_name.substr(prefix.size());
      }
      *name = std::move(device_name);
    } else if (guid) {
      *guid = std::move(device_name);
    }
    index = -1;
  });

  return (index > 0) ? -1 : 0;
}

void SetStringToArray(const std::string& string, char* array, int size) {
  const auto length = std::min(int(string.size()), size - 1);
  if (length > 0) {
    memcpy(array, string.data(), length);
  }
  array[length] = 0;
}

int DeviceName(ALCenum specifier,
               int index,
               char name[webrtc::kAdmMaxDeviceNameSize],
               char guid[webrtc::kAdmMaxGuidSize]) {
  auto sname = std::string();
  auto sguid = std::string();

  const auto result = DeviceName(specifier, index, &sname, &sguid);
  if (result) {
    return result;
  }

  SetStringToArray(sname, name, webrtc::kAdmMaxDeviceNameSize);
  SetStringToArray(sguid, guid, webrtc::kAdmMaxGuidSize);

  return 0;
}

int32_t OpenALAudioDeviceModule::SetPlayoutDevice(uint16_t index) {
  const auto result =
      DeviceName(ALC_ALL_DEVICES_SPECIFIER, index, nullptr, &_playoutDeviceId);

  return result ? result : restartPlayout();
}

int32_t OpenALAudioDeviceModule::SetPlayoutDevice(WindowsDeviceType device) {
  _playoutDeviceId = GetDefaultDeviceId(ALC_DEFAULT_DEVICE_SPECIFIER);

  return _playoutDeviceId.empty() ? -1 : restartPlayout();
}

int OpenALAudioDeviceModule::restartPlayout() {
  if (!_data || !_data->playing) {
    return 0;
  }
  stopPlayingOnThread();
  closePlayoutDevice();
  if (!validatePlayoutDeviceId()) {
    _data->_playoutThread->BlockingCall([this] {
      _data->playing = true;
      _playoutFailed = true;
    });
    return 0;
  }
  _playoutFailed = false;
  openPlayoutDevice();
  startPlayingOnThread();

  return 0;
}

int16_t OpenALAudioDeviceModule::PlayoutDevices() {
  return DevicesCount(ALC_ALL_DEVICES_SPECIFIER);
}

int32_t OpenALAudioDeviceModule::PlayoutDeviceName(
    uint16_t index,
    char name[webrtc::kAdmMaxDeviceNameSize],
    char guid[webrtc::kAdmMaxGuidSize]) {
  return DeviceName(ALC_ALL_DEVICES_SPECIFIER, index, name, guid);
}

int32_t OpenALAudioDeviceModule::InitPlayout() {
  if (!_initialized) {
    return -1;
  } else if (_playoutInitialized) {
    return 0;
  }
  _playoutInitialized = true;

  ensureThreadStarted();

  return 0;
}

bool OpenALAudioDeviceModule::PlayoutIsInitialized() const {
  return _playoutInitialized;
}

int32_t OpenALAudioDeviceModule::StartPlayout() {
  std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

  if (!_playoutInitialized) {
    return -1;
  } else if (Playing()) {
    return 0;
  }

  if (_playoutFailed) {
    _playoutFailed = false;
  }

  _data->_playoutThread->Start();
  openPlayoutDevice();
  GetAudioDeviceBuffer()->SetPlayoutSampleRate(kPlayoutFrequency);
  GetAudioDeviceBuffer()->SetPlayoutChannels(_playoutChannels);
  GetAudioDeviceBuffer()->StartPlayout();
  startPlayingOnThread();

  return 0;
}

int32_t OpenALAudioDeviceModule::StopPlayout() {
  if (_data) {
    stopPlayingOnThread();
    GetAudioDeviceBuffer()->StopPlayout();
    _data->_playoutThread->Stop();
    if (!_data->recording) {
      _data = nullptr;
    }
  }
  closePlayoutDevice();
  _playoutInitialized = false;

  return 0;
}

bool OpenALAudioDeviceModule::Playing() const {
  return _data && _data->playing;
}

int32_t OpenALAudioDeviceModule::InitSpeaker() {
  _speakerInitialized = true;
  return 0;
}

bool OpenALAudioDeviceModule::SpeakerIsInitialized() const {
  return _speakerInitialized;
}

int32_t OpenALAudioDeviceModule::StereoPlayoutIsAvailable(bool* available) const {
  if (available) {
    *available = true;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SetStereoPlayout(bool enable) {
  if (Playing()) {
    return -1;
  }
  _playoutChannels = enable ? 2 : 1;
  return 0;
}

int32_t OpenALAudioDeviceModule::StereoPlayout(bool* enabled) const {
  if (enabled) {
    *enabled = (_playoutChannels == 2);
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::PlayoutDelay(uint16_t* delayMS) const {
  if (delayMS) {
    *delayMS = 0;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SpeakerVolumeIsAvailable(bool* available) {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SetSpeakerVolume(uint32_t volume) {
  return -1;
}

int32_t OpenALAudioDeviceModule::SpeakerVolume(uint32_t* volume) const {
  return -1;
}

int32_t OpenALAudioDeviceModule::MaxSpeakerVolume(uint32_t* maxVolume) const {
  return -1;
}

int32_t OpenALAudioDeviceModule::MinSpeakerVolume(uint32_t* minVolume) const {
  return -1;
}

int32_t OpenALAudioDeviceModule::SpeakerMuteIsAvailable(bool* available) {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SetSpeakerMute(bool enable) {
  return -1;
}

int32_t OpenALAudioDeviceModule::SpeakerMute(bool* enabled) const {
  if (enabled) {
    *enabled = false;
  }
  return 0;
}

void OpenALAudioDeviceModule::openPlayoutDevice() {
  std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

  if (_playoutDevice || _playoutFailed) {
    return;
  }
  _playoutDevice = alcOpenDevice(
      _playoutDeviceId.empty() ? nullptr : _playoutDeviceId.c_str());
  if (!_playoutDevice) {
    RTC_LOG(LS_ERROR) << "OpenAL Device open failed, deviceID: '"
                      << _playoutDeviceId << "'";
    _playoutFailed = true;
    return;
  }
  _playoutContext = alcCreateContext(_playoutDevice, nullptr);
  if (!_playoutContext) {
    RTC_LOG(LS_ERROR) << "OpenAL Context create failed.";
    _playoutFailed = true;
    closePlayoutDevice();
    return;
  }

  _data->_playoutThread->PostTask(
      [=]() { alcSetThreadContext(_playoutContext); });
}

void OpenALAudioDeviceModule::ensureThreadStarted() {
  if (_data) {
    return;
  }

  _thread = rtc::Thread::Current();
  if (_thread && !_thread->IsOwned()) {
    _thread->UnwrapCurrent();
    _thread = nullptr;
  }

  _data = std::make_unique<Data>();
  processPlayoutQueued();
  processRecordingQueued();
}

void OpenALAudioDeviceModule::processPlayoutQueued() {
  _data->_playoutThread->PostDelayedHighPrecisionTask(
      [=] {
        std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

        processPlayout();
        processPlayoutQueued();
      },
      webrtc::TimeDelta::Millis(10));
}

bool CheckDeviceFailed(ALCdevice* device) {
  if (auto code = alcGetError(device); code != ALC_NO_ERROR) {
    RTC_LOG(LS_ERROR) << "OpenAL Error " << code << ": "
                      << (const char*)alcGetString(device, code);
    return true;
  }

  return false;
}

bool OpenALAudioDeviceModule::clearProcessedBuffer() {
  auto processed = ALint(0);
  alGetSourcei(_data->source, AL_BUFFERS_PROCESSED, &processed);
  if (processed < 1) {
    return false;
  }
  auto buffer = ALuint(0);
  alSourceUnqueueBuffers(_data->source, 1, &buffer);
  for (auto i = 0; i != int(_data->buffers.size()); ++i) {
    if (_data->buffers[i] == buffer) {
      _data->queuedBuffers[i] = false;
      --_data->queuedBuffersCount;
      return true;
    }
  }
}

void OpenALAudioDeviceModule::clearProcessedBuffers() {
  while (true) {
    if (!clearProcessedBuffer()) {
      break;
    }
  }
}

void OpenALAudioDeviceModule::unqueueAllBuffers() {
  alSourcei(_data->source, AL_BUFFER, AL_NONE);
  std::fill(_data->queuedBuffers.begin(), _data->queuedBuffers.end(), false);
  _data->queuedBuffersCount = 0;
}

int32_t OpenALAudioDeviceModule::RegisterAudioCallback(
    webrtc::AudioTransport* audioCallback) {
  return GetAudioDeviceBuffer()->RegisterAudioCallback(audioCallback);
}

bool OpenALAudioDeviceModule::processPlayout() {
  const auto playing = [&] {
    auto state = ALint(AL_INITIAL);
    alGetSourcei(_data->source, AL_SOURCE_STATE, &state);
    return (state == AL_PLAYING);
  };
  const auto wasPlaying = playing();

  if (wasPlaying) {
    clearProcessedBuffers();
  } else {
    unqueueAllBuffers();
  }

  const auto wereQueued = _data->queuedBuffers;
  while (_data->queuedBuffersCount < kBuffersKeepReadyCount) {
    const auto available =
        GetAudioDeviceBuffer()->RequestPlayoutData(kPlayoutPart);
    if (available == kPlayoutPart) {
      GetAudioDeviceBuffer()->GetPlayoutData(_data->playoutSamples->data());
    } else {
      std::fill(_data->playoutSamples->begin(), _data->playoutSamples->end(),
                0);
      break;
    }

    _playoutLatency = countExactQueuedMsForLatency(
        std::chrono::steady_clock::now(), wasPlaying);

    const auto i = std::find(std::begin(_data->queuedBuffers),
                             std::end(_data->queuedBuffers), false);
    const auto index = int(i - std::begin(_data->queuedBuffers));
    alBufferData(
        _data->buffers[index],
        (_playoutChannels == 2) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16,
        _data->playoutSamples->data(), _data->playoutSamples->size(),
        kPlayoutFrequency);

    _data->queuedBuffers[index] = true;
    ++_data->queuedBuffersCount;
    if (wasPlaying) {
      alSourceQueueBuffers(_data->source, 1, _data->buffers.data() + index);
    }
  }
  if (!_data->queuedBuffersCount) {
    return false;
  }
  if (!playing()) {
    if (wasPlaying) {
      // While we were queueing buffers the source stopped. Now we can't unqueue
      // only old buffers, so we unqueue all of them and then re-queue the ones
      // we queued right now.
      unqueueAllBuffers();
      for (auto i = 0; i != int(_data->buffers.size()); ++i) {
        if (!wereQueued[i] && _data->queuedBuffers[i]) {
          alSourceQueueBuffers(_data->source, 1, _data->buffers.data() + i);
        }
      }
    } else {
      // We were not playing and had no buffers, so queue them all at once.
      alSourceQueueBuffers(_data->source, _data->queuedBuffersCount,
                           _data->buffers.data());
    }
    alSourcePlay(_data->source);
  }

  if (CheckDeviceFailed(_playoutDevice)) {
    _playoutFailed = true;
  }

  return true;
}

void OpenALAudioDeviceModule::closePlayoutDevice() {
  if (_playoutContext) {
    alcDestroyContext(_playoutContext);
    _playoutContext = nullptr;
  }
  if (_playoutDevice) {
    alcCloseDevice(_playoutDevice);
    _playoutDevice = nullptr;
  }
}

bool OpenALAudioDeviceModule::validatePlayoutDeviceId() {
  auto valid = false;
  EnumerateDevices(ALC_ALL_DEVICES_SPECIFIER, [&](const char* device) {
    if (!valid && _playoutDeviceId == std::string(device)) {
      valid = true;
    }
  });
  if (valid) {
    return true;
  }
  const auto defaultDeviceId = GetDefaultDeviceId(ALC_DEFAULT_DEVICE_SPECIFIER);
  if (!defaultDeviceId.empty()) {
    _playoutDeviceId = defaultDeviceId;

    return true;
  }

  RTC_LOG(LS_ERROR) << "Could not find any OpenAL devices.";
  return false;
}

void OpenALAudioDeviceModule::startPlayingOnThread() {
  _data->_playoutThread->PostTask([this] {
    std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

    _data->playing = true;
    if (_playoutFailed) {
      return;
    }

    ALuint source = 0;
    alGenSources(1, &source);
    if (source) {
      alSourcef(source, AL_PITCH, 1.f);
      alSource3f(source, AL_POSITION, 0, 0, 0);
      alSource3f(source, AL_VELOCITY, 0, 0, 0);
      alSourcei(source, AL_LOOPING, 0);
      alSourcei(source, AL_SOURCE_RELATIVE, 1);
      alSourcei(source, AL_ROLLOFF_FACTOR, 0);
      if (alIsExtensionPresent("AL_SOFT_direct_channels_remix")) {
        alSourcei(source, alGetEnumValue("AL_DIRECT_CHANNELS_SOFT"),
                  alGetEnumValue("AL_REMIX_UNMATCHED_SOFT"));
      }
      _data->source = source;
      alGenBuffers(_data->buffers.size(), _data->buffers.data());

      _data->exactDeviceTimeCounter = 0;
      _data->lastExactDeviceTime = 0;
      _data->lastExactDeviceTimeWhen = 0;

      const auto bufferSize = kPlayoutPart * sizeof(int16_t) * _playoutChannels;

      ensureThreadStarted();
    }
  });
}

void OpenALAudioDeviceModule::stopPlayingOnThread() {
  {
    std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

    if (!_data->playing) {
      _data->_playoutThread->PostTask([this] {
        std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

        alcSetThreadContext(nullptr);
      });
      return;
    }
    _data->playing = false;
    if (_playoutFailed) {
      _data->_playoutThread->PostTask([this] {
        std::lock_guard<std::recursive_mutex> lk(_playout_mutex);

        alcSetThreadContext(nullptr);
      });
      return;
    }
  }
  if (_data->source) {
    alSourceStop(_data->source);
    unqueueAllBuffers();
    alDeleteBuffers(_data->buffers.size(), _data->buffers.data());
    alDeleteSources(1, &_data->source);
    _data->source = 0;
    std::fill(_data->buffers.begin(), _data->buffers.end(), ALuint(0));
  }
  _data->_playoutThread->PostTask([this] { alcSetThreadContext(nullptr); });
  _data->_playoutThread->Stop();
}

void OpenALAudioDeviceModule::closeRecordingDevice() {
  std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

  if (_recordingDevice) {
    alcCaptureCloseDevice(_recordingDevice);
    _recordingDevice = nullptr;
  }
}

void OpenALAudioDeviceModule::stopCaptureOnThread() {
  {
    std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

    if (!_data->recording) {
      return;
    }

    _data->_recordingThread->PostTask([=]() {
      std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

      _data->recording = false;
      if (_recordingFailed) {
        return;
      }
      if (_recordingDevice) {
        alcCaptureStop(_recordingDevice);
      }
    });
  }
  _data->_recordingThread->Stop();
}

void OpenALAudioDeviceModule::processRecordingQueued() {
  _data->_recordingThread->PostDelayedHighPrecisionTask(
      [=] {
        std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

        if (_data->recording && !_recordingFailed) {
          for (auto first = true; processRecordedPart(first); first = false) {}
          processRecordingQueued();
        }
      },
      webrtc::TimeDelta::Millis(kProcessInterval));
}

void OpenALAudioDeviceModule::startCaptureOnThread() {
  _data->_recordingThread->Start();
  _data->_recordingThread->PostTask([=]() {
    std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

    _data->recording = true;
    if (_recordingFailed) {
      return;
    }

    alcCaptureStart(_recordingDevice);

    if (CheckDeviceFailed(_recordingDevice)) {
      _recordingFailed = true;
      return;
    }

    processRecordingQueued();

    if (_recordingFailed) {
      closeRecordingDevice();
    }
  });
}

void OpenALAudioDeviceModule::openRecordingDevice() {
  if (_recordingDevice || _recordingFailed) {
    return;
  }

  _recordingDevice = alcCaptureOpenDevice(
      _recordingDeviceId.empty() ? nullptr : _recordingDeviceId.c_str(),
      kRecordingFrequency, AL_FORMAT_MONO16, kRecordingFrequency);
  if (!_recordingDevice) {
    _recordingFailed = true;
    return;
  }
}

int16_t OpenALAudioDeviceModule::RecordingDevices() {
  return DevicesCount(ALC_CAPTURE_DEVICE_SPECIFIER);
}

int32_t OpenALAudioDeviceModule::SetRecordingDevice(uint16_t index) {
  const auto result = DeviceName(ALC_CAPTURE_DEVICE_SPECIFIER, index, nullptr,
                                 &_recordingDeviceId);
  return result ? result : restartRecording();
}

int32_t OpenALAudioDeviceModule::SetRecordingDevice(WindowsDeviceType /*device*/) {
  _recordingDeviceId = GetDefaultDeviceId(ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
  return _recordingDeviceId.empty() ? -1 : restartRecording();
}

int32_t OpenALAudioDeviceModule::RecordingDeviceName(
    uint16_t index,
    char name[webrtc::kAdmMaxDeviceNameSize],
    char guid[webrtc::kAdmMaxGuidSize]) {
  return DeviceName(ALC_CAPTURE_DEVICE_SPECIFIER, index, name, guid);
}

int32_t OpenALAudioDeviceModule::RecordingIsAvailable(bool* available) {
  if (available) {
    *available = true;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::InitRecording() {
  if (!_initialized) {
    return -1;
  } else if (_recordingInitialized) {
    return 0;
  }
  _recordingInitialized = true;
  ensureThreadStarted();
  openRecordingDevice();
  GetAudioDeviceBuffer()->SetRecordingSampleRate(kRecordingFrequency);
  GetAudioDeviceBuffer()->SetRecordingChannels(kRecordingChannels);
  return 0;
}

bool OpenALAudioDeviceModule::RecordingIsInitialized() const {
  return _recordingInitialized;
}

int32_t OpenALAudioDeviceModule::StartRecording() {
  if (!_recordingInitialized) {
    return -1;
  } else if (_data && _data->recording) {
    return 0;
  }

  if (_recordingFailed) {
    _recordingFailed = false;
    openRecordingDevice();
  }

  GetAudioDeviceBuffer()->StartRecording();
  startCaptureOnThread();

  return 0;
}

int32_t OpenALAudioDeviceModule::StopRecording() {
  if (_data) {
    stopCaptureOnThread();
    GetAudioDeviceBuffer()->StopRecording();
    if (!_data->playing) {
      _data->_recordingThread->Stop();
      _data = nullptr;
    }
  }

  closeRecordingDevice();
  _recordingInitialized = false;

  return 0;
}

bool OpenALAudioDeviceModule::Recording() const {
  return _data && _data->recording;
}

int32_t OpenALAudioDeviceModule::InitMicrophone() {
  _microphoneInitialized = true;
  return 0;
}

bool OpenALAudioDeviceModule::MicrophoneIsInitialized() const {
  return _microphoneInitialized;
}

int32_t OpenALAudioDeviceModule::MicrophoneVolumeIsAvailable(bool* available) {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SetMicrophoneVolume(uint32_t volume) {
  return -1;
}

int32_t OpenALAudioDeviceModule::MicrophoneVolume(uint32_t* volume) const {
  return -1;
}

int32_t OpenALAudioDeviceModule::MaxMicrophoneVolume(uint32_t* maxVolume) const {
  return -1;
}

int32_t OpenALAudioDeviceModule::MinMicrophoneVolume(uint32_t* minVolume) const {
  return -1;
}

int32_t OpenALAudioDeviceModule::MicrophoneMuteIsAvailable(bool* available) {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SetMicrophoneMute(bool enable) {
  return -1;
}

int32_t OpenALAudioDeviceModule::MicrophoneMute(bool* enabled) const {
  if (enabled) {
    *enabled = false;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::StereoRecordingIsAvailable(bool* available) const {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t OpenALAudioDeviceModule::SetStereoRecording(bool enable) {
  return -1;
}

int32_t OpenALAudioDeviceModule::StereoRecording(bool* enabled) const {
  if (enabled) {
    *enabled = false;
  }
  return 0;
}

bool OpenALAudioDeviceModule::processRecordedPart(bool firstInCycle) {
  auto samples = ALint();
  alcGetIntegerv(_recordingDevice, ALC_CAPTURE_SAMPLES, 1, &samples);

  if (CheckDeviceFailed(_recordingDevice)) {
    _recordingFailed = true;
    return false;
  }

  if (samples <= 0) {
    if (firstInCycle) {
      ++_data->emptyRecordingData;
      if (_data->emptyRecordingData == kRestartAfterEmptyData) {
        restartRecording();
      }
    }
    return false;
  } else if (samples < kRecordingPart) {
    // Not enough data for 10 milliseconds.
    return false;
  }

  _recordingLatency = queryRecordingLatencyMs();

  _data->emptyRecordingData = 0;
  alcCaptureSamples(_recordingDevice, _data->recordedSamples->data(),
                    kRecordingPart);

  if (CheckDeviceFailed(_recordingDevice)) {
    restartRecording();
    return false;
  }

  GetAudioDeviceBuffer()->SetRecordedBuffer(_data->recordedSamples->data(),
                                            kRecordingPart);
  GetAudioDeviceBuffer()->SetVQEData(_playoutLatency.count(),
                                     _recordingLatency.count());
  GetAudioDeviceBuffer()->DeliverRecordedData();

  return true;
}

std::chrono::milliseconds OpenALAudioDeviceModule::countExactQueuedMsForLatency(
    std::chrono::time_point<std::chrono::steady_clock> now,
    bool playing) {
  auto now_nanos = now.time_since_epoch().count();
  auto values = std::array<AL_INT64_TYPE, kALMaxValues>{};
  auto& sampleOffset = values[0];
  auto& clockTime = values[1];
  auto& exactDeviceTime = values[2];
  const auto countExact = alGetSourcei64vSOFT && kAL_SAMPLE_OFFSET_CLOCK_SOFT &&
                          kAL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT;
  if (countExact) {
    if (!_data->lastExactDeviceTimeWhen ||
        !(++_data->exactDeviceTimeCounter % kQueryExactTimeEach)) {
      alGetSourcei64vSOFT(_data->source, kAL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT,
                          values.data());
      _data->lastExactDeviceTime = exactDeviceTime;
      _data->lastExactDeviceTimeWhen = now_nanos;
    } else {
      alGetSourcei64vSOFT(_data->source, kAL_SAMPLE_OFFSET_CLOCK_SOFT,
                          values.data());

      // `exactDeviceTime` is in nanoseconds.
      exactDeviceTime =
          _data->lastExactDeviceTime +
          (now_nanos - _data->lastExactDeviceTimeWhen) * 1'000'000;
    }
  } else {
    auto offset = ALint(0);
    alGetSourcei(_data->source, AL_SAMPLE_OFFSET, &offset);
    sampleOffset = (AL_INT64_TYPE(offset) << 32);
  }

  const auto queuedSamples =
      (AL_INT64_TYPE(_data->queuedBuffersCount * kPlayoutPart) << 32);
  const auto processedInOpenAL = playing ? sampleOffset : queuedSamples;
  const auto secondsQueuedInDevice =
      std::max(clockTime - exactDeviceTime, AL_INT64_TYPE(0)) / 1'000'000'000.;
  const auto secondsQueuedInOpenAL =
      (double((queuedSamples - processedInOpenAL) >> (32 - 10)) /
       double(kPlayoutFrequency * (1 << 10)));

  const auto queuedTotal = std::chrono::duration<double>(
      (secondsQueuedInDevice + secondsQueuedInOpenAL) * 1'000);

  auto res =
      countExact ? queuedTotal : std::max(queuedTotal, kDefaultPlayoutLatency);

  return std::chrono::duration_cast<std::chrono::milliseconds>(res);
}

std::chrono::milliseconds OpenALAudioDeviceModule::queryRecordingLatencyMs() {
#ifdef WEBRTC_WIN
  if (kALC_DEVICE_LATENCY_SOFT &&
      kAL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT) {  // Check patched build.
    auto latency = AL_INT64_TYPE();
    alcGetInteger64vSOFT(_recordingDevice, kALC_DEVICE_LATENCY_SOFT, 1,
                         &latency);
    return std::chrono::milliseconds(latency / 1'000'000);
  }
#endif  // WEBRTC_WIN
  return kDefaultRecordingLatency;
}

bool OpenALAudioDeviceModule::validateRecordingDeviceId() {
  auto valid = false;
  EnumerateDevices(ALC_CAPTURE_DEVICE_SPECIFIER, [&](const char* device) {
    if (!valid && _recordingDeviceId == std::string(device)) {
      valid = true;
    }
  });
  if (valid) {
    return true;
  }
  const auto defaultDeviceId =
      GetDefaultDeviceId(ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
  if (!defaultDeviceId.empty()) {
    _recordingDeviceId = defaultDeviceId;
    return true;
  }
  return false;
}

int OpenALAudioDeviceModule::restartRecording() {
  std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

  if (!_data || !_data->recording) {
    return 0;
  }

  stopCaptureOnThread();
  closeRecordingDevice();

  if (!validateRecordingDeviceId()) {
    _data->_recordingThread->PostTask([=]() {
      std::lock_guard<std::recursive_mutex> lk(_recording_mutex);

      _data->recording = true;
      _recordingFailed = true;
    });
    return 0;
  }

  _recordingFailed = false;
  openRecordingDevice();
  startCaptureOnThread();

  return 0;
}
