#import <Foundation/Foundation.h>

#import "FlutterWebRTCPlugin.h"

#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCVideoFrame.h>
#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCVideoTrack.h>

#import "FlutterRTCVideoFrameTransform.h"

@interface ExportFrame : NSObject

@property (nonatomic, assign)BOOL enabledExportFrame;
@property (nonatomic, strong)NSNumber *frameCount;
@property (nonatomic, assign)RTCVideoFrameFormat format;

- (instancetype)initWithEnabledExportFrame:(BOOL)enabled frameCount:(NSNumber *)count format:(RTCVideoFrameFormat)format;

@end

@interface FlutterRTCVideoRenderer
    : NSObject <FlutterTexture, RTCVideoRenderer, FlutterStreamHandler>

/**
 * The {@link RTCVideoTrack}, if any, which this instance renders.
 */
@property(nonatomic, strong) RTCVideoTrack* videoTrack;
@property(nonatomic) int64_t textureId;
@property(nonatomic, weak) id<FlutterTextureRegistry> registry;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) ExportFrame *exportFrame;
@property (nonatomic) int frameCount;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (void)dispose;

@end

@interface FlutterWebRTCPlugin (FlutterVideoRendererManager)

- (FlutterRTCVideoRenderer*)createWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                                            messenger:(NSObject<FlutterBinaryMessenger>*)messenger
                                          exportFrame: (ExportFrame *)exportFrame;

- (void)rendererSetSrcObject:(FlutterRTCVideoRenderer*)renderer stream:(RTCVideoTrack*)videoTrack;

@end
