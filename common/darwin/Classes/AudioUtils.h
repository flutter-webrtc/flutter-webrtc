#import <WebRTC/WebRTC.h>

@interface AudioUtils : NSObject

+ (void)ensureAudioSessionWithRecording:(BOOL)recording;
// needed for wired headphones to use headphone mic
+ (BOOL)selectAudioInput:(AVAudioSessionPort)type;
+ (void)setSpeakerphoneOn:(BOOL)enable;
+ (void)updateAudioRoute:(BOOL)speakerOn;
+ (void)deactiveRtcAudioSession;
@end
