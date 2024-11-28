#import "LocalVideoTrack.h"

@implementation LocalVideoTrack {
  RTCVideoTrack* _track;
  VideoProcessingAdapter* _processing;
}

@synthesize videoTrack = _track;
@synthesize processing = _processing;

- (instancetype)initWithTrack:(RTCVideoTrack*)track
              videoProcessing:(VideoProcessingAdapter*)processing {
  self = [super init];
  if (self) {
    _track = track;
    _processing = processing;
  }
  return self;
}

- (instancetype)initWithTrack:(RTCVideoTrack*)track {
  return [self initWithTrack:track videoProcessing:nil];
}

- (RTCMediaStreamTrack*)track {
  return _track;
}

/** Register a renderer that will render all frames received on this track. */
- (void)addRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)renderer {
  [_track addRenderer:renderer];
}

/** Deregister a renderer. */
- (void)removeRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)renderer {
  [_track removeRenderer:renderer];
}

- (void)addProcessing:(id<ExternalVideoProcessingDelegate>)processor {
  [_processing addProcessing:processor];
}

- (void)removeProcessing:(id<ExternalVideoProcessingDelegate>)processor {
  [_processing removeProcessing:processor];
}

@end
