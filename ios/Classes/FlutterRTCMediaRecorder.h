//
//  FlutterRTCMediaRecorder.h
//  flutter_webrtc
//
//  Created by Matthew Evers on 11/18/21.
//

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif
#import <WebRTC/WebRTC.h>

@import CoreVideo;

@interface FlutterRTCMediaRecorder : NSObject<RTCVideoRenderer>

- (instancetype)initWithMediaAtPath:(NSString *) path videoTrack:(RTCVideoTrack *) track  result:(FlutterResult)result;

- (int)startRecording;

- (bool)stopRecording;

- (bool)initializeRecording:(RTCVideoFrame*) firstFrame;

- (void)queueFrame:(RTCVideoFrame*) frame;
- (bool)appendFrame:(RTCVideoFrame*) frame;

+ (bool)createCVPixelBufferFromFrame:(RTCVideoFrame*)frame toBuffer:(CVPixelBufferRef*)pixelBufferRef fromPool:(nullable CVPixelBufferPoolRef) pool;

@end
