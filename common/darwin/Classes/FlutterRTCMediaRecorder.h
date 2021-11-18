#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif
#import <WebRTC/WebRTC.h>

@interface FlutterRTCMediaRecorder : NSObject<RTCVideoRenderer>

- (instancetype)initWithMedia:(NSString *) path video:(RTCVideoTrack *) videoTrack result:(FlutterResult)result;


@end
