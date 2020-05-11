
//
//  FlutterRTCAudioRecorder.h
//  Pods
//
//  Created by Yonatan Naor on 21/03/2020.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ OnRecordingStopped)(bool);

@interface FlutterRTCAudioRecorder : NSObject<AVAudioRecorderDelegate>

-(id) initWithPath:(NSString *) path;

-(void)stop:(OnRecordingStopped) callback;

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag;

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
