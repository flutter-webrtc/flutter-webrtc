#import "FlutterWebRTCPlugin.h"

@interface FlutterRTCVideoRenderer : NSObject <FLETexture, RTCVideoRenderer, FLEStreamHandler>

/**
 * The {@link RTCVideoTrack}, if any, which this instance renders.
 */
@property (nonatomic, strong) RTCVideoTrack *videoTrack;
@property (nonatomic) int64_t textureId;
@property (nonatomic, weak) id<FLETextureRegistrar> registry;
@property (nonatomic, strong) FLEEventSink eventSink;

- (instancetype)initWithSize:(CGSize)renderSize;

- (void)dispose;

@end


@interface FlutterWebRTCPlugin (FlutterVideoRendererManager)

- (FlutterRTCVideoRenderer *)createWithSize:(CGSize)size
             withTextureRegistry:(id<FLETextureRegistrar>)registry
                       messenger:(NSObject<FLEBinaryMessenger>*)messenger;

-(void)setStreamId:(NSString*)streamId view:(FlutterRTCVideoRenderer*)view;

@end
