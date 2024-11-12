#import <WebRTC/WebRTC.h>
#import "VideoProcessingAdapter.h"

@interface LocalVideoTrack : NSObject

-(instancetype)initWithTrack:(RTCVideoTrack *)track
             videoProcessing:(VideoProcessingAdapter *)processing;

@property (nonatomic, strong) RTCVideoTrack *track;
@property (nonatomic, strong) VideoProcessingAdapter *processing;

@end
