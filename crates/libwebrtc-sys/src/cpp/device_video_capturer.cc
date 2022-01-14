#include <memory>
#include <stdint.h>

#include "device_video_capturer.h"
#include <modules/video_capture/video_capture_factory.h>
#include <rtc_base/checks.h>
#include <rtc_base/logging.h>

// MediaCodec wants resolution to be divisible by 2.
const int kRequiredResolutionAlignment = 2;

DeviceVideoCapturer::DeviceVideoCapturer()
    : AdaptedVideoTrackSource(kRequiredResolutionAlignment) {}

DeviceVideoCapturer::~DeviceVideoCapturer() {
  Destroy();
}

// Creates a new `DeviceVideoCapturer`.
rtc::scoped_refptr<DeviceVideoCapturer> DeviceVideoCapturer::Create(
    size_t width,
    size_t height,
    size_t max_fps,
    uint32_t device_index) {
  rtc::scoped_refptr<DeviceVideoCapturer> capturer(
      new rtc::RefCountedObject<DeviceVideoCapturer>());

  if (!capturer->Init(width, height, max_fps, device_index)) {
    RTC_LOG(LS_ERROR) << "Failed to create DeviceVideoCapturer(w = " << width
                      << ", h = " << height << ", fps = " << max_fps
                      << ")";
    return nullptr;
  }

  return capturer;
}

// Initializes current `DeviceVideoCapturer`.
//
// Creates an underlying `VideoCaptureModule` and starts capturing media with
// specified constraints.
bool DeviceVideoCapturer::Init(size_t width,
                               size_t height,
                               size_t max_fps,
                               size_t capture_device_index) {
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> device_info(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  char device_name[256];
  char unique_name[256];
  if (device_info->GetDeviceName(static_cast<uint32_t>(capture_device_index),
                                 device_name, sizeof(device_name), unique_name,
                                 sizeof(unique_name)) != 0) {
    Destroy();
    return false;
  }

  vcm_ = webrtc::VideoCaptureFactory::Create(unique_name);
  if (!vcm_) {
    return false;
  }
  vcm_->RegisterCaptureDataCallback(this);

  device_info->GetCapability(vcm_->CurrentDeviceName(), 0, capability_);
  capability_.width = static_cast<int32_t>(width);
  capability_.height = static_cast<int32_t>(height);
  capability_.maxFPS = static_cast<int32_t>(max_fps);
  capability_.videoType = webrtc::VideoType::kI420;

  if (vcm_->StartCapture(capability_) != 0) {
    Destroy();
    return false;
  }

  RTC_CHECK(vcm_->CaptureStarted());

  return true;
}

// Frees an underlying `VideoCaptureModule`.
void DeviceVideoCapturer::Destroy() {
  if (!vcm_)
    return;

  vcm_->StopCapture();
  vcm_->DeRegisterCaptureDataCallback();
  vcm_ = nullptr;
}

// Propagates a `VideoFrame` to the `AdaptedVideoTrackSource::OnFrame()`.
void DeviceVideoCapturer::OnFrame(const webrtc::VideoFrame& frame) {
  AdaptedVideoTrackSource::OnFrame(frame);
}

// Returns `false`.
bool DeviceVideoCapturer::is_screencast() const {
  return false;
}

// Returns `false`.
absl::optional<bool> DeviceVideoCapturer::needs_denoising() const {
  return false;
}

// Returns `SourceState::kLive`.
webrtc::MediaSourceInterface::SourceState DeviceVideoCapturer::state()
const {
  return SourceState::kLive;
}

// Returns `false`.
bool DeviceVideoCapturer::remote() const {
  return false;
}
