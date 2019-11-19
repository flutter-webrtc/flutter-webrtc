#import <FlutterMacOS/FlutterMacOS.h>
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
    if (_gotFrame || frame == nil) return;
    _gotFrame = true;

    id<RTCVideoFrameBuffer> buffer = frame.buffer;
    CVPixelBufferRef pixelBufferRef = ((RTCCVPixelBuffer *) buffer).pixelBuffer;

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage
                                       fromRect:CGRectMake(0, 0, frame.width, frame.height)];
#if 0 //TODO: frame capture
    UIImageOrientation orientation;
    switch (frame.rotation) {
        case RTCVideoRotation_90:
            orientation = UIImageOrientationRight;
            break;
        case RTCVideoRotation_180:
            orientation = UIImageOrientationDown;
            break;
        case RTCVideoRotation_270:
            orientation = UIImageOrientationLeft;
        default:
            orientation = UIImageOrientationUp;
            break;
    }

    UIImage *uiImage = [UIImage imageWithCGImage:cgImage scale:1 orientation:orientation];
    CGImageRelease(cgImage);
    NSData *jpgData = UIImageJPEGRepresentation(uiImage, 0.9f);

    if ([jpgData writeToFile:_path atomically:NO]) {
        NSLog(@"File writed successfully to %@", _path);
        _result(nil);
    } else {
        NSLog(@"Failed to write to file");
        _result([FlutterError errorWithCode:@"CaptureFrameFailed"
                                    message:@"Failed to write JPEG data to file"
                                    details:nil]);
    }
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_track removeRenderer:self];
        self->_track = nil;
    });
}

@end
