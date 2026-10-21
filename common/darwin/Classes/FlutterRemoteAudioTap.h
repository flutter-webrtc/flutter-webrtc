#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif
#import <Foundation/Foundation.h>

@class FlutterWebRTCPlugin;

NS_ASSUME_NONNULL_BEGIN

/// Experimental: delivers the decoded PCM of remote audio tracks to Dart
/// (`RTCRemoteAudioTap`). See Documentation/remote-audio-tap.md.
@interface FlutterRemoteAudioTaps : NSObject
- (instancetype)initWithPlugin:(FlutterWebRTCPlugin*)plugin
                     messenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)handleCall:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)close;
@end

NS_ASSUME_NONNULL_END
