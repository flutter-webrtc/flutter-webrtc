#import "FlutterRTCVideoPlatformViewController.h"
#import "FlutterRTCVideoPlatformView.h"
#import "FlutterWebRTCPlugin.h"

@implementation FlutterRTCVideoPlatformViewController {
  FlutterRTCVideoPlatformView* _videoView;
  FlutterEventChannel* _eventChannel;
  bool _isFirstFrameRendered;
  CGSize _renderSize;
  RTCVideoRotation _rotation;
}

@synthesize messenger = _messenger;
@synthesize eventSink = _eventSink;
@synthesize viewId = _viewId;

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                   viewIdentifier:(int64_t)viewId
                            frame:(CGRect)frame {
  self = [super init];
  if (self) {
    _isFirstFrameRendered = false;
    _renderSize = CGSizeZero;
    _rotation = -1;
    _messenger = messenger;
    _videoView = [[FlutterRTCVideoPlatformView alloc] initWithFrame:frame];
    _viewId = viewId;
    /*Create Event Channel.*/
    _eventChannel = [FlutterEventChannel
        eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/PlatformViewId%lld", viewId]
             binaryMessenger:messenger];
    [_eventChannel setStreamHandler:self];
  }

  return self;
}

- (UIView*)view {
  return _videoView;
}

- (void)setVideoTrack:(RTCVideoTrack*)videoTrack {
  RTCVideoTrack* oldValue = self.videoTrack;
  if (oldValue == videoTrack) {
    return;
  }
  _videoTrack = videoTrack;
  _isFirstFrameRendered = false;
  if (!oldValue) {
    [oldValue removeRenderer:(id<RTCVideoRenderer>)self];
    _videoView.frame = CGRectZero;
  }
  if (videoTrack) {
    [videoTrack addRenderer:(id<RTCVideoRenderer>)self];
  }
}

#pragma mark - RTCVideoRenderer methods
- (void)renderFrame:(RTCVideoFrame*)frame {
  if (_renderSize.width != frame.width || _renderSize.height != frame.height ||
      !_isFirstFrameRendered) {
    if (self.eventSink) {
      postEvent(self.eventSink, @{
        @"event" : @"didPlatformViewChangeVideoSize",
        @"id" : @(self.viewId),
        @"width" : @(frame.width),
        @"height" : @(frame.height),
      });
    }
    _renderSize = CGSizeMake(frame.width, frame.height);
  }

  if (frame.rotation != _rotation || !_isFirstFrameRendered) {
    if (self.eventSink) {
      postEvent(self.eventSink, @{
        @"event" : @"didPlatformViewChangeRotation",
        @"id" : @(self.viewId),
        @"rotation" : @(frame.rotation),
      });
    }
    _rotation = frame.rotation;
  }

  if (!_isFirstFrameRendered) {
    if (self.eventSink) {
      postEvent(self.eventSink, @{@"event" : @"didFirstFrameRendered"});
    }
    self->_isFirstFrameRendered = true;
  }
    
  [_videoView renderFrame:frame];
}

/**
 * Sets the size of the video frame to render.
 *
 * @param size The size of the video frame to render.
 */
- (void)setSize:(CGSize)size {
    [_videoView setSize:size];
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
  _eventSink = sink;
  return nil;
}

@end
