#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <CoreGraphics/CGImage.h>
#import <WebRTC/RTCVideoFrameBuffer.h>
#import "FlutterRTCVideoViewManager.h"
#import "FlutterWebRTCPlugin.h"

@implementation RTCVideoView {
    CGSize _renderSize;
    CGSize _frameSize;
    CVPixelBufferRef _pixelBufferRef;
}

- (instancetype)initWithSize:(CGSize)renderSize
                  onNewFrame:(void(^)(void))onNewFrame {
    self = [super init];
    if (self){
        _renderSize = renderSize;
        _onNewFrame = onNewFrame;
        _pixelBufferRef = nil;
    }
    return self;
}

-(void)dealloc {
    if(_pixelBufferRef){
        CVBufferRelease(_pixelBufferRef);
    }
}

- (CVPixelBufferRef)copyPixelBuffer {
    CVBufferRetain(_pixelBufferRef);
    return _pixelBufferRef;
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
- (void)renderFrame:(RTCVideoFrame *)frame {
    
    //TODO: got a frame => scale to _renderSize => correct rotation => convert to BGRA32 pixelBufferRef
    
    [frame CopyI420BufferToCVPixelBuffer:_pixelBufferRef];
    
    //Notify the Flutter new pixelBufferRef to be ready.
    dispatch_async(dispatch_get_main_queue(), self.onNewFrame);
}

/**
 * Sets the size of the video frame to render.
 *
 * @param size The size of the video frame to render.
 */
- (void)setSize:(CGSize)size {
    if(_pixelBufferRef == nil || (size.width != _frameSize.width || size.height != _frameSize.height))
    {
        CVPixelBufferCreate(kCFAllocatorDefault,
                            size.width, size.height,
                            kCVPixelFormatType_32BGRA,
                            NULL, &_pixelBufferRef);
    }
    _frameSize = size;
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

