#import "FlutterRTCVideoFrameTransform.h"

@import CoreImage;
@import CoreVideo;

@implementation RTCVideoFrameTransform

+ (nullable NSData *)transform:(RTCVideoFrame *)frame format:(RTCVideoFrameFormat)format {
    NSData *result;
    switch (format) {
        case KMJPEG:
            result = [self videoFrameToJPEG:frame];
            break;
        case KI420:
            // todo
            break;
    }
    return result;
}

+ (nullable NSData *)videoFrameToJPEG:(RTCVideoFrame *)frame {
    // do something
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
    imageData = [newRep representationUsingType:NSJPEGFileType properties:quality];
    #endif
    CGImageRelease(cgImage);
    if (shouldRelease)
      CVPixelBufferRelease(pixelBufferRef);
    
    return imageData;
}

+ (CVPixelBufferRef)convertToCVPixelBuffer:(RTCVideoFrame*)frame {
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
