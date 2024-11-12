#import <WebRTC/WebRTC.h>

@interface LocalAudioTrack : NSObject

-(instancetype)initWithTrack:(RTCAudioTrack *)track;

@property (nonatomic, strong) RTCAudioTrack *track;


@end
