#import "FlutterWebRTCPlugin.h"

#import <AVFoundation/AVFoundation.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCIceServer.h>

#import "FlutterRTCPeerConnection.h"
#import "FlutterRTCMediaStream.h"
#import "FlutterRTCDataChannel.h"
#import "ARDVideoDecoderFactory.h"
#import "ARDVideoEncoderFactory.h"

@implementation FlutterWebRTCPlugin {
    FlutterMethodChannel *_methodChannel;
    id _registry;
    id _messenger;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"cloudwebrtc.com/WebRTC.Method"
                                     binaryMessenger:[registrar messenger]];
    FlutterWebRTCPlugin* instance = [[FlutterWebRTCPlugin alloc] initWithChannel:channel
                                                            registrar:registrar
                                                                       messenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    
    if (self) {
        _methodChannel = channel;
        _registry = registrar;
        _messenger = messenger;
    }

    ARDVideoDecoderFactory *decoderFactory = [[ARDVideoDecoderFactory alloc] init];
    ARDVideoEncoderFactory *encoderFactory = [[ARDVideoEncoderFactory alloc] init];
    
    _peerConnectionFactory = [[RTCPeerConnectionFactory alloc]
                              initWithEncoderFactory:encoderFactory
                              decoderFactory:decoderFactory];

    //[RTCPeerConnectionFactory initializeSSL];
    
    self.peerConnections = [NSMutableDictionary new];
    self.localStreams = [NSMutableDictionary new];
    self.localTracks = [NSMutableDictionary new];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult) result {
    if ([@"createPeerConnection" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary* configuration = argsMap[@"configuration"];
        NSDictionary* constraints = argsMap[@"constraints"];

        RTCPeerConnection *peerConnection = [self.peerConnectionFactory
                                             peerConnectionWithConfiguration:[self RTCConfiguration:configuration]
                                             constraints:[self parseMediaConstraints:constraints]
                                             delegate:self];
    
        NSString *peerConnectionId = [[NSUUID UUID] UUIDString];
        peerConnection.flutterId  = peerConnectionId;
        
        /*Create Event Channel.*/
        peerConnection.eventChannel = [FlutterEventChannel
                                             eventChannelWithName:[NSString stringWithFormat:@"cloudwebrtc.com/WebRTC/peerConnectoinEvent%@", peerConnectionId]
                                             binaryMessenger:_messenger];
        [peerConnection.eventChannel setStreamHandler:peerConnection];

        self.peerConnections[peerConnectionId] = peerConnection;
        result(@{ @"peerConnectionId" : peerConnectionId});
    } else if ([@"getUserMedia" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary* constraints = argsMap[@"constraints"];
        [self getUserMedia:constraints result:result];
    } else if ([@"mediaStreamGetTracks" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* streamId = argsMap[@"streamId"];
        [self mediaStreamGetTracks:streamId result:result];
    } else if ([@"createOffer" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary* constraints = argsMap[@"constraints"];
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection)
        {
            [self peerConnectionCreateOffer:constraints peerConnection:peerConnection result:result ];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"createAnswer" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary * constraints = (NSDictionary*)argsMap[@"constraints"];
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection)
        {
            [self peerConnectionCreateAnswer:constraints
                              peerConnection:peerConnection
                                      result:result];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"addStream" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
       
        NSString* streamId = ((NSString*)argsMap[@"streamId"]);
        RTCMediaStream *stream = self.localStreams[streamId];
        
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        if(peerConnection && stream){
            [peerConnection addStream:stream];
            result(@"");
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc or stream not found!"]
                                       details:nil]);
        }
    }  else if ([@"removeStream" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        
        NSString* streamId = ((NSString*)argsMap[@"streamId"]);
        RTCMediaStream *stream = self.localStreams[streamId];
        
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        if(peerConnection && stream){
            [peerConnection removeStream:stream];
            result(nil);
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc or stream not found!"]
                                       details:nil]);
        }
    }  else if ([@"setLocalDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        NSDictionary *descriptionMap = argsMap[@"description"];
        NSString* sdp = descriptionMap[@"sdp"];
        RTCSdpType sdpType = [RTCSessionDescription typeForString:descriptionMap[@"type"]];
        RTCSessionDescription* description = [[RTCSessionDescription alloc] initWithType:sdpType sdp:sdp];
        if(peerConnection)
        {
           [self peerConnectionSetLocalDescription:description peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"setRemoteDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        NSDictionary *descriptionMap = argsMap[@"description"];
        NSString* sdp = descriptionMap[@"sdp"];
        RTCSdpType sdpType = [RTCSessionDescription typeForString:descriptionMap[@"type"]];
        RTCSessionDescription* description = [[RTCSessionDescription alloc] initWithType:sdpType sdp:sdp];
        
        if(peerConnection)
        {
            [self peerConnectionSetRemoteDescription:description peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"addIceCandidate" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString *sdp = argsMap[@"candidate"];
        int sdpMLineIndex = ((NSNumber*)argsMap[@"sdpMLineIndex"]).intValue;
        NSString *sdpMid = argsMap[@"sdpMid"];
        
        RTCIceCandidate* candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        if(peerConnection)
        {
            [self peerConnectionAddICECandidate:candidate peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    } else if ([@"getStats" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* trackId = argsMap[@"trackId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection)
            return [self peerConnectionGetStats:trackId peerConnection:peerConnection result:result];
        
        result(nil);
    } else if([@"createDataChannel" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* label = argsMap[@"label"];
        NSDictionary * dataChannelDict = (NSDictionary*)argsMap[@"dataChannelDict"];
        [self createDataChannel:peerConnectionId
                          label:label
                         config:[self RTCDataChannelConfiguration:dataChannelDict]];
        result(nil);
    }else if([@"dataChannelSend" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* dataChannelId = argsMap[@"dataChannelId"];
        NSString* data = argsMap[@"data"];
        NSString* type = argsMap[@"type"];
        [self dataChannelSend:peerConnectionId
                          dataChannelId:dataChannelId
                          data:data
                          type:type];
        result(nil);
    }else if([@"dataChannelClose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* dataChannelId = argsMap[@"dataChannelId"];
        [self dataChannelClose:peerConnectionId
                 dataChannelId:dataChannelId];
        result(nil);
    }else if([@"streamDispose" isEqualToString:call.method]){
        
    }else if([@"trackDispose" isEqualToString:call.method]){
        
    }else if([@"peerConnectionDispose" isEqualToString:call.method]){
        
    }else{
        result(FlutterMethodNotImplemented);
    }
}

- (void)dealloc
{
  [_localTracks removeAllObjects];
  _localTracks = nil;
  [_localStreams removeAllObjects];
  _localStreams = nil;

  for (NSString *peerConnectionId in _peerConnections) {
    RTCPeerConnection *peerConnection = _peerConnections[peerConnectionId];
    peerConnection.delegate = nil;
    [peerConnection close];
  }
  [_peerConnections removeAllObjects];
  _peerConnectionFactory = nil;
}


-(void)mediaStreamGetTracks:(NSString*)streamId
                      result:(FlutterResult)result {
    RTCMediaStream* stream = [self streamForId:streamId];
    if(stream){
        NSMutableArray *audioTracks = [NSMutableArray array];
        NSMutableArray *videoTracks = [NSMutableArray array];

        for (RTCMediaStreamTrack *track in stream.audioTracks) {
            NSString *trackId = track.trackId;
            [audioTracks addObject:@{
                                     @"enabled": @(track.isEnabled),
                                     @"id": trackId,
                                     @"kind": track.kind,
                                     @"label": trackId,
                                     @"readyState": @"live",
                                     @"remote": @(NO)
                                     }];
        }
        
        for (RTCMediaStreamTrack *track in stream.videoTracks) {
            NSString *trackId = track.trackId;
            [videoTracks addObject:@{
                                     @"enabled": @(track.isEnabled),
                                     @"id": trackId,
                                     @"kind": track.kind,
                                     @"label": trackId,
                                     @"readyState": @"live",
                                     @"remote": @(NO)
                                     }];
        }

        result(@{@"audioTracks": audioTracks, @"videoTracks" : videoTracks });
    }else{
        result(nil);
    }
}

- (RTCMediaStream*)streamForId:(NSString*)streamId
{
  RTCMediaStream *stream = _localStreams[streamId];
  if (!stream) {
    for (NSString *peerConnectionId in _peerConnections) {
      RTCPeerConnection *peerConnection = _peerConnections[peerConnectionId];
      stream = peerConnection.remoteStreams[streamId];
      if (stream) {
        break;
      }
    }
  }
  return stream;
}

- (RTCIceServer *)RTCIceServer:(id)json
{
    if (!json) {
        NSLog(@"a valid iceServer value");
        return nil;
    }
    
    if (![json isKindOfClass:[NSDictionary class]]) {
        NSLog(@"must be an object");
        return nil;
    }
    
    NSArray<NSString *> *urls;
    if ([json[@"url"] isKindOfClass:[NSString class]]) {
        // TODO: 'url' is non-standard
        urls = @[json[@"url"]];
    } else if ([json[@"urls"] isKindOfClass:[NSString class]]) {
        urls = @[json[@"urls"]];
    } else {
        urls = (NSArray*)json[@"urls"];
    }
    
    if (json[@"username"] != nil || json[@"credential"] != nil) {
        return [[RTCIceServer alloc]initWithURLStrings:urls
                                              username:json[@"username"]
                                            credential:json[@"credential"]];
    }
    
    return [[RTCIceServer alloc] initWithURLStrings:urls];
}


- (nonnull RTCConfiguration *)RTCConfiguration:(id)json
{
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    
    if (!json) {
        return config;
    }
    
    if (![json isKindOfClass:[NSDictionary class]]) {
        NSLog(@"must be an object");
        return config;
    }
    
    if (json[@"iceServers"] != nil && [json[@"iceServers"] isKindOfClass:[NSArray class]]) {
        NSMutableArray<RTCIceServer *> *iceServers = [NSMutableArray new];
        for (id server in json[@"iceServers"]) {
            RTCIceServer *convert = [self RTCIceServer:server];
            if (convert != nil) {
                [iceServers addObject:convert];
            }
        }
        config.iceServers = iceServers;
    }
    // TODO: Implement the rest of the RTCConfigure options ...
    return config;
}

- (RTCDataChannelConfiguration *)RTCDataChannelConfiguration:(id)json
{
    if (!json) {
        return nil;
    }
    if ([json isKindOfClass:[NSDictionary class]]) {
        RTCDataChannelConfiguration *init = [RTCDataChannelConfiguration new];
        
        if (json[@"id"]) {
            [init setChannelId:(int)[json[@"id"] integerValue]];
        }
        if (json[@"ordered"]) {
            init.isOrdered = [json[@"ordered"] boolValue];
        }
        if (json[@"maxRetransmitTime"]) {
            init.maxRetransmitTimeMs = [json[@"maxRetransmitTime"] integerValue];
        }
        if (json[@"maxRetransmits"]) {
            init.maxRetransmits = [json[@"maxRetransmits"] intValue];
        }
        if (json[@"negotiated"]) {
            init.isNegotiated = [json[@"negotiated"] boolValue];
        }
        if (json[@"protocol"]) {
            init.protocol = [json[@"protocol"] string];
        }
        return init;
    }
    return nil;
}

@end
