#import <WebRTC/WebRTC.h>
#if TARGET_OS_IPHONE
@interface FlutterRPScreenRecorder : RTCVideoCapturer

-(void)startCapture;

-(void)stopCapture;

@end
#endif
