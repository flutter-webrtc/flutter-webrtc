#ifndef MAC_CAPTURER_H_
#define MAC_CAPTURER_H_

#include <memory>
#include <string>
#include <vector>

#include <api/media_stream_interface.h>
#include <api/scoped_refptr.h>
#include <base/RTCMacros.h>
#include <media/base/adapted_video_track_source.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/ref_counted_object.h>
#include <rtc_base/thread.h>
#include <stddef.h>
#include <memory>
#include <vector>

#include <api/scoped_refptr.h>
#include <media/base/adapted_video_track_source.h>
#include <media/base/video_adapter.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/ref_counted_object.h>
#include <rtc_base/timestamp_aligner.h>

RTC_FWD_DECL_OBJC_CLASS(AVCaptureDevice);
RTC_FWD_DECL_OBJC_CLASS(RTCCameraVideoCapturer);
RTC_FWD_DECL_OBJC_CLASS(RTCVideoSourceAdapter);

// `VideoTrackSourceInterface` capturing frames from a local video input device.
class MacCapturer : public rtc::AdaptedVideoTrackSource,
                    public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Creates a new `MacCapturer` with the specified constraints.
  static rtc::scoped_refptr<MacCapturer> Create(size_t width,
                                                size_t height,
                                                size_t target_fps,
                                                uint32_t capture_device_index);

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

  // Indicates whether the parameters suitable for screencast should be
  // automatically applied to `RtpSender`s.
  bool is_screencast() const override;

  // Indicates whether the encoder should denoise video before encoding it.
  //
  // If it's not set, the default configuration is used, which is different
  // depending on a video codec.
  absl::optional<bool> needs_denoising() const override;

  // Returns state of this `DeviceVideoCapturer`.
  webrtc::MediaSourceInterface::SourceState state() const override;

  // Returns `false` always, since `DeviceVideoCapturer` is meant to source
  // local devices only.
  bool remote() const override;

 protected:
  MacCapturer(size_t width,
              size_t height,
              size_t target_fps,
              AVCaptureDevice* device);
  virtual ~MacCapturer();

 private:
  void Destroy();

  // `RTCCameraVideoCapturer` responsible for capturing track from the local
  // video input device.
  RTCCameraVideoCapturer* capturer_;

  // `RTCVideoSourceAdapter` injected into the `capturer_`.
  RTCVideoSourceAdapter* adapter_;
};

#endif  // MAC_CAPTURER_H_
