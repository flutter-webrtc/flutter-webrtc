@interface AudioUtils : NSObject

+ (void)ensureAudioSessionWithRecording:(BOOL)recording;
// needed for wired headphones to use headphone mic
+ (void)setPreferHeadphoneInput;

@end
