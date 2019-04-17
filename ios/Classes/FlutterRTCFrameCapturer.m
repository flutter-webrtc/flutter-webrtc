#import <Flutter/Flutter.h>

#import "FlutterRTCFrameCapturer.h"

#include "libyuv.h"

@import CoreImage;
@import CoreVideo;

@implementation FlutterRTCFrameCapturer {
    RTCVideoTrack* _track;
    NSString* _path;
    FlutterResult _result;
    bool _gotFrame;
}

- (instancetype)initWithTrack:(RTCVideoTrack *) track toPath:(NSString *) path result:(FlutterResult)result
{
    self = [super init];
    if (self) {
        _gotFrame = false;
        _track = track;
        _path = path;
        _result = result;
        [track addRenderer:self];
    }
    return self;
}

- (void)setSize:(CGSize)size
{
}

- (void)renderFrame:(nullable RTCVideoFrame *)frame
{
    if (_gotFrame) return;
    _gotFrame = true;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_track removeRenderer:self];
    });

    id<RTCVideoFrameBuffer> buffer = [frame buffer];
    id<RTCI420Buffer> i420Buffer = [buffer toI420];

    CVPixelBufferRef pixelBuffer = nil;
    CVPixelBufferCreate(kCFAllocatorDefault, i420Buffer.width, i420Buffer.height, kCVPixelFormatType_32ARGB, nil, &pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    uint8_t* dst = CVPixelBufferGetBaseAddress(pixelBuffer);
    const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);

    I420ToBGRA(i420Buffer.dataY,
               i420Buffer.strideY,
               i420Buffer.dataU,
               i420Buffer.strideU,
               i420Buffer.dataV,
               i420Buffer.strideV,
               dst,
               (int)bytesPerRow,
               i420Buffer.width,
               i420Buffer.height);

    CIContext *context = [[CIContext alloc] init];
    CIImage *coreImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];

    CIImage *rotatedImage;
    switch (frame.rotation) {
        case RTCVideoRotation_0: rotatedImage = coreImage; break;
        case RTCVideoRotation_90: rotatedImage = [coreImage imageByApplyingOrientation:kCGImagePropertyOrientationRight]; break;
        case RTCVideoRotation_180: rotatedImage = [coreImage imageByApplyingOrientation:kCGImagePropertyOrientationDown]; break;
        case RTCVideoRotation_270: rotatedImage = [coreImage imageByApplyingOrientation:kCGImagePropertyOrientationLeft]; break;
    }

    NSData* data = [context JPEGRepresentationOfImage:rotatedImage colorSpace:rotatedImage.colorSpace options:@{}];

    [data writeToFile:_path atomically:NO];

    _result(nil);
}

@end
