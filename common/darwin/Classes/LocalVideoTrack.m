#import "LocalVideoTrack.h"

@implementation LocalVideoTrack {
    RTCVideoTrack *_track;
    VideoProcessingAdapter *_processing;
}

@synthesize track = _track;
@synthesize processing = _processing;

-(instancetype)initWithTrack:(RTCVideoTrack *)track
             videoProcessing:(VideoProcessingAdapter *)processing {
    self = [super init];
    if (self) {
        _track = track;
        _processing = processing;
    }
    return self;
}

@end
