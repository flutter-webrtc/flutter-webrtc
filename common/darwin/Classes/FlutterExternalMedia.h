#import <TargetConditionals.h>
#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#import <WebRTC/WebRTC.h>
@class FlutterWebRTCPlugin;
@interface FlutterExternalMedia : NSObject <FlutterStreamHandler>
@property(nonatomic,readonly) id<RTCAudioDevice> audioDevice;
- (instancetype)initWithPlugin:(FlutterWebRTCPlugin*)plugin messenger:(id<FlutterBinaryMessenger>)messenger;
- (void)handleCall:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)close;
@end
#endif
