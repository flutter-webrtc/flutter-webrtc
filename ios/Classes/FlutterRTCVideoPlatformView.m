#import "FlutterRTCVideoPlatformView.h"

@implementation FlutterRTCVideoPlatformView {
    CGSize _videoSize;
    RTCMTLVideoView *_videoView;
}

@synthesize videoRenderer = _videoRenderer;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _videoView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:CGRectZero];
        _videoView.videoContentMode = UIViewContentModeScaleAspectFit;
        _videoView.delegate = self;
        _videoRenderer = _videoView;
        self.opaque = NO;
        [self addSubview:_videoRenderer];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    _videoRenderer.frame = bounds;
}

-(void)setObjectFit:(NSNumber *)index {
    if ([index intValue] == 0) {
        _videoView.videoContentMode = UIViewContentModeScaleAspectFit;
    } else if([index intValue] == 1) {
        // for Cover mode
        _videoView.contentMode = UIViewContentModeScaleAspectFit;
        _videoView.videoContentMode = UIViewContentModeScaleAspectFill;
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
