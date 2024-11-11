#import "AudioProcessingAdapter.h"
#import <WebRTC/RTCAudioRenderer.h>
#import <os/lock.h>

@implementation AudioProcessingAdapter {
    NSMutableArray<id<RTCAudioRenderer>> *renderers;
    os_unfair_lock _lock;
}

- (instancetype)init {
  self = [super init];
  if (self) {
      _lock = OS_UNFAIR_LOCK_INIT;
      renderers = [[NSMutableArray<id<RTCAudioRenderer>> alloc] init];
  }
  return self;
}

-(void)addAudioRenderer:(nonnull id<RTCAudioRenderer>)renderer {
    os_unfair_lock_lock(&_lock);
    [renderers addObject:renderer];
    os_unfair_lock_unlock(&_lock);
}

-(void)removeAudioRenderer:(nonnull id<RTCAudioRenderer>)renderer {
    os_unfair_lock_lock(&_lock);
    renderers = [[renderers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != renderer;
    }]] mutableCopy];
    os_unfair_lock_unlock(&_lock);
}

-(void)audioProcessingInitializeWithSampleRate : (size_t)sampleRateHz channels
                                                : (size_t)channels {
    os_unfair_lock_lock(&_lock);
    os_unfair_lock_unlock(&_lock);
}

-(AVAudioPCMBuffer *) toPCMBuffer:(RTC_OBJC_TYPE(RTCAudioBuffer) *)audioBuffer {

    AVAudioFormat *format =
    [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                     sampleRate: audioBuffer.frames * 100.0
                                       channels: (AVAudioChannelCount)audioBuffer.channels
                                    interleaved:NO];

   AVAudioPCMBuffer *pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format
                                                                frameCapacity:(AVAudioFrameCount)audioBuffer.frames];
    if (!pcmBuffer) {
      NSLog(@"Failed to create AVAudioPCMBuffer");
      return nil;
    }

    pcmBuffer.frameLength = (AVAudioFrameCount)audioBuffer.frames;
    
    for (int i = 0; i < audioBuffer.channels; i++) {
        float* sourceBuffer = [audioBuffer rawBufferForChannel:i];
        float* targetBuffer = (float*)pcmBuffer.floatChannelData[i];

        for (int frame = 0; frame < audioBuffer.frames; frame++) {
            targetBuffer[frame] = sourceBuffer[frame];
        }
    }


    return pcmBuffer;
}

-(void)audioProcessingProcess:(RTC_OBJC_TYPE(RTCAudioBuffer) *)audioBuffer {
    os_unfair_lock_lock(&_lock);
    
    NSEnumerator *enumerator = [renderers objectEnumerator];
    id<RTCAudioRenderer> renderer = nil;
    while(renderer = [enumerator nextObject]){
        //[renderer renderPCMBuffer:[self toPCMBuffer:audioBuffer]];
    }
    os_unfair_lock_unlock(&_lock);
}

-(void)audioProcessingRelease {
    os_unfair_lock_lock(&_lock);
    
    os_unfair_lock_unlock(&_lock);
}

@end
