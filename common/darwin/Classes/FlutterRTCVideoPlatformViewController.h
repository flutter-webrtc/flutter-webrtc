#import "FlutterRTCVideoPlatformTypes.h"

#import <WebRTC/WebRTC.h>

#if TARGET_OS_IPHONE
@interface FlutterRTCVideoPlatformViewController
    : NSObject <FlutterPlatformView, FlutterStreamHandler, RTCVideoRenderer>
#elif TARGET_OS_OSX
@interface FlutterRTCVideoPlatformViewController : NSObject <FlutterStreamHandler, RTCVideoRenderer>
#endif

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* _Nonnull messenger;
@property(nonatomic, strong) FlutterEventSink _Nullable eventSink;
@property(nonatomic) int64_t viewId;
@property(nonatomic, strong) RTCVideoTrack* _Nullable videoTrack;

- (instancetype _Nullable)initWithMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                             viewIdentifier:(int64_t)viewId
                                      frame:(FlutterRTCVideoPlatformFrame)frame;

- (FlutterRTCVideoPlatformNativeView* _Nonnull)view;

@end
