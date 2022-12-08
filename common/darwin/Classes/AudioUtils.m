#if TARGET_OS_IPHONE
#import "AudioUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioUtils

+ (void)ensureAudioSessionWithRecording:(BOOL)recording {
  RTCAudioSession* session = [RTCAudioSession sharedInstance];
  // we also need to set default WebRTC audio configuration, since it may be activated after
  // this method is called
  RTCAudioSessionConfiguration* config = [RTCAudioSessionConfiguration webRTCConfiguration];
  // require audio session to be either PlayAndRecord or MultiRoute
  if (recording && session.category != AVAudioSessionCategoryPlayAndRecord &&
      session.category != AVAudioSessionCategoryMultiRoute) {
    config.category = AVAudioSessionCategoryPlayAndRecord;
    config.categoryOptions =
        AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    config.mode = AVAudioSessionModeVoiceChat;

    [session lockForConfiguration];
    [session setCategory:config.category withOptions:config.categoryOptions error:nil];
    [session setMode:config.mode error:nil];
    [session unlockForConfiguration];
  } else if (!recording || (session.category == AVAudioSessionCategoryAmbient ||
                            session.category == AVAudioSessionCategorySoloAmbient)) {
    config.category = AVAudioSessionCategoryPlayback;
    config.categoryOptions = 0;
    config.mode = AVAudioSessionModeDefault;

    // upgrade from ambient if needed
    [session lockForConfiguration];
    [session setCategory:config.category withOptions:config.categoryOptions error:nil];
    [session setMode:config.mode error:nil];
    [session unlockForConfiguration];
  }
}

+ (BOOL)selectAudioInput:(AVAudioSessionPort)type {
  RTCAudioSession* rtcSession = [RTCAudioSession sharedInstance];
  AVAudioSessionPortDescription* inputPort = nil;
  for (AVAudioSessionPortDescription* port in rtcSession.session.availableInputs) {
    if ([port.portType isEqualToString:type]) {
      inputPort = port;
      break;
    }
  }
  if (inputPort != nil) {
    NSError* errOut = nil;
    [rtcSession lockForConfiguration];
    [rtcSession setPreferredInput:inputPort error:&errOut];
    [rtcSession unlockForConfiguration];
    if (errOut != nil) {
      return NO;
    }
    return YES;
  }
  return NO;
}

+ (void)setSpeakerphoneOn:(BOOL)enable {
  RTCAudioSession* session = [RTCAudioSession sharedInstance];
  RTCAudioSessionConfiguration* config = [RTCAudioSessionConfiguration webRTCConfiguration];
  [session lockForConfiguration];
  NSError* error = nil;
  if (!enable) {
    [session setMode:config.mode error:&error];
    BOOL success = [session setCategory:config.category
                            withOptions:AVAudioSessionCategoryOptionAllowAirPlay |
                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP |
                                        AVAudioSessionCategoryOptionAllowBluetooth
                                  error:&error];

    success = [session.session overrideOutputAudioPort:kAudioSessionOverrideAudioRoute_None
                                                 error:&error];
    if (!success)
      NSLog(@"Port override failed due to: %@", error);

    success = [session setActive:YES error:&error];
    if (!success)
      NSLog(@"Audio session override failed: %@", error);
    else
      NSLog(@"AudioSession override via Earpiece/Headset is successful ");

  } else {
    [session setMode:config.mode error:&error];
    BOOL success = [session setCategory:config.category
                            withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker |
                                        AVAudioSessionCategoryOptionAllowAirPlay |
                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP |
                                        AVAudioSessionCategoryOptionAllowBluetooth
                                  error:&error];

    success = [session overrideOutputAudioPort:kAudioSessionOverrideAudioRoute_Speaker
                                         error:&error];
    if (!success)
      NSLog(@"Port override failed due to: %@", error);

    success = [session setActive:YES error:&error];
    if (!success)
      NSLog(@"Audio session override failed: %@", error);
    else
      NSLog(@"AudioSession override via Loudspeaker is successful ");
  }
  [session unlockForConfiguration];
}

+ (void)deactiveRtcAudioSession {
  NSError* error = nil;
  [[AVAudioSession sharedInstance] setActive:NO
                                 withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                       error:&error];
}

@end
#endif
