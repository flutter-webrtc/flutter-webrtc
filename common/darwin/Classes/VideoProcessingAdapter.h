#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@protocol ExternalVideoFrameProcessing
- (void)processVideoFrame:(RTCVideoFrame *)frame;
@end

@interface VideoProcessingAdapter : NSObject<RTCVideoCapturerDelegate>

- (instancetype)initWithRTCVideoSource:(RTCVideoSource *)source;

-(void)addProcessing:(id<ExternalVideoFrameProcessing>)processor;

-(void)removeProcessing:(id<ExternalVideoFrameProcessing>)processor;

@end
