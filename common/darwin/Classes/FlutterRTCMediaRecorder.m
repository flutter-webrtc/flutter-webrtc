#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_MAC
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import "<AVFoundation/AVFoundation.h>"  

#import "FlutterRTCFrameCapturer.h"

#include "libyuv.h"


@import CoreImage;
@import CoreVideo;

@implementation FlutterRTCMediaRecorder {
    RTCVideoTrack* _track;
    AVAssetWriter* _avAssetWriter;
    NSString* _path;
    FlutterResult _result;
}

- (instancetype)initWithTrack:(RTCVideoTrack *) track toPath:(NSString *) path result:(FlutterResult)result
{
    self = [super init];
    if (self) {
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
#if TARGET_OS_IPHONE

#endif
}

@end
