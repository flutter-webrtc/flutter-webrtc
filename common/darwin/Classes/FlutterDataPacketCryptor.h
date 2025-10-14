#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <WebRTC/WebRTC.h>

#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (DataPacketCryptor)

- (void)handleDataPacketCryptorMethodCall:(nonnull FlutterMethodCall*)call
                                   result:(nonnull FlutterResult)result;

@end
