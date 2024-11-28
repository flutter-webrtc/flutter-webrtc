#import <WebRTC/WebRTC.h>
#import "AudioProcessingAdapter.h"
#import "LocalTrack.h"

@interface LocalAudioTrack : NSObject <LocalTrack>

- (_Nonnull instancetype)initWithTrack:(RTCAudioTrack* _Nonnull)track;

@property(nonatomic, strong) RTCAudioTrack* _Nonnull audioTrack;

- (void)addRenderer:(_Nonnull id<RTC_OBJC_TYPE(RTCAudioRenderer)>)renderer;

- (void)removeRenderer:(_Nonnull id<RTC_OBJC_TYPE(RTCAudioRenderer)>)renderer;

- (void)addProcessing:(_Nonnull id<ExternalAudioProcessingDelegate>)processor;

- (void)removeProcessing:(_Nonnull id<ExternalAudioProcessingDelegate>)processor;

@end
