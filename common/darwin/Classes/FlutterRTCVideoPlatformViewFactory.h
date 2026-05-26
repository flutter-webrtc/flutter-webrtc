#import "FlutterRTCVideoPlatformTypes.h"

#define FlutterRTCVideoPlatformViewFactoryID @"rtc_video_platform_view"

@class FlutterRTCVideoPlatformViewController;

@interface FlutterRTCVideoPlatformViewFactory : NSObject <FlutterPlatformViewFactory>

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* _Nonnull messenger;
@property(nonatomic, strong)
    NSMutableDictionary<NSNumber*, FlutterRTCVideoPlatformViewController*>* _Nullable renders;

- (_Nonnull instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger;

@end
