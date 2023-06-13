#import "FlutterRTCVideoFrameTransform.h"

@import CoreImage;
@import CoreVideo;

@implementation PhotographFormat {
    NSData* _data;
    NSInteger _width;
    NSInteger _height;
    NSString* _format;
}

- (instancetype)initWidthData:(NSData *)data width:(NSInteger)width height:(NSInteger)height format:(RTCVideoFrameFormat)format {
    self = [super init];
    
    if(self) {
        _data = data;
        _width = width;
        _height = height;
        _format = [PhotographFormat getFormatString:format];
    }
    
    return self;
}

+ (NSString *)getFormatString:(RTCVideoFrameFormat)format {
    switch(format) {
        case KI420:
            return @"KI420";
        case KRGBA:
            return @"KRGBA";
        case KMJPEG:
            return @"KMJPEG";
    }
}

@end

@implementation RTCVideoFrameTransform{}

+ (PhotographFormat *)transform:(RTCVideoFrame *)frame format:(RTCVideoFrameFormat)format {
    RTCVideoFrameTransform *videoTransform = [[RTCVideoFrameTransform alloc] init];
    
    switch (format) {
        case KI420:
            return [videoTransform videoFrameToI420:frame];
        case KRGBA:
            return [videoTransform videoFrameToRGBA:frame];
        case KMJPEG:
            return [videoTransform videoFrameToJPEG:frame];
    };
}

- (PhotographFormat *)videoFrameToI420:(RTCVideoFrame *)frame {
    id<RTCI420Buffer> i420Buffer = [frame.buffer toI420];
    int height = i420Buffer.height;
    int strideY = i420Buffer.strideY;
    int strideU = i420Buffer.strideU;
    int strideV = i420Buffer.strideV;

    size_t dataSizeY = strideY * height;
    size_t dataSizeU = strideU * height / 2;
    size_t dataSizeV = strideV * height / 2;

    NSMutableData *binaryData = [NSMutableData dataWithLength:dataSizeY + dataSizeU + dataSizeV];

    uint8_t *yPlane = binaryData.mutableBytes;
    uint8_t *uPlane = yPlane + dataSizeY;
    uint8_t *vPlane = uPlane + dataSizeU;
    memcpy(yPlane, i420Buffer.dataY, dataSizeY);
    memcpy(uPlane, i420Buffer.dataU, dataSizeU);
    memcpy(vPlane, i420Buffer.dataV, dataSizeV);

    NSUInteger dataLength = binaryData.length;
    NSData *data = [NSData dataWithBytes:binaryData.bytes length:dataLength];

    return [[PhotographFormat alloc] initWidthData:data width:i420Buffer.width height:i420Buffer.height format:KI420 ];
}

- (PhotographFormat *)videoFrameToJPEG:(RTCVideoFrame *)frame {
    NSDictionary *result = [self createPixelBufferAndImage:frame];
    CVPixelBufferRef pixelBufferRef = (__bridge CVPixelBufferRef)[result objectForKey:@"pixelBufferRef"];
    CIImage *ciImage = [result objectForKey:@"ciImage"];
    CGRect outputSize = [[result objectForKey:@"outputSize"] CGRectValue];
    bool shouldRelease = [[result objectForKey:@"shouldRelease"] boolValue];
  
    CIContext* tempContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [tempContext createCGImage:ciImage fromRect:outputSize];
    NSData* imageData;
    #if TARGET_OS_IPHONE
    UIImage* uiImage = [UIImage imageWithCGImage:cgImage];
    imageData = UIImageJPEGRepresentation(uiImage, 1.0f);
    #else
    NSBitmapImageRep* newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    [newRep setSize:NSSizeToCGSize(outputSize.size)];
    NSDictionary<NSBitmapImageRepPropertyKey, id>* quality = @{NSImageCompressionFactor : @1.0f};
    imageData = [newRep representationUsingType:NSBitmapImageFileTypeJPEG properties:quality];
    #endif
    CGImageRelease(cgImage);
    if (shouldRelease)
//        CVPixelBufferRelease(pixelBufferRef);
    if(frame.rotation == RTCVideoRotation_90 || frame.rotation == RTCVideoRotation_180){
      return [[PhotographFormat alloc] initWidthData:imageData width:frame.height height:frame.width format:KMJPEG];
    }
    return [[PhotographFormat alloc] initWidthData:imageData width:frame.width height:frame.width format:KMJPEG];
}

- (PhotographFormat *)videoFrameToRGBA:(RTCVideoFrame *)frame {
    NSDictionary *result = [self createPixelBufferAndImage:frame];
    CVPixelBufferRef pixelBufferRef = (__bridge CVPixelBufferRef)[result objectForKey:@"pixelBufferRef"];
    CIImage *ciImage = [result objectForKey:@"ciImage"];
    bool shouldRelease = [[result objectForKey:@"shouldRelease"] boolValue];
  
    CIContext* tempContext = [CIContext contextWithOptions:nil];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerRow = ciImage.extent.size.width * 4;
    NSMutableData *bitmapData = [NSMutableData dataWithLength:bytesPerRow * ciImage.extent.size.height];
    [tempContext render:ciImage toBitmap:bitmapData.mutableBytes rowBytes:bytesPerRow bounds:ciImage.extent format:kCIFormatRGBA8 colorSpace:colorSpace];
//    CGColorSpaceRelease(colorSpace);

    if (shouldRelease)
        CVPixelBufferRelease(pixelBufferRef);
    if(frame.rotation == RTCVideoRotation_90 || frame.rotation == RTCVideoRotation_180){
      return [[PhotographFormat alloc] initWidthData:bitmapData width:frame.height height:frame.width format:KRGBA];
    }
    return [[PhotographFormat alloc] initWidthData:bitmapData width:frame.width height:frame.height format:KRGBA];
}

