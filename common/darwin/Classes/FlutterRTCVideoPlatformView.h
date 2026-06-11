#import "FlutterRTCVideoPlatformTypes.h"

#import <AVFoundation/AVFoundation.h>
#import <WebRTC/WebRTC.h>

@interface FlutterRTCVideoPlatformView : FlutterRTCVideoPlatformNativeView

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame;

- (instancetype _Nonnull)initWithFrame:(FlutterRTCVideoPlatformFrame)frame;

- (void)setSize:(CGSize)size;

@end
