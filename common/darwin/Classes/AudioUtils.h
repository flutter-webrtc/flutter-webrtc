#if TARGET_OS_IPHONE

#import <WebRTC/WebRTC.h>

@interface AudioUtils : NSObject
// Configures category and mode for the given direction. Does not activate.
+ (void)ensureAudioSessionWithRecording:(BOOL)recording;
// One balanced RTCAudioSession activation. Each successful call increments
// RTCAudioSession's activation count, so callers acquire once and release
// once. Returns NO when the system refused the activation.
+ (BOOL)activateAudioSession;
// The balanced release. RTCAudioSession decrements its count whether or not
// the system deactivation succeeds and whether or not the session is active,
// so the caller's reference is consumed either way.
+ (BOOL)deactivateAudioSession;
// needed for wired headphones to use headphone mic
+ (BOOL)selectAudioInput:(AVAudioSessionPort)type;
+ (void)setSpeakerphoneOn:(BOOL)enable;
+ (void)setSpeakerphoneOnButPreferBluetooth;
+ (void) setAppleAudioConfiguration:(NSDictionary*)configuration;
@end

#endif
