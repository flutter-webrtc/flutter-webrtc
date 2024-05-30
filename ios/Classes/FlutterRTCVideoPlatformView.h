#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <WebRTC/WebRTC.h>

@interface FlutterRTCVideoPlatformView : UIView <RTC_OBJC_TYPE (RTCVideoViewDelegate)>

@property(nonatomic, readonly) __kindof UIView<RTC_OBJC_TYPE(RTCVideoRenderer)> *videoRenderer;

- (instancetype)initWithFrame:(CGRect)frame;

-(void)setObjectFit:(NSNumber *)index;

@end
