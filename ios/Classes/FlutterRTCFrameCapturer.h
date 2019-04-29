#import <Flutter/Flutter.h>
#import <WebRTC/WebRTC.h>

@interface FlutterRTCFrameCapturer : NSObject<RTCVideoRenderer>

- (instancetype)initWithTrack:(RTCVideoTrack *) track toPath:(NSString *) path result:(FlutterResult)result;

@end
