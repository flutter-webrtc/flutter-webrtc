#import "FlutterWebRTCPlugin.h"

@interface RTCPeerConnection (Flutter) <FlutterStreamHandler>
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCDataChannel *> *dataChannels;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStream *> *remoteStreams;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *remoteTracks;
@property (nonatomic, strong) NSString *flutterId;
@property (nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) FlutterEventChannel* eventChannel;
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
                peerConnection:(nonnull RTCPeerConnection *)peerConnection
                        result:(nonnull FlutterResult)result;

-(RTCMediaConstraints *) parseMediaConstraints:(nonnull NSDictionary *)constraints;

-(void) peerConnectionSetConfiguration:(RTCConfiguration*)configuration
                        peerConnection:(RTCPeerConnection*)peerConnection;

@end
