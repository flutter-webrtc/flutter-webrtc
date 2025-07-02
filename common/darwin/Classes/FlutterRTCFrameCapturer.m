#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import "FlutterRTCFrameCapturer.h"

@import CoreImage;
@import CoreVideo;

@implementation FlutterRTCFrameCapturer {
  RTCVideoTrack* _track;
  NSString* _path;
  FlutterResult _result;
  bool _gotFrame;
}

- (instancetype)initWithTrack:(RTCVideoTrack*)track
                       toPath:(NSString*)path
                       result:(FlutterResult)result {
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

- (void)setSize:(CGSize)size {
}

- (void)renderFrame:(nullable RTCVideoFrame*)frame {
  if (_gotFrame || frame == nil)
    return;
  _gotFrame = true;
  id<RTCVideoFrameBuffer> buffer = frame.buffer;
  CVPixelBufferRef pixelBufferRef;
  bool shouldRelease;
  if (![buffer isKindOfClass:[RTCCVPixelBuffer class]]) {
    pixelBufferRef = [FlutterRTCFrameCapturer convertToCVPixelBuffer:frame];
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
  if ([[_path pathExtension] isEqualToString:@"jpg"]) {
    imageData = UIImageJPEGRepresentation(uiImage, 1.0f);
  } else {
    imageData = UIImagePNGRepresentation(uiImage);
  }
#else
  NSBitmapImageRep* newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
  [newRep setSize:NSSizeToCGSize(outputSize.size)];
  NSDictionary<NSBitmapImageRepPropertyKey, id>* quality = @{NSImageCompressionFactor : @1.0f};
  if ([[_path pathExtension] isEqualToString:@"jpg"]) {
    imageData = [newRep representationUsingType:NSBitmapImageFileTypeJPEG properties:quality];
  } else {
    imageData = [newRep representationUsingType:NSBitmapImageFileTypePNG properties:quality];
  }
#endif
  CGImageRelease(cgImage);
  if (shouldRelease)
    CVPixelBufferRelease(pixelBufferRef);
  if (imageData && [imageData writeToFile:_path atomically:NO]) {
    NSLog(@"File writed successfully to %@", _path);
    _result(nil);
  } else {
    NSLog(@"Failed to write to file");
    _result([FlutterError errorWithCode:@"CaptureFrameFailed"
                                message:@"Failed to write image data to file"
                                details:nil]);
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self->_track removeRenderer:self];
    self->_track = nil;
  });
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
                      height:i420Buffer.height];
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
