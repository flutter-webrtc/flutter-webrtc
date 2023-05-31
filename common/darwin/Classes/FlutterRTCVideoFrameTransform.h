#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

#import "FlutterRTCVideoRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RTCVideoFrameTransform : NSObject

+ (nullable NSData *)transform:(RTCVideoFrame *)frame format:(RTCVideoFrameFormat)format;
+ (nullable NSData *)videoFrameToJPEG:(RTCVideoFrame *)frame;
+ (nullable CVPixelBufferRef)convertToCVPixelBuffer:(RTCVideoFrame *)frame;

@end

NS_ASSUME_NONNULL_END
