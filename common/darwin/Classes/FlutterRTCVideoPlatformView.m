#import "FlutterRTCVideoPlatformView.h"

#import <QuartzCore/QuartzCore.h>
#import <WebRTC/RTCCVPixelBuffer.h>
#import <WebRTC/RTCI420Buffer.h>
#import <WebRTC/RTCYUVHelper.h>

@implementation FlutterRTCVideoPlatformView {
  AVSampleBufferDisplayLayer* _videoLayer;
  dispatch_queue_t _sampleBufferQueue;
  RTCVideoRotation _lastVideoRotation;
}

- (instancetype)initWithFrame:(FlutterRTCVideoPlatformFrame)frame {
  if (self = [super initWithFrame:frame]) {
#if TARGET_OS_OSX
    self.wantsLayer = YES;
#endif
    _videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
    _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoLayer.frame = CGRectZero;
    _sampleBufferQueue =
        dispatch_queue_create("com.cloudwebrtc.flutterwebrtc.video-platform-view.sample-buffer",
                              DISPATCH_QUEUE_SERIAL);
    _lastVideoRotation = RTCVideoRotation_0;
    [self.layer addSublayer:_videoLayer];
#if TARGET_OS_IPHONE
    self.opaque = NO;
#endif
  }
  return self;
}

#if TARGET_OS_IPHONE
- (void)layoutSubviews {
  [super layoutSubviews];
  [self layoutVideoLayer];
}
#elif TARGET_OS_OSX
- (BOOL)isOpaque {
  return NO;
}

- (void)layout {
  [super layout];
  [self layoutVideoLayer];
}
#endif

- (void)layoutVideoLayer {
  _videoLayer.frame = self.bounds;
  [_videoLayer removeAllAnimations];
}

- (void)setSize:(CGSize)size {
}

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
  if (!frame) {
    return;
  }

  CVPixelBufferRef pixelBuffer = nil;
  if ([frame.buffer isKindOfClass:[RTCCVPixelBuffer class]]) {
    pixelBuffer = ((RTCCVPixelBuffer*)frame.buffer).pixelBuffer;
    CFRetain(pixelBuffer);
  } else {
    pixelBuffer = [self toCVPixelBuffer:frame];
  }

  if (!pixelBuffer) {
    return;
  }

  RTCVideoRotation rotation = frame.rotation;
  CMSampleBufferRef sampleBuffer = [self sampleBufferFromPixelBuffer:pixelBuffer];
  CFRelease(pixelBuffer);

  if (!sampleBuffer) {
    return;
  }

  dispatch_async(_sampleBufferQueue, ^{
    [self renderSampleBuffer:sampleBuffer rotation:rotation];
    CFRelease(sampleBuffer);
  });
}

- (void)renderSampleBuffer:(CMSampleBufferRef)sampleBuffer rotation:(RTCVideoRotation)rotation {
  [self updateVideoLayerTransformForRotation:rotation];

#if TARGET_OS_IPHONE
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 170000
  if (@available(iOS 17.0, *)) {
    AVSampleBufferVideoRenderer* renderer = _videoLayer.sampleBufferRenderer;
    if ([renderer requiresFlushToResumeDecoding]) {
      [renderer flushWithRemovalOfDisplayedImage:YES completionHandler:nil];
    }
    [renderer enqueueSampleBuffer:sampleBuffer];
    return;
  }
#endif
  if (@available(iOS 14.0, *)) {
    if ([_videoLayer requiresFlushToResumeDecoding]) {
      [_videoLayer flushAndRemoveImage];
    }
  }
#elif TARGET_OS_OSX
#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 140000
  if (@available(macOS 14.0, *)) {
    AVSampleBufferVideoRenderer* renderer = _videoLayer.sampleBufferRenderer;
    if ([renderer requiresFlushToResumeDecoding]) {
      [renderer flushWithRemovalOfDisplayedImage:YES completionHandler:nil];
    }
    [renderer enqueueSampleBuffer:sampleBuffer];
    return;
  }
#endif
  if (@available(macOS 11.0, *)) {
    if ([_videoLayer requiresFlushToResumeDecoding]) {
      [_videoLayer flushAndRemoveImage];
    }
  }
#endif
  [_videoLayer enqueueSampleBuffer:sampleBuffer];
}

- (void)updateVideoLayerTransformForRotation:(RTCVideoRotation)rotation {
  if (_lastVideoRotation != rotation) {
    CATransform3D transform = [self fromFrameRotation:rotation];
    _lastVideoRotation = rotation;

    if ([NSThread isMainThread]) {
      _videoLayer.transform = transform;
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        self->_videoLayer.transform = transform;
      });
    }
  }
}

- (CVPixelBufferRef)toCVPixelBuffer:(RTCVideoFrame*)frame {
  CVPixelBufferRef outputPixelBuffer = nil;
  NSDictionary* pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
  CVPixelBufferCreate(kCFAllocatorDefault, frame.width, frame.height,
                      kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                      (__bridge CFDictionaryRef)(pixelAttributes), &outputPixelBuffer);
  if (!outputPixelBuffer) {
    return nil;
  }

  id<RTCI420Buffer> i420Buffer = [frame.buffer toI420];

  CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);
  uint8_t* dstY = CVPixelBufferGetBaseAddressOfPlane(outputPixelBuffer, 0);
  const size_t dstYStride = CVPixelBufferGetBytesPerRowOfPlane(outputPixelBuffer, 0);
  uint8_t* dstUV = CVPixelBufferGetBaseAddressOfPlane(outputPixelBuffer, 1);
  const size_t dstUVStride = CVPixelBufferGetBytesPerRowOfPlane(outputPixelBuffer, 1);

  [RTCYUVHelper I420ToNV12:i420Buffer.dataY
                srcStrideY:i420Buffer.strideY
                      srcU:i420Buffer.dataU
                srcStrideU:i420Buffer.strideU
                      srcV:i420Buffer.dataV
                srcStrideV:i420Buffer.strideV
                      dstY:dstY
                dstStrideY:(int)dstYStride
                     dstUV:dstUV
               dstStrideUV:(int)dstUVStride
                     width:i420Buffer.width
                    height:i420Buffer.height];

  CVPixelBufferUnlockBaseAddress(outputPixelBuffer, 0);
  return outputPixelBuffer;
}

- (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
  CMSampleBufferRef sampleBuffer = NULL;
  CMVideoFormatDescriptionRef formatDesc = NULL;
  OSStatus err = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDesc);
  if (err != noErr) {
    return nil;
  }

  CMSampleTimingInfo sampleTimingInfo = kCMTimingInfoInvalid;
  err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDesc,
                                                 &sampleTimingInfo, &sampleBuffer);
  if (formatDesc) {
    CFRelease(formatDesc);
  }
  if (err != noErr) {
    return nil;
  }

  if (sampleBuffer) {
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    if (attachments && CFArrayGetCount(attachments) > 0) {
      CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
      if (dict) {
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
      }
    }
  }
  return sampleBuffer;
}

- (CATransform3D)fromFrameRotation:(RTCVideoRotation)rotation {
  switch (rotation) {
    case RTCVideoRotation_0:
      return CATransform3DIdentity;
    case RTCVideoRotation_90:
      return CATransform3DMakeRotation(M_PI / 2.0, 0, 0, 1);
    case RTCVideoRotation_180:
      return CATransform3DMakeRotation(M_PI, 0, 0, 1);
    case RTCVideoRotation_270:
      return CATransform3DMakeRotation(-M_PI / 2.0, 0, 0, 1);
  }
  return CATransform3DIdentity;
}

@end
