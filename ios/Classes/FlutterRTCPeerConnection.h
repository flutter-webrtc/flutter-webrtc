#import "FlutterWebRTCPlugin.h"

@interface RTCPeerConnection (Flutter)

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, RTCDataChannel *> *dataChannels;
@property (nonatomic, strong) NSNumber *reactTag;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStream *> *remoteStreams;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *remoteTracks;

@end

@interface FlutterWebRTCPlugin (RTCPeerConnection)

-(void) peerConnectionCreateOffer:(NSDictionary *)constraints
                   peerConnection:(RTCPeerConnection*)peerConnection
                           result:(FlutterResult)result;

-(void) peerConnectionCreateAnswer:(NSDictionary *)constraints
                    peerConnection:(RTCPeerConnection *)peerConnection
                            result:(FlutterResult)result;

-(void) peerConnectionSetLocalDescription:(RTCSessionDescription *)sdp
                           peerConnection:(RTCPeerConnection *)peerConnection
                                   result:(FlutterResult)result;

-(void) peerConnectionSetRemoteDescription:(RTCSessionDescription *)sdp
                            peerConnection:(RTCPeerConnection *)peerConnection
                                    result:(FlutterResult)result;

-(void) peerConnectionAddICECandidate:(RTCIceCandidate*)candidate
                       peerConnection:(RTCPeerConnection *)peerConnection
                               result:(FlutterResult)result;

-(void) peerConnectionGetStats:(nonnull NSString *)trackID
                peerConnection:(RTCPeerConnection *)peerConnection
                        result:(FlutterResult)result;

- (RTCMediaConstraints *)parseMediaConstraints:(NSDictionary *)constraints;

@end
