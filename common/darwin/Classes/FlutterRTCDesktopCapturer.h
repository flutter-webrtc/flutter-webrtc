#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"
#import <WebRTC/WebRTC.h>

//#if TARGET_OS_MAC

@interface FlutterWebRTCPlugin (DesktopCapturer) <RTCDesktopMediaListDelegate>

-(void)getDisplayMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;

-(void)getDesktopSources:(NSDictionary *)argsMap
             result:(FlutterResult)result;

-(void)getDesktopSourceThumbnail:(NSDictionary *)argsMap
             result:(FlutterResult)result;
@end

//#endif
