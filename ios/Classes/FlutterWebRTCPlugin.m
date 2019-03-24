#import "FlutterWebRTCPlugin.h"
#import "FlutterRTCPeerConnection.h"
#import "FlutterRTCMediaStream.h"
#import "FlutterRTCDataChannel.h"
#import "FlutterRTCVideoRenderer.h"

#import <AVFoundation/AVFoundation.h>
#import <WebRTC/WebRTC.h>



@implementation FlutterWebRTCPlugin {
    FlutterMethodChannel *_methodChannel;
    id _registry;
    id _messenger;
    id _textures;
}

@synthesize messenger = _messenger;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"cloudwebrtc.com/WebRTC.Method"
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController = (UIViewController *)registrar.messenger;
    FlutterWebRTCPlugin* instance = [[FlutterWebRTCPlugin alloc] initWithChannel:channel
                                                                       registrar:registrar
                                                                       messenger:[registrar messenger]
                                                                  viewController:viewController
                                                                    withTextures:[registrar textures]];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger
                 viewController:(UIViewController *)viewController
                   withTextures:(NSObject<FlutterTextureRegistry> *)textures{

    self = [super init];
    
    if (self) {
        _methodChannel = channel;
        _registry = registrar;
        _textures = textures;
        _messenger = messenger;
        self.viewController = viewController;
    }
    
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    
    _peerConnectionFactory = [[RTCPeerConnectionFactory alloc]
                              initWithEncoderFactory:encoderFactory
                              decoderFactory:decoderFactory];
    
    
    self.peerConnections = [NSMutableDictionary new];
    self.localStreams = [NSMutableDictionary new];
    self.localTracks = [NSMutableDictionary new];
    self.renders = [[NSMutableDictionary alloc] init];
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
        
        peerConnection.remoteStreams = [NSMutableDictionary new];
        peerConnection.remoteTracks = [NSMutableDictionary new];
        peerConnection.dataChannels = [NSMutableDictionary new];
        
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
    } else if ([@"getDisplayMedia" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary* constraints = argsMap[@"constraints"];
        [self getDisplayMedia:constraints result:result];
    } else if ([@"getSources" isEqualToString:call.method]) {
        [self getSources:result];
    }else if ([@"mediaStreamGetTracks" isEqualToString:call.method]) {
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
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                                       details:nil]);
        }
    }  else if ([@"createAnswer" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary * constraints = argsMap[@"constraints"];
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection)
        {
            [self peerConnectionCreateAnswer:constraints
                              peerConnection:peerConnection
                                      result:result];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
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
                                       message:[NSString stringWithFormat:@"Error: peerConnection or mediaStream not found!"]
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
                                       message:[NSString stringWithFormat:@"Error: peerConnection or mediaStream not found!"]
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
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
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
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                                       details:nil]);
        }
    }  else if ([@"addCandidate" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSDictionary* candMap = argsMap[@"candidate"];
        NSString *sdp = candMap[@"candidate"];
        int sdpMLineIndex = ((NSNumber*)candMap[@"sdpMLineIndex"]).intValue;
        NSString *sdpMid = candMap[@"sdpMid"];
    
        RTCIceCandidate* candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        if(peerConnection)
        {
            [self peerConnectionAddICECandidate:candidate peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
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
                         config:[self RTCDataChannelConfiguration:dataChannelDict]
                      messenger:_messenger];
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
        NSDictionary* argsMap = call.arguments;
        NSString* streamId = argsMap[@"streamId"];
        RTCMediaStream *stream = self.localStreams[streamId];
        if (stream) {
            for (RTCVideoTrack *track in stream.videoTracks) {
                [self.localTracks removeObjectForKey:track.trackId];
                RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
                RTCVideoSource *source = videoTrack.source;
                if(source){
                    [self.videoCapturer stopCapture];
                    self.videoCapturer = nil;
                }
            }
            for (RTCAudioTrack *track in stream.audioTracks) {
                [self.localTracks removeObjectForKey:track.trackId];
            }
            [self.localStreams removeObjectForKey:streamId];
        }
        result(nil);
    }else if([@"mediaStreamTrackSetEnable" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        NSNumber* enabled = argsMap[@"enabled"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if(track != nil){
            track.isEnabled = enabled.boolValue;
        }
        result(nil);
    }else if([@"trackDispose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        [self.localTracks removeObjectForKey:trackId];
        result(nil);
    }else if([@"peerConnectionClose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if (!peerConnection) {
            return;
        }
        [peerConnection close];
        [self.peerConnections removeObjectForKey:peerConnectionId];
        
        // Clean up peerConnection's streams and tracks
        [peerConnection.remoteStreams removeAllObjects];
        [peerConnection.remoteTracks removeAllObjects];
        
        // Clean up peerConnection's dataChannels.
        NSMutableDictionary<NSNumber *, RTCDataChannel *> *dataChannels
        = peerConnection.dataChannels;
        for (NSNumber *dataChannelId in dataChannels) {
            dataChannels[dataChannelId].delegate = nil;
            // There is no need to close the RTCDataChannel because it is owned by the
            // RTCPeerConnection and the latter will close the former.
        }
        [dataChannels removeAllObjects];
        result(nil);
    }else if([@"createVideoRenderer" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        CGFloat width = [argsMap[@"width"] floatValue];
        CGFloat height = [argsMap[@"height"] floatValue];
        FlutterRTCVideoRenderer* render = [self createWithSize:CGSizeMake(width, height)
                                withTextureRegistry:_textures
                                          messenger:_messenger];
        self.renders[@(render.textureId)] = render;
        result(@{@"textureId": @(render.textureId)});
    }else if([@"videoRendererDispose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSNumber *textureId = argsMap[@"textureId"];
        FlutterRTCVideoRenderer *render = self.renders[textureId];
        render.videoTrack = nil;
        [render dispose];
        [self.renders removeObjectForKey:textureId];
        result(nil);
    }else if([@"videoRendererSetSrcObject" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSNumber *textureId = argsMap[@"textureId"];
        FlutterRTCVideoRenderer *render = self.renders[textureId];
        NSString *streamId = argsMap[@"streamId"];
        if(render){
            [self setStreamId:streamId view:render];
        }
        result(nil);
    }else if ([@"mediaStreamTrackSwitchCamera" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
            RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
            [self mediaStreamTrackSwitchCamera:videoTrack];
        } else {
            if (track == nil) {
                NSLog(@"Track is nil");
            } else {
                NSLog([@"Track is class of " stringByAppendingString:[[track class] description]]);
            }
        }
        result(nil);
    }else if ([@"setVolume" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        NSNumber* volume = argsMap[@"volume"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if (track != nil && [track isKindOfClass:[RTCAudioTrack class]]) {
            RTCAudioTrack *audioTrack = (RTCAudioTrack *)track;
            RTCAudioSource *audioSource = audioTrack.source;
            audioSource.volume = [volume doubleValue];
        }
        result(nil);
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
            [self.localTracks setObject:track forKey:trackId];
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
            [self.localTracks setObject:track forKey:trackId];
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
            init.protocol = json[@"protocol"];
        }
        return init;
    }
    return nil;
}

- (CGRect)parseRect:(NSDictionary *)rect {
    return CGRectMake([[rect valueForKey:@"left"] doubleValue],
                      [[rect valueForKey:@"top"] doubleValue],
                      [[rect valueForKey:@"width"] doubleValue],
                      [[rect valueForKey:@"height"] doubleValue]);
}

@end

