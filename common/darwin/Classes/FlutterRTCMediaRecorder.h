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

- (nullable instancetype)initWithMediaAtPath:(nonnull NSString *) path
                                  videoTrack:(nonnull RTCVideoTrack *) videoTrack;
// TODO: Audio
//                                  audioTrack:(nonnull RTCAudioTrack *) audioTrack;

- (bool)isComplete;

- (bool)startRecordingWithResult:(nonnull FlutterResult)result;

- (void)stopRecordingWithResult:(nonnull FlutterResult)result;

- (void)storeStartFrameInfo:(nonnull RTCVideoFrame*) frame;
- (void)queueFrame:(nonnull RTCVideoFrame*) frame;
- (bool)appendFrame:(nonnull RTCVideoFrame*) frame;

+ (bool)createCVPixelBufferFromFrame:(nonnull RTCVideoFrame*)frame
                            toBuffer:(CVPixelBufferRef _Nullable * _Nonnull)pixelBufferRef
                            fromPool:(CVPixelBufferPoolRef _Nullable) pool;
@end
