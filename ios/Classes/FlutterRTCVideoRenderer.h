#import "FlutterWebRTCPlugin.h"

#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCVideoFrame.h>
#import <WebRTC/RTCVideoTrack.h>

@interface FlutterRTCVideoRenderer : NSObject <FlutterTexture, RTCVideoRenderer, FlutterStreamHandler>

/**
 * The {@link RTCVideoTrack}, if any, which this instance renders.
 */
@property (nonatomic, strong) RTCVideoTrack *videoTrack;
@property (nonatomic) int64_t textureId;
@property (nonatomic, weak) id<FlutterTextureRegistry> registry;
@property (nonatomic, strong) FlutterEventSink eventSink;

- (instancetype)initWithSize:(CGSize)renderSize;

- (void)dispose;

@end


@interface FlutterWebRTCPlugin (FlutterVideoRendererManager)

- (FlutterRTCVideoRenderer *)createWithSize:(CGSize)size
             withTextureRegistry:(id<FlutterTextureRegistry>)registry
                       messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(void)setStreamId:(NSString*)streamId view:(FlutterRTCVideoRenderer*)view;

@end
