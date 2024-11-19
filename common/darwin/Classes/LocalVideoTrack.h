#import <WebRTC/WebRTC.h>
#import "LocalTrack.h"
#import "VideoProcessingAdapter.h"

@interface LocalVideoTrack : NSObject<LocalTrack>

-(instancetype)initWithTrack:(RTCVideoTrack *)track;

-(instancetype)initWithTrack:(RTCVideoTrack *)track
             videoProcessing:(VideoProcessingAdapter *)processing;

@property (nonatomic, strong) RTCVideoTrack *videoTrack;

@property (nonatomic, strong) VideoProcessingAdapter *processing;

- (void)addRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)renderer;

- (void)removeRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)renderer;

-(void)addProcessing:(id<ExternalVideoFrameProcessing>)processor;

-(void)removeProcessing:(id<ExternalVideoFrameProcessing>)processor;

@end
