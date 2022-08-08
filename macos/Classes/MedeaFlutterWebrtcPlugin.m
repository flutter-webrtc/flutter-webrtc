#import "MedeaFlutterWebrtcPlugin.h"

@implementation MedeaFlutterWebrtcPlugin
// Registers this `MedeaFlutterWebRtcPlugin`.
+ (void)registerWithRegistrar:(nonnull id<FlutterPluginRegistrar>)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"FlutterWebRtc/VideoRendererFactory/0"
              binaryMessenger:[registrar messenger]];
    MedeaFlutterWebrtcPlugin* instance = [MedeaFlutterWebrtcPlugin alloc];
    MedeaFlutterWebrtcPlugin* finalInstance =
        [instance initWithChannel:channel:[registrar messenger]];
    [registrar addMethodCallDelegate:finalInstance channel:channel];
    VideoRendererManager* manager =
        [[VideoRendererManager alloc] init:[registrar textures]
                                 messenger:[registrar messenger]];
    instance->_videoRendererManager = manager;
}

// Handles the provided `FlutterMethodCall`.
- (void)handleMethodCall:(nonnull FlutterMethodCall*)methodCall
                  result:(nonnull FlutterResult)result {
    NSString* method = methodCall.method;
    if ([method isEqualToString:@"create"]) {
        [_videoRendererManager createVideoRendererTexture:result];
    } else if ([method isEqualToString:@"dispose"]) {
        [_videoRendererManager videoRendererDispose:methodCall result:result];
    } else if ([method isEqualToString:@"createFrameHandler"]) {
        [_videoRendererManager createFrameHandler:methodCall result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// Initializes this `MedeaFlutterWebrtcPlugin` with the provided
// `FlutterMethodChannel`.
- (instancetype)initWithChannel:(FlutterMethodChannel*)
                        channel:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    return self;
}
@end
