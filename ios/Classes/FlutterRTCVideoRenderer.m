#import "FlutterRTCVideoRenderer.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CGImage.h>
#import <WebRTC/WebRTC.h>
#import <WebRTC/RTCYUVPlanarBuffer.h>

#import <objc/runtime.h>
#include "libyuv.h"

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


-(id<RTCI420Buffer>) correctRotation:(const id<RTCI420Buffer>) src
                                withRotation:(RTCVideoRotation) rotation
{
    
    int rotated_width = src.width;
    int rotated_height = src.height;

    if (rotation ==  RTCVideoRotation_90 ||
        rotation == RTCVideoRotation_270) {
        int temp = rotated_width;
        rotated_width = rotated_height;
        rotated_height = temp;
    }
    
    id<RTCI420Buffer> buffer = [[RTCI420Buffer alloc] initWithWidth:rotated_width height:rotated_height];
    
    I420Rotate(src.dataY, src.strideY,
               src.dataU, src.strideU,
               src.dataV, src.strideV,
               (uint8_t*)buffer.dataY, buffer.strideY,
               (uint8_t*)buffer.dataU,buffer.strideU,
               (uint8_t*)buffer.dataV, buffer.strideV,
               src.width, src.height,
               (RotationModeEnum)rotation);
    
    return buffer;
}

-(void)copyI420ToCVPixelBuffer:(CVPixelBufferRef)outputPixelBuffer withFrame:(RTCVideoFrame *) frame
{
    id<RTCI420Buffer> i420Buffer = [self correctRotation:[frame.buffer toI420] withRotation:frame.rotation];
    CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);

    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(outputPixelBuffer);
    if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
        pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        // NV12
        uint8_t* dstY = CVPixelBufferGetBaseAddressOfPlane(outputPixelBuffer, 0);
        const size_t dstYStride = CVPixelBufferGetBytesPerRowOfPlane(outputPixelBuffer, 0);
        uint8_t* dstUV = CVPixelBufferGetBaseAddressOfPlane(outputPixelBuffer, 1);
        const size_t dstUVStride = CVPixelBufferGetBytesPerRowOfPlane(outputPixelBuffer, 1);
        
        I420ToNV12(i420Buffer.dataY,
                           i420Buffer.strideY,
                           i420Buffer.dataU,
                           i420Buffer.strideU,
                           i420Buffer.dataV,
                           i420Buffer.strideV,
                           dstY,
                           (int)dstYStride,
                           dstUV,
                           (int)dstUVStride,
                           i420Buffer.width,
                           i420Buffer.height);
    } else {
        uint8_t* dst = CVPixelBufferGetBaseAddress(outputPixelBuffer);
        const size_t bytesPerRow = CVPixelBufferGetBytesPerRow(outputPixelBuffer);
        
        if (pixelFormat == kCVPixelFormatType_32BGRA) {
            // Corresponds to libyuv::FOURCC_ARGB
            I420ToARGB(i420Buffer.dataY,
                               i420Buffer.strideY,
                               i420Buffer.dataU,
                               i420Buffer.strideU,
                               i420Buffer.dataV,
                               i420Buffer.strideV,
                               dst,
                               (int)bytesPerRow,
                               i420Buffer.width,
                               i420Buffer.height);
        } else if (pixelFormat == kCVPixelFormatType_32ARGB) {
            // Corresponds to libyuv::FOURCC_BGRA
            I420ToBGRA(i420Buffer.dataY,
                               i420Buffer.strideY,
                               i420Buffer.dataU,
                               i420Buffer.strideU,
                               i420Buffer.dataV,
                               i420Buffer.strideV,
                               dst,
                               (int)bytesPerRow,
                               i420Buffer.width,
                               i420Buffer.height);
        }
    }
    
    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, 0);
}

#pragma mark - RTCVideoRenderer methods
- (void)renderFrame:(RTCVideoFrame *)frame {

    [self copyI420ToCVPixelBuffer:_pixelBufferRef withFrame:frame];
    
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
            NSLog(@"No video track for RTCMediaStream: %@", streamId);
        }
    } else {
        videoTrack = nil;
    }
    
    view.videoTrack = videoTrack;
}

@end