- (NSDictionary *)createPixelBufferAndImage:(RTCVideoFrame *)frame {
    id<RTCVideoFrameBuffer> buffer = frame.buffer;
    CVPixelBufferRef pixelBufferRef;
    bool shouldRelease;
    if (![buffer isKindOfClass:[RTCCVPixelBuffer class]]) {
      pixelBufferRef = [self convertToCVPixelBuffer:frame];
      shouldRelease = true;
    } else {
      pixelBufferRef = ((RTCCVPixelBuffer*)buffer).pixelBuffer;
      shouldRelease = false;
    }
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];
    CGRect outputSize;
    if (@available(iOS 11, macOS 10.13, *)) {
      switch (frame.rotation) {
        case RTCVideoRotation_90:
          ciImage = [ciImage imageByApplyingCGOrientation:kCGImagePropertyOrientationRight];
          outputSize = CGRectMake(0, 0, frame.height, frame.width);
          break;
        case RTCVideoRotation_180:
          ciImage = [ciImage imageByApplyingCGOrientation:kCGImagePropertyOrientationDown];
          outputSize = CGRectMake(0, 0, frame.width, frame.height);
          break;
        case RTCVideoRotation_270:
          ciImage = [ciImage imageByApplyingCGOrientation:kCGImagePropertyOrientationLeft];
          outputSize = CGRectMake(0, 0, frame.height, frame.width);
          break;
        default:
          outputSize = CGRectMake(0, 0, frame.width, frame.height);
          break;
      }
    } else {
      outputSize = CGRectMake(0, 0, frame.width, frame.height);
    }
    #if TARGET_OS_IPHONE
    NSDictionary *result = @{
        @"pixelBufferRef": (__bridge id)pixelBufferRef,
        @"ciImage": ciImage,
        @"outputSize": [NSValue valueWithCGRect:outputSize],
        @"shouldRelease": [NSNumber numberWithBool:shouldRelease]
    };
    #else
    NSDictionary *result = @{
        @"pixelBufferRef": (__bridge id)pixelBufferRef,
        @"ciImage": ciImage,
        @"outputSize": [NSValue valueWithRect:outputSize],
        @"shouldRelease": [NSNumber numberWithBool:shouldRelease]
    };
    #endif
    return result;
}

- (CVPixelBufferRef)convertToCVPixelBuffer:(RTCVideoFrame*)frame {
    id<RTCI420Buffer> i420Buffer = [frame.buffer toI420];
    CVPixelBufferRef outputPixelBuffer;
    size_t w = (size_t)roundf(i420Buffer.width);
    size_t h = (size_t)roundf(i420Buffer.height);
    NSDictionary* pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    CVPixelBufferCreate(kCFAllocatorDefault, w, h, kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)(pixelAttributes), &outputPixelBuffer);
    CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(outputPixelBuffer);
    if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
        pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
      // NV12
      uint8_t* dstY = CVPixelBufferGetBaseAddressOfPlane(outputPixelBuffer, 0);
      const size_t dstYStride = CVPixelBufferGetBytesPerRowOfPlane(outputPixelBuffer, 0);
      uint8_t* dstUV = CVPixelBufferGetBaseAddressOfPlane(outputPixelBuffer, 1);
      const size_t dstUVStride = CVPixelBufferGetBytesPerRowOfPlane(outputPixelBuffer, 1);

      [RTCYUVHelper I420ToNV12:i420Buffer.dataY
                    srcStrideY:i420Buffer.strideY
                          srcU:i420Buffer.dataU
                    srcStrideU:i420Buffer.strideU
                          srcV:i420Buffer.dataV
                    srcStrideV:i420Buffer.strideV
                          dstY:dstY
                    dstStrideY:(int)dstYStride
                        dstUV:dstUV
                  dstStrideUV:(int)dstUVStride
                        width:i420Buffer.width
                        width:i420Buffer.height];
    } else {
      uint8_t* dst = CVPixelBufferGetBaseAddress(outputPixelBuffer);
      const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(outputPixelBuffer);

      if (pixelFormat == kCVPixelFormatType_32BGRA) {
        // Corresponds to libyuv::FOURCC_ARGB
        [RTCYUVHelper I420ToARGB:i420Buffer.dataY
                      srcStrideY:i420Buffer.strideY
                            srcU:i420Buffer.dataU
                      srcStrideU:i420Buffer.strideU
                            srcV:i420Buffer.dataV
                      srcStrideV:i420Buffer.strideV
                        dstARGB:dst
                  dstStrideARGB:(int)bytesPerRow
                          width:i420Buffer.width
                          height:i420Buffer.height];
      } else if (pixelFormat == kCVPixelFormatType_32ARGB) {
        // Corresponds to libyuv::FOURCC_BGRA
        [RTCYUVHelper I420ToBGRA:i420Buffer.dataY
                      srcStrideY:i420Buffer.strideY
                            srcU:i420Buffer.dataU
                      srcStrideU:i420Buffer.strideU
                            srcV:i420Buffer.dataV
                      srcStrideV:i420Buffer.strideV
                        dstBGRA:dst
                  dstStrideBGRA:(int)bytesPerRow
                          width:i420Buffer.width
                          height:i420Buffer.height];
      }
    }
    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, 0);
    return outputPixelBuffer;
}

@end
