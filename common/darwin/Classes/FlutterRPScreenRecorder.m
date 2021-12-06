#import "FlutterRPScreenRecorder.h"
#import <ReplayKit/ReplayKit.h>

#import "FlutterRTCMediaStream.h"

//See: https://developer.apple.com/videos/play/wwdc2017/606/

NSString * const kErrorDomain = @"flutter_webrtc.videocapturer";

#pragma mark - CameraCapturer

@implementation FlutterRTCCameraCapturer

+ (nullable AVCaptureDevice *)deviceForPosition:(AVCaptureDevicePosition)position {
    // Try to find device for position
    if (position != AVCaptureDevicePositionUnspecified) {
        NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
        for (AVCaptureDevice *device in captureDevices) {
            if (device.position == position) {
                return device;
            }
        }
    }

    // Attempt to return default device
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#pragma mark -

- (nullable AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device
                                      preferredDimensions:(CMVideoDimensions)preferredDimensions {

    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(preferredDimensions.width - dimension.width) + abs(preferredDimensions.height - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [self preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    return selectedFormat;
}

- (void)updateFromVideoConstraints:(nullable id)videoConstraints {
    
    AVCaptureDevice *resolvedDevice;

    // Initial values
    CMVideoDimensions preferredDimensions = { .width = 1280, .height = 720, };
    NSInteger preferredFPS = 30;
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;

    if ([videoConstraints isKindOfClass:[NSDictionary class]]) {

        // device with sourceId has highest priority
        id optionalVideoConstraints = videoConstraints[@"optional"];
        if ([optionalVideoConstraints isKindOfClass:[NSArray class]]) {
            NSArray *options = optionalVideoConstraints;
            for (id item in options) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSString *sourceId = ((NSDictionary *)item)[@"sourceId"];
                    if (sourceId) {
                        resolvedDevice = [AVCaptureDevice deviceWithUniqueID:sourceId];
                        if (resolvedDevice != nil) { break; }
                    }
                }
            }
        }
        
        // constraints.video.facingMode
        // https://www.w3.org/TR/mediacapture-streams/#def-constraint-facingMode
        id facingMode = videoConstraints[@"facingMode"];
        if (facingMode && [facingMode isKindOfClass:[NSString class]]) {
            if ([facingMode isEqualToString:@"environment"]) {
                preferredPosition = AVCaptureDevicePositionBack;
            } else if ([facingMode isEqualToString:@"user"]) {
                preferredPosition = AVCaptureDevicePositionFront;
            }
        }

        
        id mandatory = [videoConstraints isKindOfClass:[NSDictionary class]]? videoConstraints[@"mandatory"] : nil;

        // constraints.video.mandatory
        if(mandatory && [mandatory isKindOfClass:[NSDictionary class]]) {
            id widthConstraint = mandatory[@"minWidth"];
            if ([widthConstraint isKindOfClass:[NSString class]]) {
                int possibleWidth = [widthConstraint intValue];
                if (possibleWidth != 0) {
                    preferredDimensions.width = possibleWidth;
                }
            }
            id heightConstraint = mandatory[@"minHeight"];
            if ([heightConstraint isKindOfClass:[NSString class]]) {
                int possibleHeight = [heightConstraint intValue];
                if (possibleHeight != 0) {
                    preferredDimensions.height = possibleHeight;
                }
            }
            id fpsConstraint = mandatory[@"minFrameRate"];
            if ([fpsConstraint isKindOfClass:[NSString class]]) {
                int possibleFps = [fpsConstraint intValue];
                if (possibleFps != 0) {
                    preferredFPS = possibleFps;
                }
            }
        }

        int possibleWidth = [videoConstraints constraintIntForKey:@"width"];
        if(possibleWidth != 0){
            preferredDimensions.width = possibleWidth;
        }
        
        int possibleHeight = [videoConstraints constraintIntForKey:@"height"];
        if(possibleHeight != 0){
            preferredDimensions.height = possibleHeight;
        }
        
        int possibleFps = [videoConstraints constraintIntForKey:@"frameRate"];
        if(possibleFps != 0){
            preferredFPS = possibleFps;
        }

    }
}

#pragma mark -

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
                // TODO: Handle this error, perhaps by stopping capturer ?
                return;
            }
            
            if (bufferType != RPSampleBufferTypeVideo) {
                // Only handle video buffer for this case
                return;
            }
            
            [self captureSampleBuffer:sampleBuffer
                    dimensionsHandler:^(size_t width, size_t height) {
                // TODO: Update this legacy code
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
