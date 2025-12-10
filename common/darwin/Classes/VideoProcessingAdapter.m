#import "VideoProcessingAdapter.h"
#import <os/lock.h>

@implementation VideoProcessingAdapter {
  RTCVideoSource* _videoSource;
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

- (RTCVideoSource* _Nonnull) source {
    return _videoSource;
}

- (void)addProcessing:(id<ExternalVideoProcessingDelegate>)processor {
  os_unfair_lock_lock(&_lock);
  _processors = [_processors arrayByAddingObject:processor];
  [self sanitizeProcessingChain];
  os_unfair_lock_unlock(&_lock);
}

- (void)removeProcessing:(id<ExternalVideoProcessingDelegate>)processor {
  os_unfair_lock_lock(&_lock);
  _processors = [_processors
      filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,
                                                                        NSDictionary* bindings) {
        return evaluatedObject != processor;
      }]];
  [self sanitizeProcessingChain];
  os_unfair_lock_unlock(&_lock);
}

- (void)setSize:(CGSize)size {
  _frameSize = size;
}

- (void)capturer:(RTC_OBJC_TYPE(RTCVideoCapturer) *)capturer
    didCaptureVideoFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
  os_unfair_lock_lock(&_lock);
  id<ExternalVideoProcessingDelegate> firstProcessor = [_processors firstObject];
  if (firstProcessor != nil) {
    [firstProcessor capturer:capturer didCaptureVideoFrame:frame];
  } else {
    [_videoSource capturer:capturer didCaptureVideoFrame:frame];
  }
  os_unfair_lock_unlock(&_lock);
}

- (void)sanitizeProcessingChain {
  id<ExternalVideoProcessingDelegate> currentProcessor = nil;
  for (id<ExternalVideoProcessingDelegate> processor in _processors) {
    if (currentProcessor == nil) {
      currentProcessor = processor;
      continue;
    }
    
    [currentProcessor setSink:processor];
    currentProcessor = processor;
  }
  if (currentProcessor != nil) {
    [currentProcessor setSink:_videoSource];
  }
}

@end
