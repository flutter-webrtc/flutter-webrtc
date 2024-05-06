#import "FlutterRTCVideoPlatformView.h"

@implementation FlutterRTCVideoPlatformView {
    CGSize _videoSize;
}

@synthesize videoRenderer = _videoRenderer;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        RTCMTLVideoView *videoView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:CGRectZero];
        videoView.delegate = self;
        videoView.videoContentMode = UIViewContentModeScaleAspectFit;
        _videoRenderer = videoView;
        [self addSubview:_videoRenderer];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    _videoRenderer.frame = bounds;
}

#pragma mark - RTC_OBJC_TYPE(RTCVideoViewDelegate)
- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
  if (videoView == _videoRenderer) {
      _videoSize = size;
  }
  [self setNeedsLayout];
}

@end
