#ifndef FlutterRTCVideoPlatformTypes_h
#define FlutterRTCVideoPlatformTypes_h

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
typedef UIView FlutterRTCVideoPlatformNativeView;
typedef CGRect FlutterRTCVideoPlatformFrame;
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
typedef NSView FlutterRTCVideoPlatformNativeView;
typedef NSRect FlutterRTCVideoPlatformFrame;
#endif

#endif /* FlutterRTCVideoPlatformTypes_h */
