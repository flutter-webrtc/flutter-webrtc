#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@protocol ExternalVideoProcessingDelegate <RTCVideoCapturerDelegate>
// - (RTC_OBJC_TYPE(RTCVideoFrame) * _Nonnull)onFrame:(RTC_OBJC_TYPE(RTCVideoFrame) * _Nonnull)frame;
- (void)setSink:( _Nonnull id<RTCVideoCapturerDelegate> ) __strong sink;
@end

@interface VideoProcessingAdapter : NSObject <RTCVideoCapturerDelegate>

- (_Nonnull instancetype)initWithRTCVideoSource:(RTCVideoSource* _Nonnull)source;

- (void)addProcessing:(_Nonnull id<ExternalVideoProcessingDelegate>)processor;

- (void)removeProcessing:(_Nonnull id<ExternalVideoProcessingDelegate>)processor;

- (RTCVideoSource* _Nonnull) source;

@end
