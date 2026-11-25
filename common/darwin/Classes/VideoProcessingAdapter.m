#import "VideoProcessingAdapter.h"
#import <os/lock.h>
#if TARGET_OS_IOS
#import <WebRTC/RTCMutableI420Buffer.h>
#import <WebRTC/RTCYUVHelper.h>

static RTCMutableI420Buffer* RotatePixels(id<RTCVideoFrameBuffer> buffer, RTCVideoRotation rotation) {
  id<RTCI420Buffer> input = [buffer toI420];
  BOOL quarterTurn = rotation == RTCVideoRotation_90 || rotation == RTCVideoRotation_270;
  RTCMutableI420Buffer* output =
      [[RTCMutableI420Buffer alloc] initWithWidth:quarterTurn ? input.height : input.width
                                         height:quarterTurn ? input.width : input.height];
  [RTCYUVHelper I420Rotate:input.dataY
                srcStrideY:input.strideY
                      srcU:input.dataU
                srcStrideU:input.strideU
                      srcV:input.dataV
                srcStrideV:input.strideV
                      dstY:output.mutableDataY
                dstStrideY:output.strideY
                      dstU:output.mutableDataU
                dstStrideU:output.strideU
                      dstV:output.mutableDataV
                dstStrideV:output.strideV
                     width:input.width
                    height:input.height
                      mode:rotation];
  return output;
}

// Crop before rotation so the camera's buffer can scale only the pixels we keep.
static id<RTCVideoFrameBuffer> NormalizePixels(id<RTCVideoFrameBuffer> buffer,
                                               RTCVideoRotation rotation,
                                               int outputWidth, int outputHeight) {
  BOOL quarterTurn = rotation == RTCVideoRotation_90 || rotation == RTCVideoRotation_270;
  int width = quarterTurn ? outputHeight : outputWidth;
  int height = quarterTurn ? outputWidth : outputHeight;
  if (width > 0 && height > 0 && (width != buffer.width || height != buffer.height)) {
    int cropWidth = buffer.width;
    int cropHeight = buffer.height;
    if ((int64_t)cropWidth * height > (int64_t)cropHeight * width) {
      cropWidth = (int)((int64_t)cropHeight * width / height);
    } else {
      cropHeight = (int)((int64_t)cropWidth * height / width);
    }
    // 4:2:0 chroma samples cover 2×2 luma pixels.
    cropWidth = MAX(1, cropWidth & ~1);
    cropHeight = MAX(1, cropHeight & ~1);
    int offsetX = ((buffer.width - cropWidth) / 2) & ~1;
    int offsetY = ((buffer.height - cropHeight) / 2) & ~1;
    if (![buffer respondsToSelector:@selector(cropAndScaleWith:offsetY:cropWidth:cropHeight:scaleWidth:scaleHeight:)]) {
      // Custom frame buffers may omit cropping. A concrete I420 copy supports it.
      buffer = RotatePixels(buffer, RTCVideoRotation_0);
    }
    buffer = [buffer cropAndScaleWith:offsetX offsetY:offsetY cropWidth:cropWidth
                           cropHeight:cropHeight scaleWidth:width scaleHeight:height];
    // RTCCVPixelBuffer can represent this crop over a larger underlying buffer.
    // Materialize the requested raster even when no subsequent rotation is needed.
    if (rotation == RTCVideoRotation_0) return [buffer toI420];
  }
  return rotation == RTCVideoRotation_0 ? buffer : RotatePixels(buffer, rotation);
}

static int RequestedDimension(id constraint) {
  if ([constraint isKindOfClass:[NSDictionary class]]) {
    constraint = constraint[@"exact"] ?: constraint[@"ideal"];
  }
  if ([constraint isKindOfClass:[NSNumber class]] || [constraint isKindOfClass:[NSString class]]) {
    return [constraint intValue];
  }
  return 0;
}
#endif

@implementation VideoProcessingAdapter {
  RTCVideoSource* _videoSource;
#if TARGET_OS_IOS
  BOOL _normalizeCaptureOrientation;
  CMVideoDimensions _fixedOutputDimensions;
#endif
  CGSize _frameSize;
  NSArray<id<ExternalVideoProcessingDelegate>>* _processors;
  os_unfair_lock _lock;
}

- (instancetype)initWithRTCVideoSource:(RTCVideoSource*)source {
  self = [super init];
  if (self) {
    _lock = OS_UNFAIR_LOCK_INIT;
    _videoSource = source;
    _processors = [NSArray<id<ExternalVideoProcessingDelegate>> new];
  }
  return self;
}

#if TARGET_OS_IOS
- (instancetype)initWithRTCVideoSource:(RTCVideoSource *)source cameraConstraints:(NSDictionary *)constraints {
  self = [self initWithRTCVideoSource:source];
  if (self && [constraints isKindOfClass:[NSDictionary class]] &&
      constraints[@"normalizeCaptureOrientation"] == (__bridge id)kCFBooleanTrue) {
    _normalizeCaptureOrientation = YES;
    int width = RequestedDimension(constraints[@"width"]);
    int height = RequestedDimension(constraints[@"height"]);
    if (width > 0 && height > 0) {
      _fixedOutputDimensions = (CMVideoDimensions){width, height};
    }
  }
  return self;
}
#endif

- (CMVideoDimensions)trackDimensionsForCaptureDimensions:(CMVideoDimensions)captureDimensions {
#if TARGET_OS_IOS
  if (_fixedOutputDimensions.width > 0) return _fixedOutputDimensions;
#endif
  return captureDimensions;
}

- (RTCVideoSource* _Nonnull) source {
    return _videoSource;
}

- (void)addProcessing:(id<ExternalVideoProcessingDelegate>)processor {
  os_unfair_lock_lock(&_lock);
  _processors = [_processors arrayByAddingObject:processor];
  os_unfair_lock_unlock(&_lock);
}

- (void)removeProcessing:(id<ExternalVideoProcessingDelegate>)processor {
  os_unfair_lock_lock(&_lock);
  _processors = [_processors
      filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,
                                                                        NSDictionary* bindings) {
        return evaluatedObject != processor;
      }]];
  os_unfair_lock_unlock(&_lock);
}

- (void)setSize:(CGSize)size {
  _frameSize = size;
}

- (void)capturer:(RTC_OBJC_TYPE(RTCVideoCapturer) *)capturer
    didCaptureVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
#if TARGET_OS_IOS
  if (_normalizeCaptureOrientation) {
    id<RTCVideoFrameBuffer> buffer = NormalizePixels(frame.buffer, frame.rotation,
                                                     _fixedOutputDimensions.width, _fixedOutputDimensions.height);
    if (buffer != frame.buffer || frame.rotation != RTCVideoRotation_0) {
      RTCVideoFrame *output = [[RTCVideoFrame alloc] initWithBuffer:buffer rotation:RTCVideoRotation_0
                                                       timeStampNs:frame.timeStampNs];
      output.timeStamp = frame.timeStamp;
      frame = output;
    }
  }
#endif
  os_unfair_lock_lock(&_lock);
  for (id<ExternalVideoProcessingDelegate> processor in _processors) {
    frame = [processor onFrame:frame];
  }
  [_videoSource capturer:capturer didCaptureVideoFrame:frame];
  os_unfair_lock_unlock(&_lock);
}

@end
