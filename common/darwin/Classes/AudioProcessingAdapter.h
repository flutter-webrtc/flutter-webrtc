#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@interface AudioProcessingAdapter : NSObject<RTCAudioCustomProcessingDelegate>

-(nonnull instancetype)init;

-(void)addAudioRenderer:(nonnull id<RTCAudioRenderer>)renderer;

-(void)removeAudioRenderer:(nonnull id<RTCAudioRenderer>)renderer;

@end
