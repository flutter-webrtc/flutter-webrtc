#import "AudioUtils.h"
#import <WebRTC/WebRTC.h>

#if TARGET_OS_IPHONE
#import <AVFoundation/AVFoundation.h>
#endif

@implementation AudioUtils

+ (void)ensureAudioSessionWithRecording:(BOOL)recording {
#if TARGET_OS_IPHONE
  RTCAudioSession *session = [RTCAudioSession sharedInstance];
  // we also need to set default WebRTC audio configuration, since it may be activated after
  // this method is called
  RTCAudioSessionConfiguration *config = [RTCAudioSessionConfiguration webRTCConfiguration];
  // require audio session to be either PlayAndRecord or MultiRoute
  if (recording && session.category != AVAudioSessionCategoryPlayAndRecord &&
      session.category != AVAudioSessionCategoryMultiRoute) {
    config.category = AVAudioSessionCategoryPlayAndRecord;
    config.categoryOptions = AVAudioSessionCategoryOptionDefaultToSpeaker |
        AVAudioSessionCategoryOptionAllowBluetooth |
        AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    [session setCategory:config.category
      withOptions:config.categoryOptions
      error:nil];
    [session setMode:config.mode error:nil];
  } else if (!recording && (session.category == AVAudioSessionCategoryAmbient
      || session.category == AVAudioSessionCategorySoloAmbient)) {
    config.category = AVAudioSessionCategoryPlayback;
    config.categoryOptions = 0;

    // upgrade from ambient if needed
    [session setCategory:config.category
      withOptions:config.categoryOptions
      error:nil];
    [session setMode:config.mode error:nil];
  }
#endif
}

+ (void)setPreferHeadphoneInput {
#if TARGET_OS_IPHONE
  AVAudioSession *session = [AVAudioSession sharedInstance];
  AVAudioSessionPortDescription *inputPort = nil;
  for (AVAudioSessionPortDescription *port in session.availableInputs) {
    if ([port.portType isEqualToString:AVAudioSessionPortHeadphones]) {
      inputPort = port;
      break;
    }
  }
  if (inputPort != nil) {
    [session setPreferredInput:inputPort error:nil];
  }
#endif
}

@end