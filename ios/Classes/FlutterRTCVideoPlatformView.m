#import "FlutterRTCVideoPlatformView.h"

@implementation FlutterRTCVideoPlatformView {
    CGSize _videoSize;
}

@synthesize videoRenderer = _videoRenderer;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        RTCMTLVideoView *videoView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:CGRectZero];
        videoView.delegate = self;
        _videoRenderer = videoView;
        [self addSubview:_videoRenderer];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    if (_videoSize.width > 0 && _videoSize.height > 0) {
        CGRect remoteVideoFrame =
        AVMakeRectWithAspectRatioInsideRect(_videoSize, bounds);
        CGFloat scale = 1;
        if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
            scale = bounds.size.height / remoteVideoFrame.size.height;
        } else {
            scale = bounds.size.width / remoteVideoFrame.size.width;
        }
        remoteVideoFrame.size.height *= scale;
        remoteVideoFrame.size.width *= scale;
        _videoRenderer.frame = remoteVideoFrame;
        _videoRenderer.center =
        CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        _videoRenderer.frame = bounds;
    }
}

#pragma mark - RTC_OBJC_TYPE(RTCVideoViewDelegate)
- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
  if (videoView == _videoRenderer) {
      _videoSize = size;
  }
  [self setNeedsLayout];
}

@end
