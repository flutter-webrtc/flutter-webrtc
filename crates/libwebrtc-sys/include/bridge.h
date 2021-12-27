#pragma once

#include <memory>
#include <string>
#include <iostream>

#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "rust/cxx.h"

namespace bridge {

// Smart pointer designed to wrap WebRTC's `rtc::scoped_refptr`.
//
// `rtc::scoped_refptr` can't be used with `std::uniqueptr` since it has private
// destructor. `rc` unwraps raw pointer from the provided `rtc::scoped_refptr`
// and calls `Release()` in its destructor therefore this allows wrapping `rc`
// into a `std::uniqueptr`.
template<class T>
class rc {
 public:
  typedef T element_type;

  // Unwraps the actual pointer from the provided `rtc::scoped_refptr`.
  rc(rtc::scoped_refptr<T> p) : ptr_(p.release()) {}

  // Calls `RefCountInterface::Release()` on the underlying pointer.
  ~rc() {
    ptr_->Release();
  }

  // Returns a pointer to the managed object.
  T *ptr() const {
    return ptr_;
  }

  // Returns a pointer to the managed object.
  T *operator->() const {
    return ptr_;
  }

 protected:
  // Pointer to the managed object.
  T *ptr_;
};

using TaskQueueFactory = webrtc::TaskQueueFactory;
using AudioDeviceModule = rc<webrtc::AudioDeviceModule>;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;

// Creates a new `AudioDeviceModule` for the given `AudioLayer`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory &task_queue_factory
);

// Initializes the native audio parts required for each platform.
int32_t init_audio_device_module(const AudioDeviceModule &audio_device_module);

// Returns count of the available playout audio devices.
int16_t playout_devices(const AudioDeviceModule &audio_device_module);

// Returns count of the available recording audio devices.
int16_t recording_devices(const AudioDeviceModule &audio_device_module);

// Obtains information regarding the specified audio playout device.
int32_t playout_device_name(
    const AudioDeviceModule &audio_device_module,
    int16_t index,
    rust::String &name,
    rust::String &guid
);

// Obtains information regarding the specified audio recording device.
int32_t recording_device_name(const AudioDeviceModule &audio_device_module,
                              int16_t index,
                              rust::String &name,
                              rust::String &guid);

// Creates a new `VideoDeviceInfo`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info();

// Obtains information regarding the specified video recording device.
int32_t video_device_name(VideoDeviceInfo &device_info,
                          uint32_t index,
                          rust::String &name,
                          rust::String &guid);

}
