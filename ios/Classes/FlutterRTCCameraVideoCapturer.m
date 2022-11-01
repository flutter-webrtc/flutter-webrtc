#import <WebRTC/WebRTC.h>

#import <ReplayKit/ReplayKit.h>
#import "FlutterRTCCameraVideoCapturer.h"


const int64_t kNanosecondsPerSecond = 1000000000;


@implementation FlutterRTCCameraVideoCapturer {
    RTCVideoRotation _prevRotation;
    BOOL _isLandscapeMode;
    AVCaptureDevicePosition _cameraPosition;
}

- (instancetype)initWithDelegate:(__weak id<RTCVideoCapturerDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    _isLandscapeMode = false;
    _cameraPosition = AVCaptureDevicePositionBack;

    return self;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
        !CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return;
    }
#if TARGET_OS_IPHONE
    // Default to portrait orientation on iPhone.
    RTCVideoRotation rotation = [self getLandscapeRotation];
#else
    // No rotation on Mac.
    RTCVideoRotation rotation = RTCVideoRotation_0;
#endif
    RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
    int64_t timeStampNs = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) *
    kNanosecondsPerSecond;
    RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
                                                             rotation:rotation
                                                          timeStampNs:timeStampNs];
    [self.delegate capturer:self didCaptureVideoFrame:videoFrame];
}

-(RTCVideoRotation) getLandscapeRotation {
    UIDeviceOrientation currentRotation =  [UIDevice currentDevice].orientation;

    if (!_isLandscapeMode) {
        return [self getDefaultLandscapeRotation: currentRotation];
    }

    switch(currentRotation) {
        case UIDeviceOrientationPortrait:
            if (_prevRotation == RTCVideoRotation_180) {
                return [self swapRotation] ? RTCVideoRotation_0 : RTCVideoRotation_180;
            }
            return [self swapRotation] ? RTCVideoRotation_180 : RTCVideoRotation_0;
        case UIDeviceOrientationPortraitUpsideDown:
            if (_prevRotation == RTCVideoRotation_0) {
                return [self swapRotation] ? RTCVideoRotation_180 : RTCVideoRotation_0;
            }
            return [self swapRotation] ? RTCVideoRotation_0 : RTCVideoRotation_180;
        default:
            _prevRotation = [self getDefaultLandscapeRotation: currentRotation];
            return _prevRotation;
    }
}

-(RTCVideoRotation) getDefaultLandscapeRotation:(UIDeviceOrientation) currentRotation {
    switch (currentRotation) {
        case UIDeviceOrientationPortrait:
            return [self swapRotation] ? RTCVideoRotation_270 : RTCVideoRotation_90;
        case UIDeviceOrientationPortraitUpsideDown:
            return [self swapRotation] ? RTCVideoRotation_90 : RTCVideoRotation_270;
        case UIDeviceOrientationLandscapeLeft:
            return [self swapRotation] ? RTCVideoRotation_180 : RTCVideoRotation_0;
        case UIDeviceOrientationLandscapeRight:
            return [self swapRotation] ? RTCVideoRotation_0 : RTCVideoRotation_180;
        default:
            return _prevRotation;
    }
}

- (void)setLandscapeMode:(BOOL)landscapeMode {
    _isLandscapeMode = landscapeMode;
}

- (void)setCameraPosition:(AVCaptureDevicePosition)position {
    _cameraPosition = position;
}

- (BOOL)swapRotation {
    return _cameraPosition == AVCaptureDevicePositionFront;
}

@end