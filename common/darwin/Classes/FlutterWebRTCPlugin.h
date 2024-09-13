#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@class FlutterRTCVideoRenderer;
@class FlutterRTCFrameCapturer;

void postEvent(FlutterEventSink _Nonnull sink, id _Nullable event);

typedef void (^CompletionHandler)(void);

typedef void (^CapturerStopHandler)(CompletionHandler _Nonnull handler);

@interface FlutterWebRTCPlugin : NSObject <FlutterPlugin,
                                           RTCPeerConnectionDelegate,
                                           FlutterStreamHandler
#if TARGET_OS_OSX
                                           ,
                                           RTCDesktopMediaListDelegate,
                                           RTCDesktopCapturerDelegate
#endif
                                           >

@property(nonatomic, strong) RTCPeerConnectionFactory* _Nullable peerConnectionFactory;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCPeerConnection*>* _Nullable peerConnections;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCMediaStream*>* _Nullable localStreams;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCMediaStreamTrack*>* _Nullable localTracks;
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, FlutterRTCVideoRenderer*>* _Nullable renders;
@property(nonatomic, strong)
    NSMutableDictionary<NSString*, CapturerStopHandler>* _Nullable videoCapturerStopHandlers;

@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCFrameCryptor*>* _Nullable frameCryptors;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCFrameCryptorKeyProvider*>* _Nullable keyProviders;

#if TARGET_OS_IPHONE
@property(nonatomic, retain) UIViewController* _Nullable viewController; /*for broadcast or ReplayKit */
#endif

@property(nonatomic, strong) FlutterEventSink _Nullable eventSink;
@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* _Nonnull messenger;
@property(nonatomic, strong) RTCCameraVideoCapturer* _Nullable videoCapturer;
@property(nonatomic, strong) FlutterRTCFrameCapturer* _Nullable frameCapturer;
@property(nonatomic, strong) AVAudioSessionPort _Nullable preferredInput;

@property(nonatomic) BOOL _usingFrontCamera;
@property(nonatomic) NSInteger _lastTargetWidth;
@property(nonatomic) NSInteger _lastTargetHeight;
@property(nonatomic) NSInteger _lastTargetFps;

- (RTCMediaStream* _Nullable)streamForId:(NSString* _Nonnull)streamId peerConnectionId:(NSString* _Nonnull)peerConnectionId;
- (RTCMediaStreamTrack* _Nullable)trackForId:(NSString* _Nonnull)trackId peerConnectionId:(NSString*)peerConnectionId;
- (RTCRtpTransceiver* _Nullable)getRtpTransceiverById:(RTCPeerConnection* _Nonnull)peerConnection Id:(NSString* _Nonnull)Id;
- (NSDictionary* _Nullable)mediaStreamToMap:(RTCMediaStream* _Nonnull)stream ownerTag:(NSString* _Nonnull)ownerTag;
- (NSDictionary* _Nullable)mediaTrackToMap:(RTCMediaStreamTrack* _Nonnull)track;
- (NSDictionary* _Nullable)receiverToMap:(RTCRtpReceiver* _Nonnull)receiver;
- (NSDictionary* _Nullable)transceiverToMap:(RTCRtpTransceiver* _Nonnull)transceiver;

- (BOOL)hasLocalAudioTrack;
- (void)ensureAudioSession;
- (void)deactiveRtcAudioSession;

- (RTCRtpReceiver* _Nullable)getRtpReceiverById:(RTCPeerConnection* _Nonnull)peerConnection Id:(NSString* _Nonnull)Id;
- (RTCRtpSender* _Nullable)getRtpSenderById:(RTCPeerConnection* _Nonnull)peerConnection Id:(NSString* _Nonnull)Id;

+ (FlutterWebRTCPlugin *)sharedSingleton;

@end
