#import "FlutterRPScreenRecorder.h"
#import <ReplayKit/ReplayKit.h>


//See: https://developer.apple.com/videos/play/wwdc2017/606/

NSString * const kErrorDomain = @"flutter_webrtc.videocapturer";

@implementation FlutterRTCCameraCapturer

- (void)startCapture:(nonnull void (^)(NSError *_Nullable error))completionHandler {
    
    // Call RTCCameraVideoCapturer's start method
    [self startCaptureWithDevice:_device
                          format:_format
                             fps:_fps
               completionHandler:completionHandler];
}

- (void)stopCapture:(nonnull void (^)(NSError *_Nullable error))completionHandler {
    
    // Call RTCCameraVideoCapturer's stop method
    [self stopCaptureWithCompletionHandler:^{
        completionHandler(nil);
    }];
}

@end

#if TARGET_OS_IPHONE

@implementation FlutterRPScreenRecorder {
    RTCVideoSource *source;
}

- (instancetype)initWithDelegate:(__weak id<RTCVideoCapturerDelegate>)delegate {
    source = delegate;
    return [super initWithDelegate:delegate];
}

- (void)startCapture:(nonnull void (^)(NSError *_Nullable error))completionHandler {
    
    if (@available(iOS 11.0, *)) {
        
        RPScreenRecorder* screenRecorder = [RPScreenRecorder sharedRecorder];
        
        [screenRecorder setMicrophoneEnabled:NO];
        
        // Check if RPScreenRecorder is available
        if (![screenRecorder isAvailable]) {
            NSError *error = [NSError errorWithDomain:kErrorDomain
                                                 code:0
                                             userInfo:@{@"message": @"RPScreenRecorder is not available"}];
            NSLog(@"FlutterRPScreenRecorder %@", error);
            completionHandler(error);
            return;
        }
        
        [screenRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer,
                                                  RPSampleBufferType bufferType,
                                                  NSError * _Nullable error) {
            if (error != nil) {
                // ...
                return;
            }
            
            if (bufferType != RPSampleBufferTypeVideo) {
                // Only handle video buffer for this case
                return;
            }
            
            [self captureSampleBuffer:sampleBuffer
                    dimensionsHandler:^(size_t width, size_t height) {
                //
                [self->source adaptOutputFormatToWidth:(int)(width/2)
                                                height:(int)(height/2)
                                                   fps:8];
            }];
            
        } completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"FlutterRPScreenRecorder %@", error);
            }
            completionHandler(error);
        }];
        
    } else {
        // Fallback on earlier versions
        NSError *error = [NSError errorWithDomain:kErrorDomain
                                             code:0
                                         userInfo:@{@"message": @"iOS11+ is required for RPScreenRecorder"}];
        NSLog(@"FlutterRPScreenRecorder %@", error);
        completionHandler(error);
    }
}

- (void)stopCapture:(nonnull void (^)(NSError *_Nullable error))completionHandler {
    
    if (@available(iOS 11.0, *)) {
        RPScreenRecorder* screenRecorder = [RPScreenRecorder sharedRecorder];
        
        [screenRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
            if (error != nil)
                NSLog(@"!!! stopCaptureWithHandler/completionHandler %@ !!!", error);
        }];
    } else {
        // Fallback on earlier versions
        NSError *error = [NSError errorWithDomain:kErrorDomain
                                             code:0
                                         userInfo:@{@"message": @"iOS11+ is required for RPScreenRecorder"}];
        NSLog(@"FlutterRPScreenRecorder %@", error);
        completionHandler(error);
    }
}

@end
#endif

#if TARGET_OS_OSX

@implementation FlutterMacOSScreenCapturer {
    RTCVideoSource *source;
    AVCaptureSession *session;
    AVCaptureVideoDataOutput *output;
}

- (instancetype)initWithDelegate:(__weak id<RTCVideoCapturerDelegate>)delegate {
    source = delegate;
    // Create the session
    session = [[AVCaptureSession alloc] init];
    // Prepare the output
    output = [[AVCaptureVideoDataOutput alloc] init];
    // Specify output format
    output.videoSettings = @{
        (NSString*)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
    };
    // Set delegate
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    return [super initWithDelegate:delegate];
}

-(void)startCapture:(void (^)(NSError * _Nullable))completionHandler {
    
    AVCaptureScreenInput *screenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:CGMainDisplayID()];
    if (screenInput == nil) completionHandler([NSError errorWithDomain:@"MacOSScreenCapturer"
                                                                  code:0
                                                              userInfo:nil]);
    
    // Remove all current inputs
    for (AVCaptureInput* input in session.inputs) {
        [session removeInput:input];
    }
    
    // Add new input
    [session addInput:screenInput];
    
    [session startRunning];
    completionHandler(nil);
}

- (void)stopCapture:(void (^)(NSError * _Nullable))completionHandler {
    [session stopRunning];
    completionHandler(nil);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    [self captureSampleBuffer:sampleBuffer
            dimensionsHandler:nil];
}

@end

#endif



@implementation RTCVideoCapturer (Flutter)

- (void)captureSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer
          dimensionsHandler:(nullable void (^)(size_t, size_t))dimensionsHandler;{
    
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 ||
        !CMSampleBufferIsValid(sampleBuffer) ||
        !CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return;
    }
    
    // if dimensionsHandler is not nil,
    // report back the dimensions obtained from CVPixelBuffer
    if (dimensionsHandler != nil) {
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        dimensionsHandler(width, height);
    }
    
    RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
    int64_t timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * NSEC_PER_SEC;
    RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
                                                             rotation:RTCVideoRotation_0
                                                          timeStampNs:timeStampNs];
    
    [self.delegate capturer:self didCaptureVideoFrame:videoFrame];
}

@end
