#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@protocol ExternalVideoProcessingDelegate
- (RTC_OBJC_TYPE(RTCVideoFrame) * _Nonnull)onFrame:(RTC_OBJC_TYPE(RTCVideoFrame) * _Nonnull)frame;
@end

@interface VideoProcessingAdapter : NSObject <RTCVideoCapturerDelegate>

- (_Nonnull instancetype)initWithRTCVideoSource:(RTCVideoSource* _Nonnull)source;

#if TARGET_OS_IOS
// Camera-only opt-in. With both dimensions set, output has that fixed size.
- (nonnull instancetype)initWithRTCVideoSource:(RTCVideoSource *_Nonnull)source
                             cameraConstraints:(NSDictionary *_Nonnull)constraints;
#endif
- (CMVideoDimensions)trackDimensionsForCaptureDimensions:(CMVideoDimensions)captureDimensions;

- (void)addProcessing:(_Nonnull id<ExternalVideoProcessingDelegate>)processor;

- (void)removeProcessing:(_Nonnull id<ExternalVideoProcessingDelegate>)processor;

- (RTCVideoSource* _Nonnull) source;

@end
