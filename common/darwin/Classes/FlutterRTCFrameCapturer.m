#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif


#import "FlutterRTCFrameCapturer.h"

#define clamp(a) (a>255?255:(a<0?0:a))

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

#if TARGET_OS_IPHONE
// Thanks Juan Giorello https://groups.google.com/g/discuss-webrtc/c/ULGIodbbLvM
+ (UIImage *)convertFrameToUIImage:(RTCVideoFrame *)frame {
    // https://chromium.googlesource.com/external/webrtc/+/refs/heads/main/sdk/objc/base/RTCVideoFrame.h    
    // RTCVideoFrameBuffer *rtcFrameBuffer = (RTCVideoFrameBuffer *)frame.buffer;
    // RTCI420Buffer *buffer = [rtcFrameBuffer toI420];

    // https://chromium.googlesource.com/external/webrtc/+/refs/heads/main/sdk/objc/base/RTCVideoFrameBuffer.h
    // This guarantees the buffer will be RTCI420Buffer
    RTCI420Buffer *buffer = [frame.buffer toI420];
    
    
    int width = buffer.width;
    int height = buffer.height;
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
    
    for(int row = 0; row < height; row++) {
        const uint8_t *yLine = &buffer.dataY[row * buffer.strideY];
        const uint8_t *uLine = &buffer.dataU[(row >> 1) * buffer.strideU];
        const uint8_t *vLine = &buffer.dataV[(row >> 1) * buffer.strideV];
        
        for(int x = 0; x < width; x++) {
            int16_t y = yLine[x];
            int16_t u = uLine[x >> 1] - 128;
            int16_t v = vLine[x >> 1] - 128;
            
            int16_t r = roundf(y + v * 1.4);
            int16_t g = roundf(y + u * -0.343 + v * -0.711);
            int16_t b = roundf(y + u * 1.765);
            
            uint8_t *rgb = &rgbBuffer[(row * width + x) * bytesPerPixel];
            rgb[0] = 0xff;
            rgb[1] = clamp(b);
            rgb[2] = clamp(g);
            rgb[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rgbBuffer);

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

    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1 orientation:orientation];
    CGImageRelease(cgImage);
    
    return image;
}
#endif

- (void)renderFrame:(nullable RTCVideoFrame *)frame
{
#if TARGET_OS_IPHONE
    if (_gotFrame || frame == nil) return;
    _gotFrame = true;

    UIImage *uiImage = [FlutterRTCFrameCapturer convertFrameToUIImage:frame];
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

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_track removeRenderer:self];
        self->_track = nil;
    });
#endif
}

@end
