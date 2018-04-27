#import "FlutterWebRTCPlugin.h"

#import <AVFoundation/AVFoundation.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCConfiguration.h>

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
    self.dataChannels = [NSMutableDictionary new];
    self.remoteStreams = [NSMutableDictionary new];
    self.remoteTracks = [NSMutableDictionary new];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult) result {
    if ([@"createPeerConnection" isEqualToString:call.method]) {
        //TODO: 使用call.arguments 构造RTCConfiguration和constraints 参数
        NSDictionary* argsMap = call.arguments;
        NSString* configurationArgs = argsMap[@"configuration"];
        NSString* constraintsArgs = argsMap[@"options"];
        
        RTCConfiguration* configuration = [[RTCConfiguration alloc] init];
        NSDictionary* constraints = nil;
    
        RTCPeerConnection *peerConnection
        = [self.peerConnectionFactory
           peerConnectionWithConfiguration:configuration
           constraints:[self parseMediaConstraints:constraints]
           delegate:self];
        int64_t textureId = [_registry registerTexture:peerConnection];
        self.peerConnections[@(textureId)] = peerConnection;
        result(@{ @"textureId" : @(textureId)});
        
    } else if ([@"getUserMedia" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        NSString* constraintsArgs = argsMap[@"constraints"];
        NSDictionary* constraints = nil;
        //return MediaStreamId or Error
        [self getUserMedia:constraints result:result];
    }  else if ([@"createOffer" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).integerValue;
        NSDictionary * constraints = (NSDictionary*)argsMap[@"constraints"];
        RTCPeerConnection *peerConnection = self.peerConnections[@(textureId)];
        if(peerConnection)
        {
            [self peerConnectionCreateOffer:constraints peerConnection:peerConnection result:result ];
        }
    }  else if ([@"createAnswer" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).integerValue;
        NSDictionary * constraints = (NSDictionary*)argsMap[@"constraints"];
        
        RTCPeerConnection *peerConnection = self.peerConnections[@(textureId)];
        if(peerConnection)
        {
            [self peerConnectionCreateAnswer:constraints
                              peerConnection:peerConnection
                                      result:result];
        }
    }  else if ([@"addStream" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).integerValue;
        RTCPeerConnection *peerConnection = self.peerConnections[@(textureId)];
        
        int64_t streamId = ((NSNumber*)argsMap[@"streamId"]).integerValue;
        RTCMediaStream *stream = self.localStreams[@(streamId)];
        if(peerConnection)
        {
            [peerConnection addStream:stream];
            result(@"");
        }
    }  else if ([@"removeStream" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).integerValue;
        RTCPeerConnection *peerConnection = self.peerConnections[@(textureId)];
        int64_t streamId = ((NSNumber*)argsMap[@"streamId"]).integerValue;
        RTCMediaStream *stream = self.localStreams[@(streamId)];
        if(stream && peerConnection)
        {
            [peerConnection removeStream:stream];
            result(nil);
        }else{
            result([FlutterError errorWithCode:@"removeStream"
                                       message:[NSString stringWithFormat:@"Error: pc or stream not found!"]
                                       details:nil]);
        }
        
    }  else if ([@"setLocalDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).integerValue;
        RTCPeerConnection *peerConnection = self.peerConnections[@(textureId)];
        if(peerConnection)
        {
           [self peerConnectionSetLocalDescription:nil peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:@"SetLocalDescriptionFailed"
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else if ([@"setRemoteDescription" isEqualToString:call.method]) {
        NSDictionary* argsMap = call.arguments;
        int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).integerValue;
        RTCPeerConnection *peerConnection = self.peerConnections[@(textureId)];
        if(peerConnection)
        {
            [self peerConnectionSetRemoteDescription:nil peerConnection:peerConnection result:result];
        }else{
            result([FlutterError errorWithCode:@"SetRemoteDescriptionFailed"
                                       message:[NSString stringWithFormat:@"Error: pc not found!"]
                                       details:nil]);
        }
    }  else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)dealloc
{
  [_localTracks removeAllObjects];
  _localTracks = nil;
  [_localStreams removeAllObjects];
  _localStreams = nil;

  for (NSNumber *peerConnectionId in _peerConnections) {
    RTCPeerConnection *peerConnection = _peerConnections[peerConnectionId];
    peerConnection.delegate = nil;
    [peerConnection close];
  }
  [_peerConnections removeAllObjects];
  _peerConnectionFactory = nil;
}

- (RTCMediaStream*)streamForTextureId:(NSNumber*)textureId
{
  RTCMediaStream *stream = _localStreams[textureId];
  if (!stream) {
    for (NSNumber *peerConnectionId in _peerConnections) {
      RTCPeerConnection *peerConnection = _peerConnections[peerConnectionId];
      stream = peerConnection.remoteStreams[textureId];
      if (stream) {
        break;
      }
    }
  }
  return stream;
}

@end
