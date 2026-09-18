#import "FlutterRTCPictureInPictureController.h"

#if TARGET_OS_IPHONE

#import "FlutterRTCVideoPlatformView.h"

@implementation FlutterRTCPictureInPictureController {
  FlutterRTCVideoPlatformView* _contentView;
  AVPictureInPictureVideoCallViewController* _callViewController;
  AVPictureInPictureController* _pipController;
  UIView* _anchorView;
  CGSize _frameSize;
  CGFloat _aspectRatio;
}

@synthesize videoTrack = _videoTrack;

+ (BOOL)isSupported {
  return [AVPictureInPictureController isPictureInPictureSupported];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _frameSize = CGSizeZero;
    _aspectRatio = 0;
    _callViewController = [[AVPictureInPictureVideoCallViewController alloc] init];
    _contentView = [[FlutterRTCVideoPlatformView alloc] initWithFrame:_callViewController.view.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _contentView.videoGravity = AVLayerVideoGravityResizeAspect;
    [_callViewController.view addSubview:_contentView];
    [self updatePreferredContentSize];
  }
  return self;
}

- (UIView*)anchorViewInView:(UIView*)rootView frame:(CGRect)frame {
  if (!_anchorView) {
    _anchorView = [[UIView alloc] initWithFrame:frame];
    _anchorView.backgroundColor = UIColor.clearColor;
    _anchorView.userInteractionEnabled = NO;
  }
  if (_anchorView.superview != rootView) {
    [_anchorView removeFromSuperview];
    [rootView insertSubview:_anchorView atIndex:0];
  }
  _anchorView.frame = frame;
  return _anchorView;
}

- (void)configureWithSourceView:(UIView*)sourceView
                    aspectRatio:(CGFloat)aspectRatio
                      autoEnter:(BOOL)autoEnter
                   videoGravity:(AVLayerVideoGravity)videoGravity {
  _aspectRatio = aspectRatio;
  _contentView.videoGravity = videoGravity;
  [self updatePreferredContentSize];

  AVPictureInPictureControllerContentSource* source =
      [[AVPictureInPictureControllerContentSource alloc]
          initWithActiveVideoCallSourceView:sourceView
                      contentViewController:_callViewController];
  if (!_pipController) {
    _pipController = [[AVPictureInPictureController alloc] initWithContentSource:source];
    _pipController.delegate = self;
  } else {
    _pipController.contentSource = source;
  }
  _pipController.canStartPictureInPictureAutomaticallyFromInline = autoEnter;
}

- (BOOL)start {
  if (!_pipController) {
    return NO;
  }
  if (_pipController.isPictureInPictureActive) {
    return YES;
  }
  if (!_pipController.isPictureInPicturePossible) {
    return NO;
  }
  [_pipController startPictureInPicture];
  return YES;
}

- (void)stop {
  if (_pipController.isPictureInPictureActive) {
    [_pipController stopPictureInPicture];
  }
}

- (BOOL)isActive {
  return _pipController != nil && _pipController.isPictureInPictureActive;
}

- (void)dispose {
  [self stop];
  self.videoTrack = nil;
  _pipController.delegate = nil;
  _pipController = nil;
  [_anchorView removeFromSuperview];
  _anchorView = nil;
  _stateHandler = nil;
}

- (void)setVideoTrack:(RTCVideoTrack*)videoTrack {
  RTCVideoTrack* oldValue = _videoTrack;
  if (oldValue == videoTrack) {
    return;
  }
  if (oldValue) {
    [oldValue removeRenderer:self];
  }
  _videoTrack = videoTrack;
  _frameSize = CGSizeZero;
  if (videoTrack) {
    [videoTrack addRenderer:self];
  }
}

- (void)updatePreferredContentSize {
  CGSize size;
  if (_aspectRatio > 0) {
    size = CGSizeMake(round(1000 * _aspectRatio), 1000);
  } else if (_frameSize.width > 0 && _frameSize.height > 0) {
    size = _frameSize;
  } else {
    size = CGSizeMake(1280, 720);
  }
  _callViewController.preferredContentSize = size;
}

- (void)emitState:(NSString*)state error:(NSString*)error {
  FlutterRTCPictureInPictureStateHandler handler = self.stateHandler;
  if (handler) {
    handler(state, error);
  }
}

#pragma mark - RTCVideoRenderer

- (void)setSize:(CGSize)size {
}

- (void)renderFrame:(nullable RTCVideoFrame*)frame {
  if (!frame || frame.width <= 0 || frame.height <= 0) {
    return;
  }
  BOOL rotated = frame.rotation == RTCVideoRotation_90 || frame.rotation == RTCVideoRotation_270;
  CGSize size = rotated ? CGSizeMake(frame.height, frame.width) : CGSizeMake(frame.width, frame.height);
  if (!CGSizeEqualToSize(size, _frameSize)) {
    _frameSize = size;
    if (_aspectRatio <= 0) {
      __weak FlutterRTCPictureInPictureController* weakSelf = self;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updatePreferredContentSize];
      });
    }
  }
  [_contentView renderFrame:frame];
}

#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:
    (AVPictureInPictureController*)pictureInPictureController {
  [self emitState:@"willStart" error:nil];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:
    (AVPictureInPictureController*)pictureInPictureController {
  [self emitState:@"started" error:nil];
}

- (void)pictureInPictureController:(AVPictureInPictureController*)pictureInPictureController
    failedToStartPictureInPictureWithError:(NSError*)error {
  [self emitState:@"failed" error:error.localizedDescription];
}

- (void)pictureInPictureControllerWillStopPictureInPicture:
    (AVPictureInPictureController*)pictureInPictureController {
  [self emitState:@"willStop" error:nil];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:
    (AVPictureInPictureController*)pictureInPictureController {
  [self emitState:@"stopped" error:nil];
}

- (void)pictureInPictureController:(AVPictureInPictureController*)pictureInPictureController
    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:
        (void (^)(BOOL))completionHandler {
  [self emitState:@"restoreUserInterface" error:nil];
  completionHandler(YES);
}

@end

#endif
