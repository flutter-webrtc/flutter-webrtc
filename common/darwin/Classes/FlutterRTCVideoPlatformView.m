#import "FlutterRTCVideoPlatformView.h"

#import <QuartzCore/QuartzCore.h>
#import <WebRTC/RTCCVPixelBuffer.h>
#import <WebRTC/RTCI420Buffer.h>
#import <WebRTC/RTCYUVHelper.h>

@implementation FlutterRTCVideoPlatformView {
  AVSampleBufferDisplayLayer* _videoLayer;
  dispatch_queue_t _sampleBufferQueue;
  RTCVideoRotation _lastVideoRotation;
  CVPixelBufferPoolRef _cropAndScalePixelBufferPool;
  int _cropAndScalePixelBufferPoolWidth;
  int _cropAndScalePixelBufferPoolHeight;
  OSType _cropAndScalePixelBufferPoolPixelFormat;
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

- (void)dealloc {
  if (_cropAndScalePixelBufferPool) {
    CFRelease(_cropAndScalePixelBufferPool);
    _cropAndScalePixelBufferPool = NULL;
  }
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
    pixelBuffer = [self pixelBufferFromRTCCVPixelBuffer:(RTCCVPixelBuffer*)frame.buffer];
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
  if (_lastVideoRotation == rotation) {
    return;
  }
  _lastVideoRotation = rotation;

  CATransform3D transform = [self fromFrameRotation:rotation];
  // CoreAnimation derives the layer's geometry from `frame` through the
  // active transform, so both must be applied together: updating only the
  // transform leaves the layer with bounds computed under the old rotation
  // until the next layout pass.
  void (^applyRotation)(void) = ^{
    self->_videoLayer.transform = transform;
    [self layoutVideoLayer];
  };
  if ([NSThread isMainThread]) {
    applyRotation();
  } else {
    dispatch_async(dispatch_get_main_queue(), applyRotation);
  }
}

- (CVPixelBufferRef)pixelBufferFromRTCCVPixelBuffer:(RTCCVPixelBuffer*)buffer {
  if (![buffer requiresCropping] &&
      ![buffer requiresScalingToWidth:buffer.width height:buffer.height]) {
    CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
    CFRetain(pixelBuffer);
    return pixelBuffer;
  }

  CVPixelBufferRef outputPixelBuffer = nil;
  OSType pixelFormat = CVPixelBufferGetPixelFormatType(buffer.pixelBuffer);
  @synchronized(self) {
    CVPixelBufferPoolRef pixelBufferPool =
        [self pixelBufferPoolForWidth:buffer.width height:buffer.height pixelFormat:pixelFormat];
    if (pixelBufferPool) {
      CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &outputPixelBuffer);
    }
  }
  if (!outputPixelBuffer) {
    return nil;
  }

  int tempBufferSize =
      [buffer bufferSizeForCroppingAndScalingToWidth:buffer.width height:buffer.height];
  uint8_t* tempBuffer = nil;
  if (tempBufferSize > 0) {
    tempBuffer = malloc((size_t)tempBufferSize);
    if (!tempBuffer) {
      CFRelease(outputPixelBuffer);
      return nil;
    }
  }

  BOOL didCropAndScale = [buffer cropAndScaleTo:outputPixelBuffer withTempBuffer:tempBuffer];
  if (tempBuffer) {
    free(tempBuffer);
  }
  if (!didCropAndScale) {
    CFRelease(outputPixelBuffer);
    return nil;
  }

  CVBufferPropagateAttachments(buffer.pixelBuffer, outputPixelBuffer);
  return outputPixelBuffer;
}

- (CVPixelBufferPoolRef)pixelBufferPoolForWidth:(int)width
                                         height:(int)height
                                    pixelFormat:(OSType)pixelFormat {
  if (_cropAndScalePixelBufferPool && _cropAndScalePixelBufferPoolWidth == width &&
      _cropAndScalePixelBufferPoolHeight == height &&
      _cropAndScalePixelBufferPoolPixelFormat == pixelFormat) {
    return _cropAndScalePixelBufferPool;
  }

  NSDictionary* pixelBufferAttributes = @{
    (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
    (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
    (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
    (id)kCVPixelBufferWidthKey : @(width),
    (id)kCVPixelBufferHeightKey : @(height),
    (id)kCVPixelBufferPixelFormatTypeKey : @(pixelFormat),
  };
  NSDictionary* poolAttributes = @{
    (id)kCVPixelBufferPoolMinimumBufferCountKey : @4,
  };

  CVPixelBufferPoolRef pixelBufferPool = NULL;
  CVReturn result =
      CVPixelBufferPoolCreate(kCFAllocatorDefault, (__bridge CFDictionaryRef)poolAttributes,
                              (__bridge CFDictionaryRef)pixelBufferAttributes, &pixelBufferPool);
  if (result != kCVReturnSuccess) {
    return NULL;
  }

  if (_cropAndScalePixelBufferPool) {
    CFRelease(_cropAndScalePixelBufferPool);
  }
  _cropAndScalePixelBufferPool = pixelBufferPool;
  _cropAndScalePixelBufferPoolWidth = width;
  _cropAndScalePixelBufferPoolHeight = height;
  _cropAndScalePixelBufferPoolPixelFormat = pixelFormat;

  return _cropAndScalePixelBufferPool;
}

- (CVPixelBufferRef)toCVPixelBuffer:(RTCVideoFrame*)frame {
  CVPixelBufferRef outputPixelBuffer = nil;
  NSDictionary* pixelAttributes = @{
    (id)kCVPixelBufferCGImageCompatibilityKey : @YES,
    (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
    (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
  };
  CVPixelBufferCreate(kCFAllocatorDefault, frame.width, frame.height, kCVPixelFormatType_32BGRA,
                      (__bridge CFDictionaryRef)(pixelAttributes), &outputPixelBuffer);
  if (!outputPixelBuffer) {
    return nil;
  }

  id<RTCI420Buffer> i420Buffer = [frame.buffer toI420];

  CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);
  uint8_t* dst = CVPixelBufferGetBaseAddress(outputPixelBuffer);
  const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(outputPixelBuffer);

  [RTCYUVHelper I420ToARGB:i420Buffer.dataY
                srcStrideY:i420Buffer.strideY
                      srcU:i420Buffer.dataU
                srcStrideU:i420Buffer.strideU
                      srcV:i420Buffer.dataV
                srcStrideV:i420Buffer.strideV
                   dstARGB:dst
             dstStrideARGB:(int)bytesPerRow
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
