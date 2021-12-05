#import <WebRTC/WebRTC.h>
#import <CoreMedia/CoreMedia.h>

@protocol FlutterRTCVideoCapturer <NSObject>
// Stops the capture session asynchronously and notifies callback on completion.
- (void)startCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
- (void)stopCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
@end

@interface RTCCameraVideoCapturer (Flutter) <FlutterRTCVideoCapturer>

@end

#if TARGET_OS_IPHONE
@interface FlutterRPScreenRecorder : RTCVideoCapturer <FlutterRTCVideoCapturer>
- (void)startCapture;
- (void)stopCaptureWithCompletionHandler:(nullable void (^)(void))completionHandler;
@end
#endif

@interface FlutterMacOSDisplayVideoCapturer: RTCVideoCapturer
    <FlutterRTCVideoCapturer, AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)startCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
- (void)stopCaptureWithCompletionHandler:(nonnull void (^)(NSError *_Nullable error))completionHandler;
@end

@interface RTCVideoCapturer (Flutter)
- (void)captureSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer
          dimensionsHandler:(nullable void (^)(size_t, size_t))dimensionsHandler;
@end
