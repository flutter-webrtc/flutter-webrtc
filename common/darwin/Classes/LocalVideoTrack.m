#import "LocalVideoTrack.h"

@implementation LocalVideoTrack {
    RTCVideoTrack *_track;
    VideoProcessingAdapter *_processing;
}

@synthesize videoTrack = _track;
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

-(instancetype)initWithTrack:(RTCVideoTrack *)track {
    return [self initWithTrack:track videoProcessing:nil];
}

-(RTCMediaStreamTrack *) track {
    return _track;
}

@end
