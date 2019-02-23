#import "FLEWebRTCPlugin.h"
#import "FlutterWebRTCPlugin.h"

@implementation FLEWebRTCPlugin

+ (void)registerWithRegistrar:(nonnull id<FLEPluginRegistrar>)registrar{
    FLEMethodChannel* channel = [FLEMethodChannel
                                 methodChannelWithName:@"cloudwebrtc.com/WebRTC.Method"
                                 binaryMessenger:registrar.messenger
                                 codec:[FLEJSONMethodCodec sharedInstance]];
    FlutterWebRTCPlugin* instance = [[FlutterWebRTCPlugin alloc] initWithPluginRegistrar:registrar channel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

@end
