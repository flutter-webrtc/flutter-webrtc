#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif
#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (DesktopCapturer)

-(void)getDisplayMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;

-(void)getDesktopSources:(NSDictionary *)argsMap
             result:(FlutterResult)result;

-(void)getDesktopSourceThumbnail:(NSDictionary *)argsMap
             result:(FlutterResult)result;
@end