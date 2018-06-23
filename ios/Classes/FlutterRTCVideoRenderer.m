#import "FlutterRTCVideoRenderer.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CGImage.h>
#import <WebRTC/RTCVideoFrameBuffer.h>
#import <objc/runtime.h>

#import "FlutterWebRTCPlugin.h"

@implementation FlutterRTCVideoRenderer {
    CGSize _renderSize;
    CGSize _frameSize;
    CVPixelBufferRef _pixelBufferRef;
    RTCVideoRotation _rotation;
    FlutterEventChannel* _eventChannel;
}

@synthesize textureId  = _textureId;
@synthesize registry = _registry;
@synthesize eventSink = _eventSink;

- (instancetype)initWithSize:(CGSize)renderSize
         withTextureRegistry:(id<FlutterTextureRegistry>)registry
                   messenger:(NSObject<FlutterBinaryMessenger>*)messenger{
    self = [super init];
    if (self){
        _renderSize = renderSize;
        _registry = registry;
        _pixelBufferRef = nil;
        _eventSink = nil;
        _rotation  = -1;
        _textureId  = [registry registerTexture:self];
        /*Create Event Channel.*/
        _eventChannel = [FlutterEventChannel
                                       eventChannelWithName:[NSString stringWithFormat:@"cloudwebrtc.com/WebRTC/Texture%lld", _textureId]
                                       binaryMessenger:messenger];
        [_eventChannel setStreamHandler:self];
    }
    return self;
}

-(void)dealloc {
    if(_pixelBufferRef){
        CVBufferRelease(_pixelBufferRef);
    }
}

- (CVPixelBufferRef)copyPixelBuffer {
    if(_pixelBufferRef != nil){
        CVBufferRetain(_pixelBufferRef);
        return _pixelBufferRef;
    }
    return nil;
}

-(void)dispose{
    [_registry unregisterTexture:_textureId];
}

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
    
    //TODO: got a frame => scale to _renderSize => convert to BGRA32 pixelBufferRef
    
    [frame CopyI420BufferToCVPixelBuffer:_pixelBufferRef];
    
    __weak FlutterRTCVideoRenderer *weakSelf = self;
    
    if(frame.rotation != _rotation){
        dispatch_async(dispatch_get_main_queue(), ^{
            FlutterRTCVideoRenderer *strongSelf = weakSelf;
            if(strongSelf.eventSink){
                strongSelf.eventSink(@{
                                   @"event" : @"didTextureChangeRotation",
                                   @"id": @(strongSelf.textureId),
                                   @"rotation": @(frame.rotation),
                                   });
            }
        });

        _rotation = frame.rotation;
    }
    
    //Notify the Flutter new pixelBufferRef to be ready.
    dispatch_async(dispatch_get_main_queue(), ^{
        FlutterRTCVideoRenderer *strongSelf = weakSelf;
        [strongSelf.registry textureFrameAvailable:strongSelf.textureId];
    });
}

/**
 * Sets the size of the video frame to render.
 *
 * @param size The size of the video frame to render.
 */
- (void)setSize:(CGSize)size {
    if(_pixelBufferRef == nil || (size.width != _frameSize.width || size.height != _frameSize.height))
    {
        if(_pixelBufferRef){
            CVBufferRelease(_pixelBufferRef);
        }
        CVPixelBufferCreate(kCFAllocatorDefault,
                            size.width, size.height,
                            kCVPixelFormatType_32BGRA,
                            NULL, &_pixelBufferRef);
    }
    
    __weak FlutterRTCVideoRenderer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        FlutterRTCVideoRenderer *strongSelf = weakSelf;
        if(strongSelf.eventSink){
            strongSelf.eventSink(@{
                    @"event" : @"didTextureChangeVideoSize",
                    @"id": @(strongSelf.textureId),
                    @"width": @(size.width),
                    @"height": @(size.height),
                    });
        }
    });
    _frameSize = size;
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
    _eventSink = sink;
    return nil;
}
@end

@implementation FlutterWebRTCPlugin (FlutterVideoRendererManager)

- (FlutterRTCVideoRenderer *)createWithSize:(CGSize)size
                    withTextureRegistry:(id<FlutterTextureRegistry>)registry
                       messenger:(NSObject<FlutterBinaryMessenger>*)messenger{
    return [[FlutterRTCVideoRenderer alloc] initWithSize:size withTextureRegistry:registry messenger:messenger];
}

-(void)setStreamId:(NSString*)streamId view:(FlutterRTCVideoRenderer*)view {
    
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

    BOOL enabled = (stream && videoTrack);
    __weak FlutterRTCVideoRenderer *weakSelf = view;
    dispatch_async(dispatch_get_main_queue(), ^{
        FlutterRTCVideoRenderer *strongSelf = weakSelf;
        if(strongSelf.eventSink){
            strongSelf.eventSink(@{@"event" : @"videoState",
                                   @"id": @(strongSelf.textureId),
                                   @"enabled":@(enabled)});
        }
    });
}

@end

