#import "AudioUtils.h"

#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#endif

@implementation AudioUtils

+ (void)ensureAudioSessionWithRecording:(BOOL)recording {
#if TARGET_OS_IPHONE
  AVAudioSession *session = [AVAudioSession sharedInstance];
  AVAudioSessionCategory category = AVAudioSessionCategoryPlayback;
  if (recording) {
    category = AVAudioSessionCategoryPlayAndRecord;
  }
  if (recording && session.category != AVAudioSessionCategoryPlayAndRecord &&
      session.category != AVAudioSessionCategoryMultiRoute) {
    // require audio session to be either PlayAndRecord or MultiRoute
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
      mode:AVAudioSessionModeVoiceChat
      options:AVAudioSessionCategoryOptionDefaultToSpeaker |
        AVAudioSessionCategoryOptionAllowBluetooth |
        AVAudioSessionCategoryOptionAllowBluetoothA2DP
      error:nil];
  } else if (!recording && (session.category == AVAudioSessionCategoryAmbient
      || session.category == AVAudioSessionCategorySoloAmbient)) {
    // upgrade from ambient if needed
    [session setCategory:AVAudioSessionCategoryPlayback
      mode:AVAudioSessionModeVoiceChat
      options:AVAudioSessionCategoryOptionDefaultToSpeaker
      error:nil];
  }
#endif
}

@end