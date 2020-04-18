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
    BOOL _speakerOn;
}

@synthesize messenger = _messenger;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"FlutterWebRTC.Method"
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
        _speakerOn = NO;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];

    return self;
}


- (void)didSessionRouteChange:(NSNotification *)notification {
  NSDictionary *interuptionDict = notification.userInfo;
  NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];

  switch (routeChangeReason) {
      case AVAudioSessionRouteChangeReasonCategoryChange: {
          NSError* error;
          [[AVAudioSession sharedInstance] overrideOutputAudioPort:_speakerOn? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone error:&error];
      }
      break;

    default:
      break;
  }
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
                                       eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/peerConnectoinEvent%@", peerConnectionId]
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
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                                       details:nil]);
        }
    } else if ([@"createAnswer" isEqualToString:call.method]) {
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
    } else if ([@"addStream" isEqualToString:call.method]) {
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
    } else if ([@"removeStream" isEqualToString:call.method]) {
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
    } else if ([@"captureFrame" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* path = argsMap[@"path"];
        NSString* trackId = argsMap[@"trackId"];

        RTCMediaStreamTrack *track = [self trackForId: trackId];
        if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
            RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
            [self mediaStreamTrackCaptureFrame:videoTrack toPath:path result:result];
        } else {
            if (track == nil) {
                result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
            } else {
                result([FlutterError errorWithCode:[@"Track is class of " stringByAppendingString:[[track class] description]] message:nil details:nil]);
            }
        }
    } else if ([@"setLocalDescription" isEqualToString:call.method]) {
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
    } else if ([@"setRemoteDescription" isEqualToString:call.method]) {
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
    } else if ([@"addCandidate" isEqualToString:call.method]) {
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
    } else if ([@"createDataChannel" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* label = argsMap[@"label"];
        NSDictionary * dataChannelDict = (NSDictionary*)argsMap[@"dataChannelDict"];
        [self createDataChannel:peerConnectionId
                          label:label
                         config:[self RTCDataChannelConfiguration:dataChannelDict]
                      messenger:_messenger];
        result(nil);
    } else if ([@"dataChannelSend" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* dataChannelId = argsMap[@"dataChannelId"];
        NSString* type = argsMap[@"type"];
        id data = argsMap[@"data"];
        
        [self dataChannelSend:peerConnectionId
                dataChannelId:dataChannelId
                         data:data
                         type:type];
        result(nil);
    } else if ([@"dataChannelClose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        NSString* dataChannelId = argsMap[@"dataChannelId"];
        [self dataChannelClose:peerConnectionId
                 dataChannelId:dataChannelId];
        result(nil);
    } else if ([@"streamDispose" isEqualToString:call.method]){
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
    } else if ([@"mediaStreamTrackSetEnable" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        NSNumber* enabled = argsMap[@"enabled"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if(track != nil){
            track.isEnabled = enabled.boolValue;
        }
        result(nil);
    } else if ([@"mediaStreamAddTrack" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* streamId = argsMap[@"streamId"];
        NSString* trackId = argsMap[@"trackId"];

        RTCMediaStream *stream = self.localStreams[streamId];
        if (stream) {
            RTCMediaStreamTrack *track = self.localTracks[trackId];
            if(track != nil) {
                if([track isKindOfClass:[RTCAudioTrack class]]) {
                    RTCAudioTrack *audioTrack = (RTCAudioTrack *)track;
                    [stream addAudioTrack:audioTrack];
                } else if ([track isKindOfClass:[RTCVideoTrack class]]){
                    RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
                    [stream addVideoTrack:videoTrack];
                }
            } else {
                result([FlutterError errorWithCode:@"mediaStreamAddTrack: Track is nil" message:nil details:nil]);
            }
        } else {
            result([FlutterError errorWithCode:@"mediaStreamAddTrack: Stream is nil" message:nil details:nil]);
        }
        result(nil);
    } else if ([@"mediaStreamRemoveTrack" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* streamId = argsMap[@"streamId"];
        NSString* trackId = argsMap[@"trackId"];
        RTCMediaStream *stream = self.localStreams[streamId];
        if (stream) {
            RTCMediaStreamTrack *track = self.localTracks[trackId];
            if(track != nil) {
                if([track isKindOfClass:[RTCAudioTrack class]]) {
                    RTCAudioTrack *audioTrack = (RTCAudioTrack *)track;
                    [stream removeAudioTrack:audioTrack];
                } else if ([track isKindOfClass:[RTCVideoTrack class]]){
                    RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
                    [stream removeVideoTrack:videoTrack];
                }
            } else {
                result([FlutterError errorWithCode:@"mediaStreamRemoveTrack: Track is nil" message:nil details:nil]);
            }
        } else {
            result([FlutterError errorWithCode:@"mediaStreamRemoveTrack: Stream is nil" message:nil details:nil]);
        }
        result(nil);
    } else if ([@"trackDispose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        [self.localTracks removeObjectForKey:trackId];
        result(nil);
    } else if ([@"peerConnectionClose" isEqualToString:call.method] || [@"peerConnectionDispose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if (peerConnection) {
            [peerConnection close];
            [self.peerConnections removeObjectForKey:peerConnectionId];
            
            // Clean up peerConnection's streams and tracks
            [peerConnection.remoteStreams removeAllObjects];
            [peerConnection.remoteTracks removeAllObjects];
            
            // Clean up peerConnection's dataChannels.
            NSMutableDictionary<NSNumber *, RTCDataChannel *> *dataChannels = peerConnection.dataChannels;
            for (NSNumber *dataChannelId in dataChannels) {
                dataChannels[dataChannelId].delegate = nil;
                // There is no need to close the RTCDataChannel because it is owned by the
                // RTCPeerConnection and the latter will close the former.
            }
            [dataChannels removeAllObjects];
        }
        result(nil);
    } else if ([@"createVideoRenderer" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        FlutterRTCVideoRenderer* render = [self createWithTextureRegistry:_textures
                                          messenger:_messenger];
        self.renders[@(render.textureId)] = render;
        result(@{@"textureId": @(render.textureId)});
    } else if ([@"videoRendererDispose" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSNumber *textureId = argsMap[@"textureId"];
        FlutterRTCVideoRenderer *render = self.renders[textureId];
        render.videoTrack = nil;
        [render dispose];
        [self.renders removeObjectForKey:textureId];
        result(nil);
    } else if ([@"videoRendererSetSrcObject" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSNumber *textureId = argsMap[@"textureId"];
        FlutterRTCVideoRenderer *render = self.renders[textureId];
        NSString *streamId = argsMap[@"streamId"];
        NSString *peerConnectionId = argsMap[@"ownerTag"];
        if(render){
            [self setStreamId:streamId view:render peerConnectionId:peerConnectionId];
        }
        result(nil);
    } else if ([@"mediaStreamTrackHasTorch" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
            RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
            [self mediaStreamTrackHasTorch:videoTrack result:result];
        } else {
            if (track == nil) {
                result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
            } else {
                result([FlutterError errorWithCode:[@"Track is class of " stringByAppendingString:[[track class] description]] message:nil details:nil]);
            }
        }
    } else if ([@"mediaStreamTrackSetTorch" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        BOOL torch = [argsMap[@"torch"] boolValue];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
            RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
            [self mediaStreamTrackSetTorch:videoTrack torch:torch result:result];
        } else {
            if (track == nil) {
                result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
            } else {
                result([FlutterError errorWithCode:[@"Track is class of " stringByAppendingString:[[track class] description]] message:nil details:nil]);
            }
        }
    } else if ([@"mediaStreamTrackSwitchCamera" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
            RTCVideoTrack *videoTrack = (RTCVideoTrack *)track;
            [self mediaStreamTrackSwitchCamera:videoTrack result:result];
        } else {
            if (track == nil) {
                result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
            } else {
                result([FlutterError errorWithCode:[@"Track is class of " stringByAppendingString:[[track class] description]] message:nil details:nil]);
            }
        }
    } else if ([@"setVolume" isEqualToString:call.method]){
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
    } else if ([@"setMicrophoneMute" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* trackId = argsMap[@"trackId"];
        NSNumber* mute = argsMap[@"mute"];
        RTCMediaStreamTrack *track = self.localTracks[trackId];
        if (track != nil && [track isKindOfClass:[RTCAudioTrack class]]) {
            RTCAudioTrack *audioTrack = (RTCAudioTrack *)track;
            audioTrack.isEnabled = !mute.boolValue;
        }
        result(nil);
    } else if ([@"enableSpeakerphone" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSNumber* enable = argsMap[@"enable"];
        _speakerOn = enable.boolValue;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                      withOptions:_speakerOn ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0
                            error:nil];
        [audioSession setActive:YES error:nil];
        result(nil);
    } else if ([@"getLocalDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection) {
            RTCSessionDescription* sdp = peerConnection.localDescription;
            NSString *type = [RTCSessionDescription stringForType:sdp.type];
            result(@{@"sdp": sdp.sdp, @"type": type});
        } else {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                                       details:nil]);
        }
    } else if ([@"getRemoteDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection) {
            RTCSessionDescription* sdp = peerConnection.remoteDescription;
            NSString *type = [RTCSessionDescription stringForType:sdp.type];
            result(@{@"sdp": sdp.sdp, @"type": type});
        } else {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                       message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                                       details:nil]);
        }
    } else if ([@"setConfiguration" isEqualToString:call.method]){
        NSDictionary* argsMap = call.arguments;
            NSString* peerConnectionId = argsMap[@"peerConnectionId"];
            NSDictionary* configuration = argsMap[@"configuration"];
            RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
            if(peerConnection) {
                [self peerConnectionSetConfiguration:[self RTCConfiguration:configuration] peerConnection:peerConnection];
                result(nil);
            } else {
                result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed",call.method]
                                           message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                                           details:nil]);
            }
    } else {
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
    RTCMediaStream* stream = [self streamForId:streamId peerConnectionId:@""];
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

- (RTCMediaStream*)streamForId:(NSString*)streamId peerConnectionId:(NSString *)peerConnectionId
{
    RTCMediaStream *stream = _localStreams[streamId];
    if (!stream) {
        if (peerConnectionId.length > 0) {
             RTCPeerConnection *peerConnection = [_peerConnections objectForKey:peerConnectionId];
             stream = peerConnection.remoteStreams[streamId];
        } else {
            for (RTCPeerConnection *peerConnection in _peerConnections.allValues) {
              stream = peerConnection.remoteStreams[streamId];
              if (stream) {
                   break;
              }
            }
       }
    }
    return stream;
}

- (RTCMediaStreamTrack*)trackForId:(NSString*)trackId
{
    RTCMediaStreamTrack *track = _localTracks[trackId];
    if (!track) {
        for (RTCPeerConnection *peerConnection in _peerConnections.allValues) {
            track = peerConnection.remoteTracks[trackId];
            if (track) {
                break;
            }
        }
    }

    return track;    
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

  if (json[@"audioJitterBufferMaxPackets"] != nil && [json[@"audioJitterBufferMaxPackets"] isKindOfClass:[NSNumber class]]) {
    config.audioJitterBufferMaxPackets = [json[@"audioJitterBufferMaxPackets"] intValue];
  }

  if (json[@"bundlePolicy"] != nil && [json[@"bundlePolicy"] isKindOfClass:[NSString class]]) {
    NSString *bundlePolicy = json[@"bundlePolicy"];
    if ([bundlePolicy isEqualToString:@"balanced"]) {
      config.bundlePolicy = RTCBundlePolicyBalanced;
    } else if ([bundlePolicy isEqualToString:@"max-compat"]) {
      config.bundlePolicy = RTCBundlePolicyMaxCompat;
    } else if ([bundlePolicy isEqualToString:@"max-bundle"]) {
      config.bundlePolicy = RTCBundlePolicyMaxBundle;
    }
  }

  if (json[@"iceBackupCandidatePairPingInterval"] != nil && [json[@"iceBackupCandidatePairPingInterval"] isKindOfClass:[NSNumber class]]) {
    config.iceBackupCandidatePairPingInterval = [json[@"iceBackupCandidatePairPingInterval"] intValue];
  }

  if (json[@"iceConnectionReceivingTimeout"] != nil && [json[@"iceConnectionReceivingTimeout"] isKindOfClass:[NSNumber class]]) {
    config.iceConnectionReceivingTimeout = [json[@"iceConnectionReceivingTimeout"] intValue];
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

  if (json[@"iceTransportPolicy"] != nil && [json[@"iceTransportPolicy"] isKindOfClass:[NSString class]]) {
    NSString *iceTransportPolicy = json[@"iceTransportPolicy"];
    if ([iceTransportPolicy isEqualToString:@"all"]) {
      config.iceTransportPolicy = RTCIceTransportPolicyAll;
    } else if ([iceTransportPolicy isEqualToString:@"none"]) {
      config.iceTransportPolicy = RTCIceTransportPolicyNone;
    } else if ([iceTransportPolicy isEqualToString:@"nohost"]) {
      config.iceTransportPolicy = RTCIceTransportPolicyNoHost;
    } else if ([iceTransportPolicy isEqualToString:@"relay"]) {
      config.iceTransportPolicy = RTCIceTransportPolicyRelay;
    }
  }

  if (json[@"rtcpMuxPolicy"] != nil && [json[@"rtcpMuxPolicy"] isKindOfClass:[NSString class]]) {
    NSString *rtcpMuxPolicy = json[@"rtcpMuxPolicy"];
    if ([rtcpMuxPolicy isEqualToString:@"negotiate"]) {
      config.rtcpMuxPolicy = RTCRtcpMuxPolicyNegotiate;
    } else if ([rtcpMuxPolicy isEqualToString:@"require"]) {
      config.rtcpMuxPolicy = RTCRtcpMuxPolicyRequire;
    }
  }

  if (json[@"tcpCandidatePolicy"] != nil && [json[@"tcpCandidatePolicy"] isKindOfClass:[NSString class]]) {
    NSString *tcpCandidatePolicy = json[@"tcpCandidatePolicy"];
    if ([tcpCandidatePolicy isEqualToString:@"enabled"]) {
      config.tcpCandidatePolicy = RTCTcpCandidatePolicyEnabled;
    } else if ([tcpCandidatePolicy isEqualToString:@"disabled"]) {
      config.tcpCandidatePolicy = RTCTcpCandidatePolicyDisabled;
    }
  }

  if (json[@"sdpSemantics"] != nil && [json[@"sdpSemantics"] isKindOfClass:[NSString class]]) {
    NSString *sdpSemantics = json[@"sdpSemantics"];
    if ([sdpSemantics isEqualToString:@"plan-b"]) {
      config.sdpSemantics = RTCSdpSemanticsPlanB;
    } else if ([sdpSemantics isEqualToString:@"unified-plan"]) {
      config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    }
  }

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
