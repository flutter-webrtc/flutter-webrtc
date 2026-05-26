#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#define FLutterRTCVideoPlatformViewFactoryID @"rtc_video_platform_view"

@class FlutterRTCVideoPlatformViewController;

@interface FLutterRTCVideoPlatformViewFactory : NSObject <FlutterPlatformViewFactory>

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* _Nonnull messenger;
@property(nonatomic, strong)
    NSMutableDictionary<NSNumber*, FlutterRTCVideoPlatformViewController*>* _Nullable renders;

- (_Nonnull instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger;

@end
