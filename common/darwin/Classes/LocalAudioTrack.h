#import <WebRTC/WebRTC.h>
#import "LocalTrack.h"

@interface LocalAudioTrack : NSObject<LocalTrack>

-(instancetype)initWithTrack:(RTCAudioTrack *)track;

@property (nonatomic, strong) RTCAudioTrack *audioTrack;

@end
