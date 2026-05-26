#import "FlutterRTCVideoPlatformView.h"

@implementation FlutterRTCVideoPlatformView {
  CGSize _videoSize;
  AVSampleBufferDisplayLayer* _videoLayer;
  CGSize _remoteVideoSize;
  CATransform3D _bufferTransform;
  RTCVideoRotation _lastVideoRotation;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
    _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _videoLayer.frame = CGRectZero;
    _bufferTransform = CATransform3DIdentity;
    _lastVideoRotation = RTCVideoRotation_0;
    [self.layer addSublayer:_videoLayer];
    self.opaque = NO;
  }
  return self;
}

- (void)layoutSubviews {
  _videoLayer.frame = self.bounds;
  [_videoLayer removeAllAnimations];
}

- (void)setSize:(CGSize)size {
    _remoteVideoSize = size;
}

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame {

  CVPixelBufferRef pixelBuffer = nil;
  if ([frame.buffer isKindOfClass:[RTCCVPixelBuffer class]]) {
    pixelBuffer = ((RTCCVPixelBuffer*)frame.buffer).pixelBuffer;
    CFRetain(pixelBuffer);
  } else if ([frame.buffer isKindOfClass:[RTCI420Buffer class]]) {
    pixelBuffer = [self toCVPixelBuffer:frame];
  }

  if (_lastVideoRotation != frame.rotation) {
    _bufferTransform = [self fromFrameRotation:frame.rotation];
    _videoLayer.transform = _bufferTransform;
    [_videoLayer layoutIfNeeded];
    _lastVideoRotation = frame.rotation;
  }

  CMSampleBufferRef sampleBuffer = [self sampleBufferFromPixelBuffer:pixelBuffer];
  if (sampleBuffer) {
      if (@available(iOS 14.0, *)) {
          if([_videoLayer requiresFlushToResumeDecoding]) {
              [_videoLayer flushAndRemoveImage];
          }
      } else {
          // Fallback on earlier versions
      }
    [_videoLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
  }

  CFRelease(pixelBuffer);
}

- (CVPixelBufferRef)toCVPixelBuffer:(RTCVideoFrame*)frame {
  CVPixelBufferRef outputPixelBuffer;
  NSDictionary* pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
  CVPixelBufferCreate(kCFAllocatorDefault, frame.width, frame.height,
                      kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                      (__bridge CFDictionaryRef)(pixelAttributes), &outputPixelBuffer);
  id<RTCI420Buffer> i420Buffer = (RTCI420Buffer*)frame.buffer;

  CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);
  // NV12
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
  OSStatus err = noErr;
  CMVideoFormatDescriptionRef formatDesc = NULL;
  err = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDesc);
  if (err != noErr) {
    return nil;
  }
  CMSampleTimingInfo sampleTimingInfo = kCMTimingInfoInvalid;
  err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDesc,
                                                 &sampleTimingInfo, &sampleBuffer);
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

- (CATransform3D)fromFrameRotation:(RTCVideoRotation)rotation {
  switch (rotation) {
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
