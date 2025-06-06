#if __APPLE__
#include "mac_capturer.h"

#include <rtc_base/logging.h>

#import <sdk/objc/base/RTCVideoCapturer.h>
#import <sdk/objc/components/capturer/RTCCameraVideoCapturer.h>
#import <sdk/objc/native/api/video_capturer.h>
#import <sdk/objc/native/src/objc_frame_buffer.h>

@interface RTCVideoSourceAdapter : NSObject <RTCVideoCapturerDelegate>
@property(nonatomic) MacCapturer* capturer;
@end

@implementation RTCVideoSourceAdapter
@synthesize capturer = _capturer;

- (void)capturer:(RTCVideoCapturer*)capturer didCaptureVideoFrame:(RTCVideoFrame*)frame {
  const int64_t timestamp_us = frame.timeStampNs / webrtc::kNumNanosecsPerMicrosec;
  webrtc::scoped_refptr<webrtc::VideoFrameBuffer> buffer =
      webrtc::make_ref_counted<webrtc::ObjCFrameBuffer>(frame.buffer);
  _capturer->OnFrame(webrtc::VideoFrame::Builder()
                         .set_video_frame_buffer(buffer)
                         .set_rotation(webrtc::kVideoRotation_0)
                         .set_timestamp_us(timestamp_us)
                         .build());
}

@end

namespace {

// Chooses the best fit video dimensions for the provided `AVCaptureDevice`.
AVCaptureDeviceFormat* SelectClosestFormat(AVCaptureDevice* device, size_t width, size_t height) {
  NSArray<AVCaptureDeviceFormat*>* formats =
      [RTCCameraVideoCapturer supportedFormatsForDevice:device];
  AVCaptureDeviceFormat* selectedFormat = nil;
  int currentDiff = INT_MAX;
  for (AVCaptureDeviceFormat* format in formats) {
    CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
    int diff = std::abs((int64_t)width - dimension.width) +
               std::abs((int64_t)height - dimension.height);
    if (diff < currentDiff) {
      selectedFormat = format;
      currentDiff = diff;
    }
  }
  return selectedFormat;
}

}  // namespace

// Creates a new `MacCapturer`.
MacCapturer::MacCapturer(size_t width, size_t height, size_t target_fps, AVCaptureDevice* device) {
  RTC_LOG(LS_INFO) << "MacCapturer width=" << width << ", height=" << height
                   << ", target_fps=" << target_fps;

  adapter_ = [[RTCVideoSourceAdapter alloc] init];
  adapter_.capturer = this;

  capturer_ = [[RTCCameraVideoCapturer alloc] initWithDelegate:adapter_];
  AVCaptureDeviceFormat* format = SelectClosestFormat(device, width, height);
  [capturer_ startCaptureWithDevice:device format:format fps:target_fps];
}

void MacCapturer::Destroy() {
  [capturer_ stopCapture];
}

MacCapturer::~MacCapturer() {
  Destroy();
}

// Creates a new `MacCapturer`.
webrtc::scoped_refptr<MacCapturer> MacCapturer::Create(size_t width,
                                                    size_t height,
                                                    size_t target_fps,
                                                    uint32_t capture_device_index) {
  AVCaptureDeviceDiscoverySession* discoverySession =
      [AVCaptureDeviceDiscoverySession
          discoverySessionWithDeviceTypes:@[
            AVCaptureDeviceTypeBuiltInWideAngleCamera,
            AVCaptureDeviceTypeExternalUnknown
          ]
          mediaType:AVMediaTypeVideo
          position:AVCaptureDevicePositionUnspecified];

  NSArray<AVCaptureDevice*>* devices = discoverySession.devices;
  AVCaptureDevice* device = [devices objectAtIndex:capture_device_index];
  if (!device) {
    RTC_LOG(LS_ERROR) << "Failed to create MacCapture";
    return nullptr;
  }

  return webrtc::make_ref_counted<MacCapturer>(width, height, target_fps, device);
}

// Propagates a `VideoFrame` to the `AdaptedVideoTrackSource::OnFrame()`.
void MacCapturer::OnFrame(const webrtc::VideoFrame& frame) {
  AdaptedVideoTrackSource::OnFrame(frame);
}

// Returns `false`.
bool MacCapturer::is_screencast() const {
  return false;
}

// Returns `false`.
std::optional<bool> MacCapturer::needs_denoising() const {
  return false;
}

// Returns `SourceState::kLive`.
webrtc::MediaSourceInterface::SourceState MacCapturer::state() const {
  return SourceState::kLive;
}

// Returns `false`.
bool MacCapturer::remote() const {
  return false;
}
#endif __APPLE__
