#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <CoreGraphics/CGImage.h>
#import <WebRTC/RTCVideoFrameBuffer.h>
#import "FlutterRTCVideoViewManager.h"
#import "FlutterWebRTCPlugin.h"

@implementation RTCVideoView {
    CGSize _renderSize;
    RTCVideoFrame *_frame;
    CVPixelBufferRef pixelBufferRef;
}

- (instancetype)initWithSize:(CGSize)renderSize
                  onNewFrame:(void(^)(void))onNewFrame {
    self = [super init];
    if (self){
        _renderSize = renderSize;
        _onNewFrame = onNewFrame;
    }
    return self;
}

- (CVPixelBufferRef)copyPixelBuffer {
    CVBufferRetain(pixelBufferRef);
    return pixelBufferRef;
}

void DrawGradientInRGBPixelBuffer(CVPixelBufferRef pixelBuffer) {
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    void* baseAddr = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int byteOrder = CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32ARGB ?
    kCGBitmapByteOrder32Little :
    0;
    CGContextRef cgContext = CGBitmapContextCreate(baseAddr,
                                                   width,
                                                   height,
                                                   8,
                                                   CVPixelBufferGetBytesPerRow(pixelBuffer),
                                                   colorSpace,
                                                   byteOrder | kCGImageAlphaNoneSkipLast);
    
    // Create a gradient
    CGFloat colors[] = {
        1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 4);
    
    CGContextDrawLinearGradient(
                                cgContext, gradient, CGPointMake(0, 0), CGPointMake(width, height), 0);
    CGGradientRelease(gradient);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    CGContextRelease(cgContext);
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

/**
 * Implements the setter of the {@link #mirror} property of this
 * {@code RTCVideoView}.
 *
 * @param mirror The value to set on the {@code mirror} property of this
 * {@code RTCVideoView}.
 */
- (void)setMirror:(BOOL)mirror {
    if (_mirror != mirror) {
        _mirror = mirror;
    }
}

/**
 * Implements the setter of the {@link #objectFit} property of this
 * {@code RTCVideoView}.
 *
 * @param objectFit The value to set on the {@code objectFit} property of this
 * {@code RTCVideoView}.
 */
- (void)setObjectFit:(RTCVideoViewObjectFit)objectFit {
    if (_objectFit != objectFit) {
        _objectFit = objectFit;
    }
}

/**
 * Implements the setter of the {@link #videoTrack} property of this
 * {@code RTCVideoView}.
 *
 * @param videoTrack The value to set on the {@code videoTrack} property of this
 * {@code RTCVideoView}.
 */
- (void)setVideoTrack:(RTCVideoTrack *)videoTrack {
    RTCVideoTrack *oldValue = self.videoTrack;
    
    if (oldValue != videoTrack) {
        if (oldValue) {
            [oldValue removeRenderer:self];
        }
        _videoTrack = videoTrack;
        if (videoTrack) {
            [videoTrack addRenderer:self];
        }
    }
}

#pragma mark - RTCVideoRenderer methods

/**
 * Renders a specific video frame. Delegates to the subview of this instance
 * which implements the actual {@link RTCVideoRenderer}.
 *
 * @param frame The video frame to render.
 */
- (void)renderFrame:(RTCVideoFrame *)frame {
    if(pixelBufferRef == nil){
        CVPixelBufferCreate(kCFAllocatorDefault, frame.width, frame.height, kCVPixelFormatType_32BGRA, NULL, &pixelBufferRef);
    }
    [frame CopyI420BufferToCVPixelBuffer:pixelBufferRef];
    dispatch_async(dispatch_get_main_queue(), self.onNewFrame);
}

/**
 * Sets the size of the video frame to render.
 *
 * @param size The size of the video frame to render.
 */
- (void)setSize:(CGSize)size {
    /*
    id<RTCVideoRenderer> videoRenderer = self;
    if (videoRenderer) {
        [videoRenderer setSize:size];
    }
    */
}

@end

@implementation FlutterWebRTCPlugin (RTCVideoViewManager)

- (RTCVideoView *)createWithSize:(CGSize)size onNewFrame:(void(^)(void))onNewFrame{
    RTCVideoView *v = [[RTCVideoView alloc] initWithSize:size onNewFrame:onNewFrame];
    return v;
}

-(void)setStreamId:(NSString*)streamId view:(RTCVideoView*)view {
    
    RTCVideoTrack *videoTrack;
    RTCMediaStream *stream = [self streamForId:streamId];
    if(stream){
        NSArray *videoTracks = stream ? stream.videoTracks : nil;
        
        videoTrack = videoTracks && videoTracks.count ? videoTracks[0] : nil;
        if (!videoTrack) {
            NSLog(@"No video stream for react tag: %@", streamId);
        }
    } else {
        videoTrack = nil;
    }
    
    view.videoTrack = videoTrack;
}

@end

