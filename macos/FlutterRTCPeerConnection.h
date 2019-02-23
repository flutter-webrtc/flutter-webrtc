#import "FlutterWebRTCPlugin.h"

@interface RTCPeerConnection (Flutter) <FLEStreamHandler>
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCDataChannel *> *dataChannels;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStream *> *remoteStreams;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *remoteTracks;
@property (nonatomic, strong) NSString *flutterId;
@property (nonatomic, strong) FLEEventSink eventSink;
@property (nonatomic, strong) FLEEventChannel* eventChannel;
@end

@interface FlutterWebRTCPlugin (RTCPeerConnection)

-(void) peerConnectionCreateOffer:(NSDictionary *)constraints
                   peerConnection:(RTCPeerConnection*)peerConnection
                           result:(FLEMethodResult)result;

-(void) peerConnectionCreateAnswer:(NSDictionary *)constraints
                    peerConnection:(RTCPeerConnection *)peerConnection
                            result:(FLEMethodResult)result;

-(void) peerConnectionSetLocalDescription:(RTCSessionDescription *)sdp
                           peerConnection:(RTCPeerConnection *)peerConnection
                                   result:(FLEMethodResult)result;

-(void) peerConnectionSetRemoteDescription:(RTCSessionDescription *)sdp
                            peerConnection:(RTCPeerConnection *)peerConnection
                                    result:(FLEMethodResult)result;

-(void) peerConnectionAddICECandidate:(RTCIceCandidate*)candidate
                       peerConnection:(RTCPeerConnection *)peerConnection
                               result:(FLEMethodResult)result;

-(void) peerConnectionGetStats:(nonnull NSString *)trackID
                peerConnection:(nonnull RTCPeerConnection *)peerConnection
                        result:(nonnull FLEMethodResult)result;

- (RTCMediaConstraints *)parseMediaConstraints:(nonnull NSDictionary *)constraints;

@end
