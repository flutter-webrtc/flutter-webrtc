#import <WebRTC/WebRTC.h>
#import <CoreMedia/CoreMedia.h>

// Common interface for a VideoCapturer that can be started/stopped asynchronously
@protocol FlutterRTCVideoCapturer <NSObject>
// Starts the capture session asynchronously and notifies callback on completion.
- (void)startCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
// Stops the capture session asynchronously and notifies callback on completion.
- (void)stopCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
@end

@interface RTCCameraVideoCapturer (Flutter) <FlutterRTCVideoCapturer>

@end

#if TARGET_OS_IPHONE
// Only available for iOS
@interface FlutterRPScreenRecorder : RTCVideoCapturer <FlutterRTCVideoCapturer>
- (void)startCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
- (void)stopCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
@end
#elif TARGET_OS_OSX
// Only available for macOS
@interface FlutterMacOSScreenCapturer: RTCVideoCapturer
    <FlutterRTCVideoCapturer, AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)startCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
- (void)stopCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
@end
#endif

// Extends RTCVideoCapturer to take CMSampleBufferRef as input
@interface RTCVideoCapturer (Flutter)
- (void)captureSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer
          dimensionsHandler:(nullable void (^)(size_t, size_t))dimensionsHandler;
@end
