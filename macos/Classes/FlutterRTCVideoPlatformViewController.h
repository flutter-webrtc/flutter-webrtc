#import <FlutterMacOS/FlutterMacOS.h>
#import <WebRTC/WebRTC.h>

@interface FlutterRTCVideoPlatformViewController
    : NSObject <FlutterStreamHandler, RTCVideoRenderer>

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* _Nonnull messenger;
@property(nonatomic, strong) FlutterEventSink _Nonnull eventSink;
@property(nonatomic) int64_t viewId;
@property(nonatomic, strong) RTCVideoTrack* _Nullable videoTrack;

- (instancetype _Nullable)initWithMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                             viewIdentifier:(int64_t)viewId;

- (NSView* _Nonnull)view;

@end
