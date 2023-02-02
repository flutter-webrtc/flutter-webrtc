#import "VideoRenderer.h"

// Drops the provided `TextureVideoRenderer`.
void drop_handler(void* handler) {
    TextureVideoRenderer* renderer =
        (__bridge_transfer TextureVideoRenderer*)handler;
}

// Passes the provided `Frame` from Rust side to the specified
// `TextureVideoRenderer`.
void on_frame_caller(void* handler, Frame frame) {
    TextureVideoRenderer* renderer = (__bridge TextureVideoRenderer*)handler;
    [renderer onFrame:frame];
}

@implementation TextureVideoRenderer
// Initializes a new `TextureVideoRenderer` with the provided `registry` and
// `messenger`.
- (instancetype)init:(id<FlutterTextureRegistry>)registry
           messenger:(id<FlutterBinaryMessenger>)messenger {
    self = [super init];
    self->_pixelBufferRef = nil;
    self->_registry = registry;
    self->_bufferSize = 0;
    self->_frameWidth = 0;
    self->_frameHeight = 0;

    int64_t tid = [registry registerTexture:self];
    self->_tid = tid;
    NSNumber* textureId = [NSNumber numberWithLong:tid];
    NSString* channelName = [NSString
        stringWithFormat:@"FlutterWebRtc/VideoRendererEvent/%@", textureId];
    _eventChannel = [FlutterEventChannel eventChannelWithName:channelName
                                              binaryMessenger:messenger];
    self->_textureId = textureId;
    [_eventChannel setStreamHandler:self];

    __weak TextureVideoRenderer* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      __strong TextureVideoRenderer* strongSelf = weakSelf;
      if (strongSelf) {
          [strongSelf.registry textureFrameAvailable:strongSelf->_tid];
      }
    });
    return self;
}

// Resets this `TextureVideoRenderer`.
- (void)resetRenderer {
    self->_firstFrameRendered = false;
}

// Releases `PixelBuffer` of this `TextureVideoRenderer`.
- (void)onTextureUnregistered:(NSObject<FlutterTexture>*)texture {
    if (_pixelBufferRef != nil) {
        CVBufferRelease(_pixelBufferRef);
    }
}

// Draws the provided `Frame` on the `PixelBuffer` of this
// `TextureVideoRenderer`.
- (void)onFrame:(Frame)frame {
    bool isBufferNotCreated = _pixelBufferRef == nil;
    bool isFrameSizeChanged = _bufferSize != frame.buffer_size;
    if (isBufferNotCreated || isFrameSizeChanged) {
        if (isFrameSizeChanged) {
            _bufferSize = frame.buffer_size;
            CVBufferRelease(_pixelBufferRef);
        }
        NSDictionary* pixelAttributes =
            @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
        CVPixelBufferCreate(kCFAllocatorDefault, frame.width, frame.height,
                            kCVPixelFormatType_32BGRA,
                            (__bridge CFDictionaryRef)(pixelAttributes),
                            &self->_pixelBufferRef);
    }
    CVPixelBufferLockBaseAddress(_pixelBufferRef, 0);
    uint8_t* dst = CVPixelBufferGetBaseAddress(_pixelBufferRef);
    int argb_stride = CVPixelBufferGetBytesPerRow(_pixelBufferRef);
    get_argb_bytes(frame.frame, argb_stride, dst);
    drop_frame(frame.frame);
    CVPixelBufferUnlockBaseAddress(_pixelBufferRef, 0);

    if (!_firstFrameRendered) {
        if (_eventSink != nil) {
            NSDictionary* map = @{
                @"event" : @"onFirstFrameRendered",
                @"id" : self->_textureId,
            };
            _eventSink(map);
        }
        _firstFrameRendered = true;
    }
    NSNumber* frameRotation = [NSNumber numberWithInt:frame.rotation];
    if (_rotation != frameRotation) {
        if (_eventSink != nil) {
            NSDictionary* map = @{
                @"event" : @"onTextureChangeRotation",
                @"id" : _textureId,
                @"rotation" : frameRotation,
            };
            _eventSink(map);
        }
        _rotation = frameRotation;
    }
    bool isFrameWidthChanged = _frameWidth != frame.width;
    bool isFrameHeightChanged = _frameHeight != frame.height;
    if (isFrameWidthChanged || isFrameHeightChanged) {
        _frameWidth = frame.width;
        _frameHeight = frame.height;
        if (_eventSink != nil) {
            NSDictionary* map = @{
                @"event" : @"onTextureChangeVideoSize",
                @"id" : _textureId,
                @"width" : [NSNumber numberWithLong:frame.width],
                @"height" : [NSNumber numberWithLong:frame.height],
            };
            _eventSink(map);
        }
    }

    __weak TextureVideoRenderer* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      __strong TextureVideoRenderer* strongSelf = weakSelf;
      if (strongSelf) {
          [strongSelf.registry textureFrameAvailable:strongSelf->_tid];
      }
    });
}

// Returns ID of this `TextureVideoRenderer`.
- (NSNumber*)textureId {
    return _textureId;
}

// Frees `EventSink` of this `TextureVideoRenderer`.
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

// Sets a new `EventSink` of this `TextureVideoRenderer`.
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:
                                           (nonnull FlutterEventSink)sink {
    _eventSink = sink;
    return nil;
}

// Returns `PixelBuffer` of this `TextureVideoRenderer`.
- (CVPixelBufferRef)copyPixelBuffer {
    if (_pixelBufferRef != nil) {
        CVBufferRetain(_pixelBufferRef);
        return _pixelBufferRef;
    }
    return nil;
}
@end

@implementation VideoRendererManager
// Initializes a new `VideoRendererManager`.
- (VideoRendererManager*)init:(id<FlutterTextureRegistry>)registry
                    messenger:(id<FlutterBinaryMessenger>)messenger {
    _renderers = [[NSMutableDictionary alloc] init];
    _registry = registry;
    _messenger = messenger;
    return self;
}

// Creates a new `TextureVideoRenderer`.
- (void)createVideoRendererTexture:(FlutterResult)result {
    TextureVideoRenderer* renderer =
        [[TextureVideoRenderer alloc] init:_registry messenger:_messenger];
    NSNumber* textureId = [renderer textureId];
    [_renderers setObject:renderer forKey:textureId];

    NSDictionary* map = @{
        @"textureId" : textureId,
        @"channelId" : textureId,
    };
    result(map);
}

// Disposes this `TextureVideoRenderer` based on the provided
// `FlutterMethodCall`.
- (void)videoRendererDispose:(FlutterMethodCall*)methodCall
                      result:(FlutterResult)result {
    NSDictionary* arguments = methodCall.arguments;
    NSNumber* textureId = arguments[@"textureId"];

    TextureVideoRenderer* renderer = _renderers[textureId];
    [_registry unregisterTexture:[textureId intValue]];
    [_renderers removeObjectForKey:textureId];
    result(@{});
}

// Creates a new `TextureVideoRenderer` into which `Frame`s will be passed from
// Rust side.
- (void)createFrameHandler:(FlutterMethodCall*)methodCall
                    result:(FlutterResult)result {
    NSDictionary* arguments = methodCall.arguments;
    NSNumber* textureId = arguments[@"textureId"];
    TextureVideoRenderer* renderer = _renderers[textureId];

    int64_t rendererPtr = (int64_t)renderer;
    result(@{
        @"handler_ptr" : [NSNumber numberWithLong:rendererPtr],
    });
}
@end
