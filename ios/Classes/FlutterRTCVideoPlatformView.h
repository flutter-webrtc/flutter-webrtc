#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <WebRTC/WebRTC.h>

@interface FlutterRTCVideoPlatformView : UIView

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame;

- (instancetype _Nonnull)initWithFrame:(CGRect)frame;

- (void)setSize:(CGSize)size;

@end
