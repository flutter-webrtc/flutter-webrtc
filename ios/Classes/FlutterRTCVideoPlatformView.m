#import "FlutterRTCVideoPlatformView.h"

@implementation FlutterRTCVideoPlatformView {
    CGSize _videoSize;
    AVSampleBufferDisplayLayer *_videoLayer;
    RTCVideoRotation _rotation;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
         _rotation = RTCVideoRotation_0;
        _videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
        _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoLayer.frame = frame;
        [self.layer insertSublayer:_videoLayer atIndex:0];
        self.opaque = NO;
    }
    return self;
}

- (void)layoutSubviews {
    _videoLayer.frame = self.bounds;
    [_videoLayer removeAllAnimations];
}

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
    CVPixelBufferRef pixelBuffer = nil;
    if([frame.buffer isKindOfClass: [RTCCVPixelBuffer  class]]) {
        pixelBuffer =  ((RTCCVPixelBuffer *)frame.buffer).pixelBuffer;
    } else if([frame.buffer isKindOfClass: [RTCI420Buffer  class]]) {
        //TODO(cloudwebrtc): Not yet implemented.
        return;
    }

    if (_rotation != frame.rotation) {
        CATransform3D  bufferTransform = [self fromFrameRotation:frame];
        _videoLayer.transform = bufferTransform;
        [_videoLayer layoutIfNeeded];
        _rotation = frame.rotation;
    }

    CMSampleBufferRef sampleBuffer = [self sampleBufferFromPixelBuffer:pixelBuffer];
    if (sampleBuffer) {
        [_videoLayer enqueueSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
    }
}

- (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus err = noErr;
    CMVideoFormatDescriptionRef formatDesc = NULL;
    err = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDesc);
    if (err != noErr) {
        return nil;
    }
    CMSampleTimingInfo sampleTimingInfo = kCMTimingInfoInvalid;
    err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDesc, &sampleTimingInfo, &sampleBuffer);
    if (sampleBuffer) {
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    }
    if (err != noErr) {
        return nil;
    }
    formatDesc = nil;
    return sampleBuffer;
}

-(CATransform3D) fromFrameRotation:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
        switch (frame.rotation) {
        case RTCVideoRotation_0:
                return CATransform3DIdentity;
        case RTCVideoRotation_90:
                return CATransform3DMakeRotation(M_PI / 2.0, 0, 0, 1);
        case RTCVideoRotation_180:
                return CATransform3DMakeRotation(M_PI, 0, 0, 1);
        case RTCVideoRotation_270:
                return CATransform3DMakeRotation(-M_PI / 0, 0, 0, 1);
        }
    return CATransform3DIdentity;
}

@end
