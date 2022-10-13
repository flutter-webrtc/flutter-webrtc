#import "AudioUtils.h"

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
        config.categoryOptions = AVAudioSessionCategoryOptionAllowBluetooth |
        AVAudioSessionCategoryOptionAllowBluetoothA2DP;
        
        [session lockForConfiguration];
        [session setCategory:config.category
                 withOptions:config.categoryOptions
                       error:nil];
        [session setMode:config.mode error:nil];
        [session unlockForConfiguration];
    } else if (!recording && (session.category == AVAudioSessionCategoryAmbient
                              || session.category == AVAudioSessionCategorySoloAmbient)) {
        config.category = AVAudioSessionCategoryPlayback;
        config.categoryOptions = 0;
        
        // upgrade from ambient if needed
        [session lockForConfiguration];
        [session setCategory:config.category
                 withOptions:config.categoryOptions
                       error:nil];
        [session setMode:config.mode error:nil];
        [session unlockForConfiguration];
    }
#endif
}

+ (BOOL)selectAudioInput:(AVAudioSessionPort)type {
#if TARGET_OS_IPHONE
    RTCAudioSession *rtcSession = [RTCAudioSession sharedInstance];
    AVAudioSessionPortDescription *inputPort = nil;
    for (AVAudioSessionPortDescription *port in rtcSession.session.availableInputs) {
        if ([port.portType isEqualToString:type]) {
            inputPort = port;
            break;
        }
    }
    if (inputPort != nil) {
        NSError *errOut = nil;
        [rtcSession lockForConfiguration];
        [rtcSession setPreferredInput:inputPort error:&errOut];
        [rtcSession unlockForConfiguration];
        if(errOut != nil) {
            return NO;
        }
        return YES;
    }
#endif
    return NO;
}

+ (void)setSpeakerphoneOn:(BOOL)enable {
#if TARGET_OS_IPHONE
    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    RTCAudioSessionConfiguration *config = [RTCAudioSessionConfiguration webRTCConfiguration];
    [session lockForConfiguration];
    NSError *error = nil;
    if(!enable) {
        [session setCategory:config.category
                 withOptions:config.categoryOptions
                       error:&error];
        [session setPreferredOutputNumberOfChannels:0 error:nil];
        BOOL success = [session setActive:YES error:&error];
        if (!success) NSLog(@"Audio session override failed: %@", error);
        else NSLog(@"AudioSession override via Earpiece/Headset is successful ");
    } else {
        BOOL success = [session setCategory:config.category
                                withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                      error:&error];
        [session setPreferredOutputNumberOfChannels:0 error:nil];
        if (!success)  NSLog(@"Port override failed due to: %@", error);
        success = [session setActive:YES error:&error];
        if (!success) NSLog(@"Audio session override failed: %@", error);
        else NSLog(@"AudioSession override via Loudspeaker is successful ");
    }
    [session unlockForConfiguration];
#endif
}

+ (void)updateAudioRoute:(BOOL)speakerOn {
    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    NSError *error = nil;
    [session lockForConfiguration];
    if(speakerOn) {
        [session overrideOutputAudioPort:[AVAudioSessionPortBuiltInSpeaker intValue] error: &error];
        [session.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        
        [session setMode:AVAudioSessionModeVoiceChat error: &error];
    } else {
        [session overrideOutputAudioPort:[AVAudioSessionPortHeadphones intValue] error:&error];
        [session.session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        [session setMode:AVAudioSessionModeVoiceChat error: &error];
    }
    [session unlockForConfiguration];
}

+ (void)diactiveRtcAudioSession {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
}

@end
