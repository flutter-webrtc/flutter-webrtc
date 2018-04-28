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

#import "FlutterRTCPeerConnection.h"
#import "FlutterRTCMediaStream.h"
#import "ARDVideoDecoderFactory.h"
#import "ARDVideoEncoderFactory.h"

@implementation FlutterWebRTCPlugin {
    FlutterMethodChannel *_methodChannel;
    FlutterEventChannel* _eventChannel;
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

#pragma mark - FlutterStreamHandler methods

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
    _eventSink = sink;
    return nil;
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
    /*Create Event Channel.*/
    FlutterEventChannel* eventChannel = [FlutterEventChannel
                                         eventChannelWithName:[NSString stringWithFormat:@"cloudwebrtc.com/WebRTC.Event"]
                                         binaryMessenger:messenger];
    [eventChannel setStreamHandler:self];
    _eventChannel = eventChannel;

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
        NSDictionary* constraints = argsMap[@"configuration"];
        NSDictionary* options = argsMap[@"options"];
        
        RTCConfiguration* configuration = [[RTCConfiguration alloc] init];
        RTCPeerConnection *peerConnection
        = [self.peerConnectionFactory
           peerConnectionWithConfiguration:configuration
           constraints:[self parseMediaConstraints:constraints]
           delegate:self];
        NSString *peerConnectionId = [[NSUUID UUID] UUIDString];
        peerConnection.flutterId  = peerConnectionId;
        self.peerConnections[peerConnectionId] = peerConnection;
        result(@{ @"peerConnectionId" : peerConnectionId});
    } else if ([@"getUserMedia" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary* constraints = argsMap[@"constraints"];
        [self getUserMedia:constraints result:result];
    }  else if ([@"createOffer" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSDictionary* constraints = argsMap[@"constraints"];
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        if(peerConnection)
        {
            [self peerConnectionCreateOffer:constraints peerConnection:peerConnection result:result ];
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
            result([FlutterError errorWithCode:@"removeStream"
                                       message:[NSString stringWithFormat:@"Error: pc or stream not found!"]
                                       details:nil]);
        }
        
    }  else if ([@"setLocalDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        NSString* sdp = argsMap[@"sdp"];
        RTCSdpType sdpType = [RTCSessionDescription typeForString:argsMap[@"type"]];
        RTCSessionDescription* description = [[RTCSessionDescription alloc] initWithType:sdpType sdp:sdp];
        
        if(peerConnection)
        {
           [self peerConnectionSetLocalDescription:description peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:@"SetLocalDescriptionFailed"
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"setRemoteDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        NSString* sdp = argsMap[@"sdp"];
        RTCSdpType sdpType = [RTCSessionDescription typeForString:argsMap[@"type"]];
        RTCSessionDescription* description = [[RTCSessionDescription alloc] initWithType:sdpType sdp:sdp];
        
        if(peerConnection)
        {
            [self peerConnectionSetRemoteDescription:description peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:@"SetRemoteDescriptionFailed"
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"addIceCandidate" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* peerConnectionId = argsMap[@"peerConnectionId"];
       
        NSString *sdp = argsMap[@"candidate"];
        int sdpMLineIndex = ((NSNumber*)argsMap[@"sdpMLineIndex"]).integerValue;
        NSString *sdpMid = argsMap[@"sdpMid"];
        
        RTCIceCandidate* candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
        
        RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
        
        if(peerConnection)
        {
            [self peerConnectionAddICECandidate:candidate peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:@"addIceCandidate"
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }
    else {
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

@end
