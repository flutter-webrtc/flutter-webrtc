#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@class FlutterRTCVideoRenderer;
@class FlutterRTCFrameCapturer;

typedef void (^CompletionHandler)(void);

typedef void (^CapturerStopHandler)(CompletionHandler handler);

@interface FlutterWebRTCPlugin : NSObject <FlutterPlugin,
                                           RTCPeerConnectionDelegate,
                                           FlutterStreamHandler
#if TARGET_OS_OSX
                                           ,
                                           RTCDesktopMediaListDelegate,
                                           RTCDesktopCapturerDelegate
#endif
                                           >

@property(nonatomic, strong) RTCPeerConnectionFactory* peerConnectionFactory;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCPeerConnection*>* peerConnections;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCMediaStream*>* localStreams;
@property(nonatomic, strong) NSMutableDictionary<NSString*, RTCMediaStreamTrack*>* localTracks;
@property(nonatomic, strong) NSMutableDictionary<NSNumber*, FlutterRTCVideoRenderer*>* renders;
@property(nonatomic, strong)
    NSMutableDictionary<NSString*, CapturerStopHandler>* videoCapturerStopHandlers;

#if TARGET_OS_IPHONE
@property(nonatomic, retain) UIViewController* viewController; /*for broadcast or ReplayKit */
#endif

@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, strong) NSObject<FlutterBinaryMessenger>* messenger;
@property(nonatomic, strong) RTCCameraVideoCapturer* videoCapturer;
@property(nonatomic, strong) FlutterRTCFrameCapturer* frameCapturer;
@property(nonatomic, strong) AVAudioSessionPort preferredInput;
@property(nonatomic) BOOL _usingFrontCamera;
@property(nonatomic) int _targetWidth;
@property(nonatomic) int _targetHeight;
@property(nonatomic) int _targetFps;

- (RTCMediaStream*)streamForId:(NSString*)streamId peerConnectionId:(NSString*)peerConnectionId;
- (RTCRtpTransceiver*)getRtpTransceiverById:(RTCPeerConnection*)peerConnection Id:(NSString*)Id;
- (NSDictionary*)mediaStreamToMap:(RTCMediaStream*)stream ownerTag:(NSString*)ownerTag;
- (NSDictionary*)mediaTrackToMap:(RTCMediaStreamTrack*)track;
- (NSDictionary*)receiverToMap:(RTCRtpReceiver*)receiver;
- (NSDictionary*)transceiverToMap:(RTCRtpTransceiver*)transceiver;

- (BOOL)hasLocalAudioTrack;
- (void)ensureAudioSession;
- (void)deactiveRtcAudioSession;

@end
