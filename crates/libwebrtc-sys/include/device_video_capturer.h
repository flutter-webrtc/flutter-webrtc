#ifndef DEVICE_VIDEO_CAPTURER_H_
#define DEVICE_VIDEO_CAPTURER_H_

#include <stddef.h>
#include <memory>
#include <vector>

#include <api/scoped_refptr.h>
#include <media/base/adapted_video_track_source.h>
#include <media/base/video_adapter.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/ref_counted_object.h>
#include <rtc_base/timestamp_aligner.h>

// `VideoTrackSourceInterface` that captures frames from a local video input
// device.
class DeviceVideoCapturer : public rtc::AdaptedVideoTrackSource,
                            public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Creates a new `DeviceVideoCapturer`.
  static rtc::scoped_refptr<DeviceVideoCapturer> Create(size_t width,
                                                        size_t height,
                                                        size_t target_fps,
                                                        uint32_t device_index);

  // Indicates that parameters suitable for screencast should be automatically
  // applied to RtpSenders.
  bool is_screencast() const override;

  // Indicates that the encoder should denoise video before encoding it.
  // If it's not set, the default configuration is used which is different
  // depending on a video codec.
  absl::optional<bool> needs_denoising() const override;

  // Returns state of this `DeviceVideoCapturer`.
  webrtc::MediaSourceInterface::SourceState state() const override;

  // Returns `false` since `DeviceVideoCapturer` is meant to source local
  // devices only.
  bool remote() const override;

 protected:
  DeviceVideoCapturer();
  ~DeviceVideoCapturer();

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

 private:
  // Initializes `DeviceVideoCapturer` and starts capturing media.
  bool Init(size_t width,
            size_t height,
            size_t target_fps,
            size_t capture_device_index);

  // Frees underlying resources.
  void Destroy();

  // `VideoCaptureModule` responsible for capturing track from the local video
  // input device.
  rtc::scoped_refptr<webrtc::VideoCaptureModule> vcm_;

  // `VideoCaptureCapability` used to capture media.
  webrtc::VideoCaptureCapability capability_;
};

#endif
