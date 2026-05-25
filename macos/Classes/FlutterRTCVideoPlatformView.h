#import <AVFoundation/AVFoundation.h>
#import <FlutterMacOS/FlutterMacOS.h>
#import <WebRTC/WebRTC.h>

@interface FlutterRTCVideoPlatformView : NSView

- (void)renderFrame:(nullable RTC_OBJC_TYPE(RTCVideoFrame) *)frame;

- (instancetype _Nonnull)initWithFrame:(NSRect)frame;

- (void)setSize:(CGSize)size;

@end
