
//
//  FlutterRTCAudioRecorder.m
//  Pods
//
//  Created by Yonatan Naor on 21/03/2020.
//

#import "FlutterRTCAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

AVAudioSession* recordingSession;
AVAudioRecorder *audioRecorder;

@implementation FlutterRTCAudioRecorder

OnRecordingStopped onRecordingStopped;

-(id) initWithPath:(NSString *) path {
    self = [super init];
    recordingSession = [[AVAudioSession alloc] init];
    
    [recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [recordingSession setActive:true error:nil];
    [recordingSession requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSError* error;
            NSDictionary* recordingSettings = @{
                @"AVFormatIDKey": [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                @"AVSampleRateKey": @12000,
                @"AVNumberOfChannelsKey": @1,
                @"AVEncoderAudioQualityKey": [NSNumber numberWithInt:AVAudioQualityMedium]
            };
            audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:path] settings: recordingSettings error:&error];
            
            [audioRecorder prepareToRecord];
            [audioRecorder record];
        } else {
            @throw [NSException
            exceptionWithName:@"RecordigPermissionDenied"
            reason:@"Recording permission not granted"
            userInfo:nil];
        }
    }];
    return self;
}

-(void)stop:(OnRecordingStopped) callback {
    [recordingSession setActive:false error:nil];
    onRecordingStopped = callback;
    if (audioRecorder != nil) {
        [audioRecorder stop];
    }
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag {
    if (onRecordingStopped != nil) {
        onRecordingStopped(flag);
    }
    onRecordingStopped = nil;
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error {
        NSLog(@"Encode Error occurred");
}

@end
