#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif
#import <WebRTC/WebRTC.h>

@interface FlutterRTCFrameCapturer : NSObject<RTCVideoRenderer>

- (instancetype)initWithTrack:(RTCVideoTrack *) track toPath:(NSString *) path result:(FlutterResult)result;

#if TARGET_OS_IPHONE
+ (UIImage *)convertFrameToUIImage:(RTCVideoFrame *)frame;
#endif

@end
