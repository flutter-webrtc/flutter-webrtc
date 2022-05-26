#import "FlutterWebRTCPlugin.h"

@interface RTCPeerConnection (Flutter) <FlutterStreamHandler>
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSString *, RTCDataChannel *> *dataChannels;
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSString *, RTCMediaStream *> *remoteStreams;
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *remoteTracks;
@property (nonatomic, strong, nonnull) NSString *flutterId;
@property (nonatomic, strong, nullable) FlutterEventSink eventSink;
@property (nonatomic, strong, nullable) FlutterEventChannel* eventChannel;
@end

@interface FlutterWebRTCPlugin (RTCPeerConnection)

-(void) peerConnectionCreateOffer:(nonnull NSDictionary *)constraints
                   peerConnection:(nonnull RTCPeerConnection*)peerConnection
                           result:(nonnull FlutterResult)result;

-(void) peerConnectionCreateAnswer:(nonnull NSDictionary *)constraints
                    peerConnection:(nonnull RTCPeerConnection *)peerConnection
                            result:(nonnull FlutterResult)result;

-(void) peerConnectionSetLocalDescription:(nonnull RTCSessionDescription *)sdp
                           peerConnection:(nonnull RTCPeerConnection *)peerConnection
                                   result:(nonnull FlutterResult)result;

-(void) peerConnectionSetRemoteDescription:(nonnull RTCSessionDescription *)sdp
                            peerConnection:(nonnull RTCPeerConnection *)peerConnection
                                    result:(nonnull FlutterResult)result;

-(void) peerConnectionAddICECandidate:(nonnull RTCIceCandidate*)candidate
                       peerConnection:(nonnull RTCPeerConnection *)peerConnection
                               result:(nonnull FlutterResult)result;

-(void) peerConnectionGetStats:(nonnull NSString *)trackID
                peerConnection:(nonnull RTCPeerConnection *)peerConnection
                        result:(nonnull FlutterResult)result;

-(nonnull RTCMediaConstraints *) parseMediaConstraints:(nonnull NSDictionary *)constraints;

-(void) peerConnectionSetConfiguration:(nonnull RTCConfiguration*)configuration
                        peerConnection:(nonnull RTCPeerConnection*)peerConnection;

@end
