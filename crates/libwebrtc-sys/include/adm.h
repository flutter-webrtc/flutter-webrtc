/*
 * This file is modified version of the one from Desktop App Toolkit, a set of
 * libraries for developing nice desktop applications.
 * https://github.com/desktop-app/lib_webrtc/blob/openal/webrtc/details/webrtc_openal_adm.h
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

#ifndef BRIDGE_ADM_H_
#define BRIDGE_ADM_H_

#define WEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE 1

#include <chrono>
#include <iostream>
#include <memory>
#include <mutex>
#include <unordered_map>

#include <AL/al.h>
#include <AL/alc.h>

#include "api/audio/audio_frame.h"
#include "api/audio/audio_mixer.h"
#include "api/media_stream_interface.h"
#include "api/sequence_checker.h"
#include "api/task_queue/task_queue_factory.h"
#include "libwebrtc-sys/include/audio_device_recorder.h"
#include "libwebrtc-sys/include/local_audio_source.h"
#include "modules/audio_device/audio_device_buffer.h"
#include "modules/audio_device/audio_device_generic.h"
#include "modules/audio_device/audio_device_impl.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/audio_device/include/audio_device_defines.h"
#include "modules/audio_mixer/audio_mixer_impl.h"
#include "rtc_base/event.h"
#include "rtc_base/platform_thread.h"
#include "rtc_base/synchronization/mutex.h"
#include "rtc_base/thread.h"
#include "rtc_base/thread_annotations.h"

#if defined(WEBRTC_USE_X11)
#include <X11/Xlib.h>
#endif

class ExtendedADM : public webrtc::AudioDeviceModule {
 public:
  // Creates a new `bridge::LocalAudioSource` that will record audio from the
  // device with the provided ID.
  virtual rtc::scoped_refptr<bridge::LocalAudioSource> CreateAudioSource(
      uint32_t device_index) = 0;

  // Stops the `bridge::LocalAudioSource` for the provided device ID.
  virtual void DisposeAudioSource(std::string device_id) = 0;
};

class OpenALAudioDeviceModule : public ExtendedADM {
 public:
  ~OpenALAudioDeviceModule() override;

  static rtc::scoped_refptr<OpenALAudioDeviceModule> Create(
      AudioLayer audio_layer,
      webrtc::TaskQueueFactory* task_queue_factory);

  // Main initialization and termination.
  int32_t Init() override;
  int32_t Terminate() override;
  bool Initialized() const override;

  // Creates a new `bridge::LocalAudioSource` that will record audio from the
  // device with the provided ID.
  rtc::scoped_refptr<bridge::LocalAudioSource> CreateAudioSource(
      uint32_t device_index) override;

  // Stops the `bridge::LocalAudioSource` for the provided device ID.
  void DisposeAudioSource(std::string device_id) override;

  // Playout control.
  int16_t PlayoutDevices() override;
  int32_t SetPlayoutDevice(uint16_t index) override;
  int32_t SetPlayoutDevice(WindowsDeviceType device) override;
  int32_t PlayoutDeviceName(uint16_t index,
                            char name[webrtc::kAdmMaxDeviceNameSize],
                            char guid[webrtc::kAdmMaxGuidSize]) override;
  int32_t InitPlayout() override;
  bool PlayoutIsInitialized() const override;
  int32_t StartPlayout() override;
  int32_t StopPlayout() override;
  bool Playing() const override;
  int32_t InitSpeaker() override;
  bool SpeakerIsInitialized() const override;
  int32_t StereoPlayoutIsAvailable(bool* available) const override;
  int32_t SetStereoPlayout(bool enable) override;
  int32_t StereoPlayout(bool* enabled) const override;
  int32_t PlayoutDelay(uint16_t* delayMS) const override;

  int32_t SpeakerVolumeIsAvailable(bool* available) override;
  int32_t SetSpeakerVolume(uint32_t volume) override;
  int32_t SpeakerVolume(uint32_t* volume) const override;
  int32_t MaxSpeakerVolume(uint32_t* maxVolume) const override;
  int32_t MinSpeakerVolume(uint32_t* minVolume) const override;

  int32_t SpeakerMuteIsAvailable(bool* available) override;
  int32_t SetSpeakerMute(bool enable) override;
  int32_t SpeakerMute(bool* enabled) const override;
  int32_t RegisterAudioCallback(webrtc::AudioTransport* audioCallback) override;

  // Capture control.
  int16_t RecordingDevices() override;
  int32_t RecordingDeviceName(uint16_t index,
                              char name[webrtc::kAdmMaxDeviceNameSize],
                              char guid[webrtc::kAdmMaxGuidSize]) override;
  int32_t SetRecordingDevice(uint16_t index) override;
  int32_t SetRecordingDevice(WindowsDeviceType device) override;
  int32_t RecordingIsAvailable(bool* available) override;
  int32_t InitRecording() override;
  bool RecordingIsInitialized() const override;
  int32_t StartRecording() override;
  int32_t StopRecording() override;
  bool Recording() const override;
  int32_t InitMicrophone() override;
  bool MicrophoneIsInitialized() const override;

  int32_t MicrophoneVolumeIsAvailable(bool* available) override;
  int32_t SetMicrophoneVolume(uint32_t volume) override;
  int32_t MicrophoneVolume(uint32_t* volume) const override;
  int32_t MaxMicrophoneVolume(uint32_t* maxVolume) const override;
  int32_t MinMicrophoneVolume(uint32_t* minVolume) const override;

  int32_t MicrophoneMuteIsAvailable(bool* available) override;
  int32_t SetMicrophoneMute(bool enable) override;
  int32_t MicrophoneMute(bool* enabled) const override;

  int32_t StereoRecordingIsAvailable(bool* available) const override;
  int32_t SetStereoRecording(bool enable) override;
  int32_t StereoRecording(bool* enabled) const override;

  // ----------------

  // Retrieves the currently utilized audio layer.
  int32_t ActiveAudioLayer(AudioLayer* audioLayer) const override;

  int32_t PlayoutIsAvailable(bool* available) override;

  bool BuiltInAECIsAvailable() const override;
  int32_t EnableBuiltInAEC(bool enable) override;
  bool BuiltInAGCIsAvailable() const override;
  int32_t EnableBuiltInAGC(bool enable) override;
  bool BuiltInNSIsAvailable() const override;
  int32_t EnableBuiltInNS(bool enable) override;

  int32_t GetPlayoutUnderrunCount() const override { return -1; }

  virtual absl::optional<Stats> GetStats() const { return absl::nullopt; }

#if defined(WEBRTC_IOS)
  virtual int GetPlayoutAudioParameters(AudioParameters* params) const {
    return absl::nullopt;
  }
  virtual int GetRecordAudioParameters(AudioParameters* params) const {
    return absl::nullopt;
  }
#endif  // WEBRTC_IOS

  // ----------------
 private:
  struct Data;

  bool _initialized = false;
  std::unique_ptr<Data> _data;

  bool quit = false;

 private:
  int restartPlayout();
  void openPlayoutDevice();

  void startPlayingOnThread();
  void ensureThreadStarted();
  void closePlayoutDevice();
  bool validatePlayoutDeviceId();

  void clearProcessedBuffers();
  bool clearProcessedBuffer();

  void unqueueAllBuffers();

  bool processPlayout();

  // NB! closePlayoutDevice should be called after this, so that next time
  // we start playing, we set the thread local context and event callback.
  void stopPlayingOnThread();

  void processPlayoutQueued();

  void startCaptureOnThread();
  void stopCaptureOnThread();
  std::chrono::milliseconds countExactQueuedMsForLatency(
      std::chrono::time_point<std::chrono::steady_clock> now,
      bool playing);
  void processRecordingQueued();

  std::unique_ptr<webrtc::AudioDeviceBuffer> audio_device_buffer_ = nullptr;

  std::recursive_mutex _recording_mutex;
  bool _recordingInitialized = false;
  bool _microphoneInitialized = false;
  std::unordered_map<std::string, std::unique_ptr<AudioDeviceRecorder>>
      _recorders;

  std::recursive_mutex _playout_mutex;
  std::string _playoutDeviceId;
  bool _playoutInitialized = false;
  bool _speakerInitialized = false;
  bool _playoutFailed = false;
  ALCdevice* _playoutDevice = nullptr;
  std::chrono::milliseconds _playoutLatency = std::chrono::milliseconds(0);
  ALCcontext* _playoutContext = nullptr;
  int _playoutChannels = 2;
};

#endif  // BRIDGE_ADM_H_
