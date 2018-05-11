#import "FlutterWebRTCPlugin.h"

#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCVideoFrame.h>
#import <WebRTC/RTCVideoTrack.h>


typedef void(^onChangeVideoSizeCallback)(int width, int height);
typedef void(^onRotationChangeCallback)(int rotation);

/**
 * Implements an equivalent of {@code HTMLVideoElement} i.e. Web's video
 * element.
 */
@interface RTCVideoView : NSObject <FlutterTexture, RTCVideoRenderer, FlutterStreamHandler>

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


@interface FlutterWebRTCPlugin (RTCVideoViewManager)

- (RTCVideoView *)createWithSize:(CGSize)size
             withTextureRegistry:(id<FlutterTextureRegistry>)registry
                       messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(void)setStreamId:(NSString*)streamId view:(RTCVideoView*)view;

@end
