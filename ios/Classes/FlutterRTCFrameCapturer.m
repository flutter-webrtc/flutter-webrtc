#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif


#import "FlutterRTCFrameCapturer.h"

#include "libyuv.h"

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
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

- (void)renderFrame:(nullable RTCVideoFrame *)frame
{
#if TARGET_OS_IPHONE
    if (_gotFrame || frame == nil) return;
    _gotFrame = true;
    
//    UIImage *uiImage = [FlutterRTCFrameCapturer convertFrameToUIImage:frame];
    int32_t frameHeight = frame.height;
    int32_t frameWidth = frame.width;

//    if (_vtCompressionSession == nil) {
//        CMVideoCodecType codec = kCMVideoCodecType_H264;
//        OSStatus result = VTCompressionSessionCreate(nil, frameWidth, frameHeight, codec, nil, nil, nil, vtCompressionCallback, (__bridge_retained void*) self, &(_vtCompressionSession));
//        NSLog(@"VTCompressionSessionCreate result %d", result);
//    }
//
    
//        if (_vtCompressionSession != nil) {
            
        NSLog(@"We have a compression session");
            //https://wiki.videolan.org/YUV#I420
            RTCI420Buffer *buffer = [frame.buffer toI420];
            
    //https://stackoverflow.com/questions/3838696/convert-uiimage-to-cvpixelbufferref
    NSDictionary *pixelAttributes = @{(NSString*)kCVPixelBufferCGImageCompatibilityKey: @YES, (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
            CVPixelBufferRef pixelBuffer = NULL;
            CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                                  frameWidth,
                                                  frameHeight,
                                                  kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                                  //kCVPixelFormatType_420YpCbCr8PlanarFullRange,
                                                  (__bridge CFDictionaryRef)(pixelAttributes),
                                                  &pixelBuffer);

            if (result != kCVReturnSuccess) {
                NSLog(@"Unable to create cvpixelbuffer %d", result);
                return;
            }
            
            // The i420 buffer stores the data Planar
            //https://developer.apple.com/documentation/accelerate/conversion/understanding_ypcbcr_image_formats?language=objc
            // https://chromium.googlesource.com/external/webrtc/+/HEAD/api/video/i420_buffer.cc

    uint32_t strideY = [buffer strideY];
    uint32_t strideU = [buffer strideU];
    uint32_t strideV = [buffer strideV];
    
    uint32_t yPlaneSize = buffer.height * strideY;
    uint32_t uPlaneSize =((buffer.height + 1) / 2) * strideU;
    uint32_t vPlaneSize =((buffer.height + 1) / 2) * strideV;

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    memcpy(yDestPlane, [buffer dataY], yPlaneSize);
    
    uint8_t *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    for (int i = 0; i <= vPlaneSize; i++)
    {
        uvDestPlane[i*2] = [buffer dataU][i];
        uvDestPlane[i*2+1] = [buffer dataV][i];
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];


    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                       createCGImage:ciImage
                       fromRect:CGRectMake(0, 0,
                              CVPixelBufferGetWidth(pixelBuffer),
                              CVPixelBufferGetHeight(pixelBuffer))];

    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
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
