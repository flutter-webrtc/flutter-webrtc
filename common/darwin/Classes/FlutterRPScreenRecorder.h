#import <WebRTC/WebRTC.h>
#import <CoreMedia/CoreMedia.h>

// Common interface for a VideoCapturer that can be started/stopped asynchronously
@protocol FlutterRTCVideoCapturer <NSObject>
- (nonnull instancetype)initWithDelegate:(nullable id<RTC_OBJC_TYPE(RTCVideoCapturerDelegate)>)delegate;
// Starts the capture session asynchronously and notifies callback on completion.
- (void)startCapture:(nonnull void (^)(NSError *_Nullable error))completionHandler;
// Stops the capture session asynchronously and notifies callback on completion.
- (void)stopCapture:(nonnull void (^)(NSError *_Nullable error))completionHandler;
@end

// Make RTCCameraVideoCapturer comply with FlutterRTCVideoCapturer protocol
@interface FlutterRTCCameraCapturer: RTCCameraVideoCapturer <FlutterRTCVideoCapturer>
+ (nullable AVCaptureDevice *)deviceForPosition:(AVCaptureDevicePosition)position;
- (nullable AVCaptureDeviceFormat *)selectFormatForDevice:(nonnull AVCaptureDevice *)device
                                      preferredDimensions:(CMVideoDimensions)preferredDimensions;

- (void)updateFromVideoConstraints:(nullable id)videoConstraints;

@property (nonatomic, strong, nullable) AVCaptureDevice *device;
@property (nonatomic, strong, nullable) AVCaptureDeviceFormat *format;
@property (nonatomic) NSInteger fps;

@end

#if TARGET_OS_IPHONE
// Only available for iOS
@interface FlutterRPScreenRecorder : RTCVideoCapturer <FlutterRTCVideoCapturer>
@end
#elif TARGET_OS_OSX
// Only available for macOS
@interface FlutterMacOSScreenCapturer: RTCVideoCapturer <FlutterRTCVideoCapturer,
    AVCaptureVideoDataOutputSampleBufferDelegate>
@end
#endif

// Extends RTCVideoCapturer to take CMSampleBufferRef as input
@interface RTCVideoCapturer (Flutter)
- (void)captureSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer
          dimensionsHandler:(nullable void (^)(size_t, size_t))dimensionsHandler;
@end
