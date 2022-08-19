#import <WebRTC/WebRTC.h>

@interface AudioUtils : NSObject

+ (void)ensureAudioSessionWithRecording:(BOOL)recording;
// needed for wired headphones to use headphone mic
+ (BOOL)setPreferredInput:(AVAudioSessionPort)type;

@end
