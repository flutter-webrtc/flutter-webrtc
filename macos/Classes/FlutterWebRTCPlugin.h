#import <FlutterMacOS/FlutterMacOS.h>
#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@class FlutterRTCVideoRenderer;

@interface FlutterWebRTCPlugin : NSObject<FlutterPlugin, RTCPeerConnectionDelegate>

@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCPeerConnection *> *peerConnections;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStream *> *localStreams;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *localTracks;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, FlutterRTCVideoRenderer *> *renders;
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger>* messenger;
@property (nonatomic, strong) RTCCameraVideoCapturer *videoCapturer;
@property (nonatomic) BOOL _usingFrontCamera;
@property (nonatomic) int _targetWidth;
@property (nonatomic) int _targetHeight;
@property (nonatomic) int _targetFps;

- (RTCMediaStream*)streamForId:(NSString*)streamId peerConnectionId:(NSString *)peerConnectionId;

@end
