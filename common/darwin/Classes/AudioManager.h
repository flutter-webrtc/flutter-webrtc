#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@interface AudioManager : NSObject

@property(nonatomic, strong) RTCDefaultAudioProcessingModule *audioProcessingModule;

+ (instancetype)sharedInstance;

-(void) addLocalAudioRenderer:(nonnull id<RTCAudioRenderer>)renderer;

-(void) removeLocalAudioRenderer:(nonnull id<RTCAudioRenderer>)renderer;

@end
