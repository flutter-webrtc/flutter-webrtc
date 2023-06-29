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
  PhotographFormat* transformResult = [RTCVideoFrameTransform transform:frame format:KMJPEG];
  if (transformResult.data && [transformResult.data writeToFile:_path atomically:NO]) {
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

@end
