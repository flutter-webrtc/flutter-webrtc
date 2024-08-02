#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <WebRTC/WebRTC.h>

@interface FlutterRTCVideoPlatformViewController
    : NSObject <FlutterPlatformView, FlutterStreamHandler, RTCVideoRenderer>

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* _Nonnull messenger;
@property(nonatomic, strong) FlutterEventSink _Nonnull eventSink;
@property(nonatomic) int64_t viewId;
@property(nonatomic, strong) RTCVideoTrack* _Nullable videoTrack;

- (instancetype _Nullable)initWithMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                             viewIdentifier:(int64_t)viewId
                                      frame:(CGRect)frame;

- (UIView* _Nonnull)view;

@end
