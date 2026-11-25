#import "VideoProcessingAdapter.h"
#import <os/lock.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

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
  os_unfair_lock_lock(&_lock);
  for (id<ExternalVideoProcessingDelegate> processor in _processors) {
    frame = [processor onFrame:frame];
  }
  [_videoSource capturer:capturer didCaptureVideoFrame:frame];
  os_unfair_lock_unlock(&_lock);
}

@end

#if TARGET_OS_IOS
@interface CameraVideoProcessingAdapter ()
@property(atomic, assign) UIInterfaceOrientation lockedOrientation;
@end

@implementation CameraVideoProcessingAdapter

- (BOOL)setCaptureOrientationNamed:(NSString *)name {
  if (!name) {
    self.lockedOrientation = UIInterfaceOrientationUnknown;
  } else if ([name isEqual:@"portraitUp"]) {
    self.lockedOrientation = UIInterfaceOrientationPortrait;
  } else if ([name isEqual:@"portraitDown"]) {
    self.lockedOrientation = UIInterfaceOrientationPortraitUpsideDown;
  } else if ([name isEqual:@"landscapeLeft"]) {
    self.lockedOrientation = UIInterfaceOrientationLandscapeLeft;
  } else if ([name isEqual:@"landscapeRight"]) {
    self.lockedOrientation = UIInterfaceOrientationLandscapeRight;
  } else {
    return NO;
  }
  return YES;
}

- (void)capturer:(RTCVideoCapturer *)capturer didCaptureVideoFrame:(RTCVideoFrame *)frame {
  // Use RTCCameraVideoCapturer's lens-dependent interface orientation mapping.
  // While unlocked, pass through the SDK's original frame and orientation.
  RTCVideoRotation rotation = frame.rotation;
  switch (self.lockedOrientation) {
    case UIInterfaceOrientationPortrait:
      rotation = RTCVideoRotation_90;
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      rotation = RTCVideoRotation_270;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      rotation = self.cameraPosition == AVCaptureDevicePositionFront ? RTCVideoRotation_0 : RTCVideoRotation_180;
      break;
    case UIInterfaceOrientationLandscapeRight:
      rotation = self.cameraPosition == AVCaptureDevicePositionFront ? RTCVideoRotation_180 : RTCVideoRotation_0;
      break;
    case UIInterfaceOrientationUnknown:
      break;
  }
  if (rotation != frame.rotation) {
    RTCVideoFrame *oriented = [[RTCVideoFrame alloc] initWithBuffer:frame.buffer
                                                           rotation:rotation
                                                        timeStampNs:frame.timeStampNs];
    oriented.timeStamp = frame.timeStamp;
    frame = oriented;
  }
  [super capturer:capturer didCaptureVideoFrame:frame];
}

@end
#endif
