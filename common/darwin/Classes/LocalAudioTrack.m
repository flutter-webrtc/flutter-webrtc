#import "LocalAudioTrack.h"

@implementation LocalAudioTrack {
    RTCAudioTrack *_track;
}

@synthesize track = _track;

- (instancetype)initWithTrack:(RTCAudioTrack *)track {
    self = [super init];
    if (self) {
        _track = track;
    }
    return self;
}

- (void)addRenderer:(id<RTC_OBJC_TYPE(RTCAudioRenderer)>)renderer {

}

- (void)removeRenderer:(id<RTC_OBJC_TYPE(RTCAudioRenderer)>)renderer {

}

- (void)removeAllRenderers {

}

@end