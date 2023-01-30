#import "FlutterWebRTCPlugin.h"
#import "AudioUtils.h"
#import "FlutterRTCDataChannel.h"
#import "FlutterRTCDesktopCapturer.h"
#import "FlutterRTCMediaStream.h"
#import "FlutterRTCPeerConnection.h"
#import "FlutterRTCVideoRenderer.h"

#import <AVFoundation/AVFoundation.h>
#import <WebRTC/WebRTC.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation FlutterWebRTCPlugin {
#pragma clang diagnostic pop
  FlutterMethodChannel* _methodChannel;
  FlutterEventSink _eventSink;
  FlutterEventChannel* _eventChannel;
  id _registry;
  id _messenger;
  id _textures;
  BOOL _speakerOn;
  AVAudioSessionPort _preferredInput;
}

@synthesize messenger = _messenger;
@synthesize eventSink = _eventSink;
@synthesize preferredInput = _preferredInput;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"FlutterWebRTC.Method"
                                  binaryMessenger:[registrar messenger]];
#if TARGET_OS_IPHONE
  UIViewController* viewController = (UIViewController*)registrar.messenger;
#endif
  FlutterWebRTCPlugin* instance =
      [[FlutterWebRTCPlugin alloc] initWithChannel:channel
                                         registrar:registrar
                                         messenger:[registrar messenger]
#if TARGET_OS_IPHONE
                                    viewController:viewController
#endif
                                      withTextures:[registrar textures]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel
                      registrar:(NSObject<FlutterPluginRegistrar>*)registrar
                      messenger:(NSObject<FlutterBinaryMessenger>*)messenger
#if TARGET_OS_IPHONE
                 viewController:(UIViewController*)viewController
#endif
                   withTextures:(NSObject<FlutterTextureRegistry>*)textures {

  self = [super init];

  FlutterEventChannel* eventChannel =
      [FlutterEventChannel eventChannelWithName:@"FlutterWebRTC.Event" binaryMessenger:messenger];
  [eventChannel setStreamHandler:self];

  if (self) {
    _methodChannel = channel;
    _registry = registrar;
    _textures = textures;
    _messenger = messenger;
    _speakerOn = NO;
    _eventChannel = eventChannel;
#if TARGET_OS_IPHONE
    _preferredInput = AVAudioSessionPortHeadphones;
    self.viewController = viewController;
#endif
  }
  // RTCSetMinDebugLogLevel(RTCLoggingSeverityVerbose);
  RTCDefaultVideoDecoderFactory* decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
  RTCDefaultVideoEncoderFactory* encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];

  RTCVideoEncoderFactorySimulcast* simulcastFactory =
      [[RTCVideoEncoderFactorySimulcast alloc] initWithPrimary:encoderFactory
                                                      fallback:encoderFactory];

  _peerConnectionFactory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:simulcastFactory
                                                                     decoderFactory:decoderFactory];

  self.peerConnections = [NSMutableDictionary new];
  self.localStreams = [NSMutableDictionary new];
  self.localTracks = [NSMutableDictionary new];
  self.renders = [NSMutableDictionary new];
  self.videoCapturerStopHandlers = [NSMutableDictionary new];
#if TARGET_OS_IPHONE
  AVAudioSession* session = [AVAudioSession sharedInstance];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didSessionRouteChange:)
                                               name:AVAudioSessionRouteChangeNotification
                                             object:session];
#endif
#if TARGET_OS_OSX
  [_peerConnectionFactory.audioDeviceModule setDevicesUpdatedHandler:^(void) {
    NSLog(@"Handle Devices Updated!");
    if (self.eventSink) {
      self.eventSink(@{@"event" : @"onDeviceChange"});
    }
  }];
#endif
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  for (RTCPeerConnection* peerConnection in _peerConnections.allValues) {
    for (RTCDataChannel* dataChannel in peerConnection.dataChannels) {
      dataChannel.eventSink = nil;
    }
    peerConnection.eventSink = nil;
  }
  _eventSink = nil;
}

#pragma mark - FlutterStreamHandler methods

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
  _eventSink = sink;
  return nil;
}

- (void)didSessionRouteChange:(NSNotification*)notification {
#if TARGET_OS_IPHONE
  NSDictionary* interuptionDict = notification.userInfo;
  NSInteger routeChangeReason =
      [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
  RTCAudioSession* session = [RTCAudioSession sharedInstance];
  switch (routeChangeReason) {
    case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
      if (session.isActive) {
        [AudioUtils selectAudioInput:_preferredInput];
      }
      break;
    }
    default:
      break;
  }

  if (self.eventSink &&
      (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable ||
       routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)) {
    self.eventSink(@{@"event" : @"onDeviceChange"});
  }
#endif
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"createPeerConnection" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSDictionary* configuration = argsMap[@"configuration"];
    NSDictionary* constraints = argsMap[@"constraints"];

    RTCPeerConnection* peerConnection = [self.peerConnectionFactory
        peerConnectionWithConfiguration:[self RTCConfiguration:configuration]
                            constraints:[self parseMediaConstraints:constraints]
                               delegate:self];

    peerConnection.remoteStreams = [NSMutableDictionary new];
    peerConnection.remoteTracks = [NSMutableDictionary new];
    peerConnection.dataChannels = [NSMutableDictionary new];

    NSString* peerConnectionId = [[NSUUID UUID] UUIDString];
    peerConnection.flutterId = peerConnectionId;

    /*Create Event Channel.*/
    peerConnection.eventChannel = [FlutterEventChannel
        eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/peerConnectionEvent%@",
                                                        peerConnectionId]
             binaryMessenger:_messenger];
    [peerConnection.eventChannel setStreamHandler:peerConnection];

    self.peerConnections[peerConnectionId] = peerConnection;
    result(@{@"peerConnectionId" : peerConnectionId});
  } else if ([@"getUserMedia" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSDictionary* constraints = argsMap[@"constraints"];
    [self getUserMedia:constraints result:result];
  } else if ([@"getDisplayMedia" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSDictionary* constraints = argsMap[@"constraints"];
    [self getDisplayMedia:constraints result:result];
  } else if ([@"createLocalMediaStream" isEqualToString:call.method]) {
    [self createLocalMediaStream:result];
  } else if ([@"getSources" isEqualToString:call.method]) {
    [self getSources:result];
  } else if ([@"selectAudioInput" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* deviceId = argsMap[@"deviceId"];
    [self selectAudioInput:deviceId result:result];
  } else if ([@"selectAudioOutput" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* deviceId = argsMap[@"deviceId"];
    [self selectAudioOutput:deviceId result:result];
  } else if ([@"mediaStreamGetTracks" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* streamId = argsMap[@"streamId"];
    [self mediaStreamGetTracks:streamId result:result];
  } else if ([@"createOffer" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSDictionary* constraints = argsMap[@"constraints"];
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      [self peerConnectionCreateOffer:constraints peerConnection:peerConnection result:result];
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"createAnswer" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSDictionary* constraints = argsMap[@"constraints"];
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      [self peerConnectionCreateAnswer:constraints peerConnection:peerConnection result:result];
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"addStream" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;

    NSString* streamId = ((NSString*)argsMap[@"streamId"]);
    RTCMediaStream* stream = self.localStreams[streamId];

    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];

    if (peerConnection && stream) {
      [peerConnection addStream:stream];
      result(@"");
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString
                            stringWithFormat:@"Error: peerConnection or mediaStream not found!"]
                details:nil]);
    }
  } else if ([@"removeStream" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;

    NSString* streamId = ((NSString*)argsMap[@"streamId"]);
    RTCMediaStream* stream = self.localStreams[streamId];

    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];

    if (peerConnection && stream) {
      [peerConnection removeStream:stream];
      result(nil);
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString
                            stringWithFormat:@"Error: peerConnection or mediaStream not found!"]
                details:nil]);
    }
  } else if ([@"captureFrame" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* path = argsMap[@"path"];
    NSString* trackId = argsMap[@"trackId"];

    RTCMediaStreamTrack* track = [self trackForId:trackId];
    if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
      RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
      [self mediaStreamTrackCaptureFrame:videoTrack toPath:path result:result];
    } else {
      if (track == nil) {
        result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
      } else {
        result([FlutterError errorWithCode:[@"Track is class of "
                                               stringByAppendingString:[[track class] description]]
                                   message:nil
                                   details:nil]);
      }
    }
  } else if ([@"setLocalDescription" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    NSDictionary* descriptionMap = argsMap[@"description"];
    NSString* sdp = descriptionMap[@"sdp"];
    RTCSdpType sdpType = [RTCSessionDescription typeForString:descriptionMap[@"type"]];
    RTCSessionDescription* description = [[RTCSessionDescription alloc] initWithType:sdpType
                                                                                 sdp:sdp];
    if (peerConnection) {
      [self peerConnectionSetLocalDescription:description
                               peerConnection:peerConnection
                                       result:result];
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"setRemoteDescription" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    NSDictionary* descriptionMap = argsMap[@"description"];
    NSString* sdp = descriptionMap[@"sdp"];
    RTCSdpType sdpType = [RTCSessionDescription typeForString:descriptionMap[@"type"]];
    RTCSessionDescription* description = [[RTCSessionDescription alloc] initWithType:sdpType
                                                                                 sdp:sdp];

    if (peerConnection) {
      [self peerConnectionSetRemoteDescription:description
                                peerConnection:peerConnection
                                        result:result];
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"sendDtmf" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* tone = argsMap[@"tone"];
    int duration = ((NSNumber*)argsMap[@"duration"]).intValue;
    int interToneGap = ((NSNumber*)argsMap[@"gap"]).intValue;

    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      RTCRtpSender* audioSender = nil;
      for (RTCRtpSender* rtpSender in peerConnection.senders) {
        if ([[[rtpSender track] kind] isEqualToString:@"audio"]) {
          audioSender = rtpSender;
        }
      }
      if (audioSender) {
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        [queue addOperationWithBlock:^{
          double durationMs = duration / 1000.0;
          double interToneGapMs = interToneGap / 1000.0;
          [audioSender.dtmfSender insertDtmf:(NSString*)tone
                                    duration:(NSTimeInterval)durationMs
                                interToneGap:(NSTimeInterval)interToneGapMs];
          NSLog(@"DTMF Tone played ");
        }];
      }

      result(@{@"result" : @"success"});
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"addCandidate" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSDictionary* candMap = argsMap[@"candidate"];
    NSString* sdp = candMap[@"candidate"];
    id sdpMLineIndexValue = candMap[@"sdpMLineIndex"];
    int sdpMLineIndex = 0;
    if (![sdpMLineIndexValue isKindOfClass:[NSNull class]]) {
      sdpMLineIndex = ((NSNumber*)candMap[@"sdpMLineIndex"]).intValue;
    }
    NSString* sdpMid = candMap[@"sdpMid"];

    RTCIceCandidate* candidate = [[RTCIceCandidate alloc] initWithSdp:sdp
                                                        sdpMLineIndex:sdpMLineIndex
                                                               sdpMid:sdpMid];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];

    if (peerConnection) {
      [self peerConnectionAddICECandidate:candidate peerConnection:peerConnection result:result];
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"getStats" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    id trackId = argsMap[@"trackId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      if (trackId != nil && trackId != [NSNull null]) {
        return [self peerConnectionGetStatsForTrackId:trackId
                                       peerConnection:peerConnection
                                               result:result];
      } else {
        return [self peerConnectionGetStats:peerConnection result:result];
      }
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"createDataChannel" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* label = argsMap[@"label"];
    NSDictionary* dataChannelDict = (NSDictionary*)argsMap[@"dataChannelDict"];
    [self createDataChannel:peerConnectionId
                      label:label
                     config:[self RTCDataChannelConfiguration:dataChannelDict]
                  messenger:_messenger
                     result:result];
  } else if ([@"dataChannelSend" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* dataChannelId = argsMap[@"dataChannelId"];
    NSString* type = argsMap[@"type"];
    id data = argsMap[@"data"];

    [self dataChannelSend:peerConnectionId dataChannelId:dataChannelId data:data type:type];
    result(nil);
  } else if ([@"dataChannelClose" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* dataChannelId = argsMap[@"dataChannelId"];
    [self dataChannelClose:peerConnectionId dataChannelId:dataChannelId];
    result(nil);
  } else if ([@"streamDispose" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* streamId = argsMap[@"streamId"];
    RTCMediaStream* stream = self.localStreams[streamId];
    BOOL shouldCallResult = YES;
    if (stream) {
      for (RTCVideoTrack* track in stream.videoTracks) {
        [_localTracks removeObjectForKey:track.trackId];
        RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
        CapturerStopHandler stopHandler = self.videoCapturerStopHandlers[videoTrack.trackId];
        if (stopHandler) {
          shouldCallResult = NO;
          stopHandler(^{
            NSLog(@"video capturer stopped, trackID = %@", videoTrack.trackId);
            result(nil);
          });
          [self.videoCapturerStopHandlers removeObjectForKey:videoTrack.trackId];
        }
      }
      for (RTCAudioTrack* track in stream.audioTracks) {
        [_localTracks removeObjectForKey:track.trackId];
      }
      [self.localStreams removeObjectForKey:streamId];
      [self deactiveRtcAudioSession];
    }
    if (shouldCallResult) {
      // do not call if will be called in stopCapturer above.
      result(nil);
    }
  } else if ([@"mediaStreamTrackSetEnable" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    NSNumber* enabled = argsMap[@"enabled"];
    RTCMediaStreamTrack* track = [self trackForId:trackId];
    if (track != nil) {
      track.isEnabled = enabled.boolValue;
    }
    result(nil);
  } else if ([@"mediaStreamAddTrack" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* streamId = argsMap[@"streamId"];
    NSString* trackId = argsMap[@"trackId"];

    RTCMediaStream* stream = self.localStreams[streamId];
    if (stream) {
      RTCMediaStreamTrack* track = [self trackForId:trackId];
      if (track != nil) {
        if ([track isKindOfClass:[RTCAudioTrack class]]) {
          RTCAudioTrack* audioTrack = (RTCAudioTrack*)track;
          [stream addAudioTrack:audioTrack];
        } else if ([track isKindOfClass:[RTCVideoTrack class]]) {
          RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
          [stream addVideoTrack:videoTrack];
        }
      } else {
        result([FlutterError errorWithCode:@"mediaStreamAddTrack: Track is nil"
                                   message:nil
                                   details:nil]);
      }
    } else {
      result([FlutterError errorWithCode:@"mediaStreamAddTrack: Stream is nil"
                                 message:nil
                                 details:nil]);
    }
    result(nil);
  } else if ([@"mediaStreamRemoveTrack" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* streamId = argsMap[@"streamId"];
    NSString* trackId = argsMap[@"trackId"];
    RTCMediaStream* stream = self.localStreams[streamId];
    if (stream) {
      RTCMediaStreamTrack* track = self.localTracks[trackId];
      if (track != nil) {
        if ([track isKindOfClass:[RTCAudioTrack class]]) {
          RTCAudioTrack* audioTrack = (RTCAudioTrack*)track;
          [stream removeAudioTrack:audioTrack];
        } else if ([track isKindOfClass:[RTCVideoTrack class]]) {
          RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
          [stream removeVideoTrack:videoTrack];
        }
      } else {
        result([FlutterError errorWithCode:@"mediaStreamRemoveTrack: Track is nil"
                                   message:nil
                                   details:nil]);
      }
    } else {
      result([FlutterError errorWithCode:@"mediaStreamRemoveTrack: Stream is nil"
                                 message:nil
                                 details:nil]);
    }
    result(nil);
  } else if ([@"trackDispose" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    BOOL audioTrack = NO;
    for (NSString* streamId in self.localStreams) {
      RTCMediaStream* stream = [self.localStreams objectForKey:streamId];
      for (RTCAudioTrack* track in stream.audioTracks) {
        if ([trackId isEqualToString:track.trackId]) {
          [stream removeAudioTrack:track];
          audioTrack = YES;
        }
      }
      for (RTCVideoTrack* track in stream.videoTracks) {
        if ([trackId isEqualToString:track.trackId]) {
          [stream removeVideoTrack:track];
          CapturerStopHandler stopHandler = self.videoCapturerStopHandlers[track.trackId];
          if (stopHandler) {
            stopHandler(^{
              NSLog(@"video capturer stopped, trackID = %@", track.trackId);
            });
            [self.videoCapturerStopHandlers removeObjectForKey:track.trackId];
          }
        }
      }
    }
    [_localTracks removeObjectForKey:trackId];
    if (audioTrack) {
      [self ensureAudioSession];
    }
    result(nil);
  } else if ([@"restartIce" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (!peerConnection) {
      result([FlutterError errorWithCode:@"restartIce: peerConnection is nil"
                                 message:nil
                                 details:nil]);
    } else {
      [peerConnection restartIce];
      result(nil);
    }
  } else if ([@"peerConnectionClose" isEqualToString:call.method] ||
             [@"peerConnectionDispose" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];

    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      [peerConnection close];
      [self.peerConnections removeObjectForKey:peerConnectionId];

      // Clean up peerConnection's streams and tracks
      [peerConnection.remoteStreams removeAllObjects];
      [peerConnection.remoteTracks removeAllObjects];

      // Clean up peerConnection's dataChannels.
      NSMutableDictionary<NSString*, RTCDataChannel*>* dataChannels = peerConnection.dataChannels;
      for (NSString* dataChannelId in dataChannels) {
        dataChannels[dataChannelId].delegate = nil;
        // There is no need to close the RTCDataChannel because it is owned by the
        // RTCPeerConnection and the latter will close the former.
      }
      [dataChannels removeAllObjects];
    }
    [self deactiveRtcAudioSession];
    result(nil);
  } else if ([@"createVideoRenderer" isEqualToString:call.method]) {
    FlutterRTCVideoRenderer* render = [self createWithTextureRegistry:_textures
                                                            messenger:_messenger];
    self.renders[@(render.textureId)] = render;
    result(@{@"textureId" : @(render.textureId)});
  } else if ([@"videoRendererDispose" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSNumber* textureId = argsMap[@"textureId"];
    FlutterRTCVideoRenderer* render = self.renders[textureId];
    render.videoTrack = nil;
    [render dispose];
    [self.renders removeObjectForKey:textureId];
    result(nil);
  } else if ([@"videoRendererSetSrcObject" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSNumber* textureId = argsMap[@"textureId"];
    FlutterRTCVideoRenderer* render = self.renders[textureId];
    NSString* streamId = argsMap[@"streamId"];
    NSString* ownerTag = argsMap[@"ownerTag"];
    NSString* trackId = argsMap[@"trackId"];
    if (!render) {
      result([FlutterError errorWithCode:@"videoRendererSetSrcObject: render is nil"
                                 message:nil
                                 details:nil]);
      return;
    }
    RTCMediaStream* stream = nil;
    RTCVideoTrack* videoTrack = nil;
    if ([ownerTag isEqualToString:@"local"]) {
      stream = _localStreams[streamId];
    }
    if (!stream) {
      stream = [self streamForId:streamId peerConnectionId:ownerTag];
    }
    if (stream) {
      NSArray* videoTracks = stream ? stream.videoTracks : nil;
      videoTrack = videoTracks && videoTracks.count ? videoTracks[0] : nil;
      for (RTCVideoTrack* track in videoTracks) {
        if ([track.trackId isEqualToString:trackId]) {
          videoTrack = track;
        }
      }
      if (!videoTrack) {
        NSLog(@"Not found video track for RTCMediaStream: %@", streamId);
      }
    }
    [self rendererSetSrcObject:render stream:videoTrack];
    result(nil);
  } else if ([@"mediaStreamTrackHasTorch" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    RTCMediaStreamTrack* track = self.localTracks[trackId];
    if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
      RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
      [self mediaStreamTrackHasTorch:videoTrack result:result];
    } else {
      if (track == nil) {
        result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
      } else {
        result([FlutterError errorWithCode:[@"Track is class of "
                                               stringByAppendingString:[[track class] description]]
                                   message:nil
                                   details:nil]);
      }
    }
  } else if ([@"mediaStreamTrackSetTorch" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    BOOL torch = [argsMap[@"torch"] boolValue];
    RTCMediaStreamTrack* track = self.localTracks[trackId];
    if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
      RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
      [self mediaStreamTrackSetTorch:videoTrack torch:torch result:result];
    } else {
      if (track == nil) {
        result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
      } else {
        result([FlutterError errorWithCode:[@"Track is class of "
                                               stringByAppendingString:[[track class] description]]
                                   message:nil
                                   details:nil]);
      }
    }
  } else if ([@"mediaStreamTrackSwitchCamera" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    RTCMediaStreamTrack* track = self.localTracks[trackId];
    if (track != nil && [track isKindOfClass:[RTCVideoTrack class]]) {
      RTCVideoTrack* videoTrack = (RTCVideoTrack*)track;
      [self mediaStreamTrackSwitchCamera:videoTrack result:result];
    } else {
      if (track == nil) {
        result([FlutterError errorWithCode:@"Track is nil" message:nil details:nil]);
      } else {
        result([FlutterError errorWithCode:[@"Track is class of "
                                               stringByAppendingString:[[track class] description]]
                                   message:nil
                                   details:nil]);
      }
    }
  } else if ([@"setVolume" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    NSNumber* volume = argsMap[@"volume"];
    RTCMediaStreamTrack* track = self.localTracks[trackId];
    if (track != nil && [track isKindOfClass:[RTCAudioTrack class]]) {
      RTCAudioTrack* audioTrack = (RTCAudioTrack*)track;
      RTCAudioSource* audioSource = audioTrack.source;
      audioSource.volume = [volume doubleValue];
    }
    result(nil);
  } else if ([@"setMicrophoneMute" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* trackId = argsMap[@"trackId"];
    NSNumber* mute = argsMap[@"mute"];
    RTCMediaStreamTrack* track = self.localTracks[trackId];
    if (track != nil && [track isKindOfClass:[RTCAudioTrack class]]) {
      RTCAudioTrack* audioTrack = (RTCAudioTrack*)track;
      audioTrack.isEnabled = !mute.boolValue;
    }
    result(nil);
  }
#if TARGET_OS_IPHONE
  else if ([@"enableSpeakerphone" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSNumber* enable = argsMap[@"enable"];
    _speakerOn = enable.boolValue;
    [AudioUtils setSpeakerphoneOn:_speakerOn];
    result(nil);
  }
#endif
  else if ([@"getLocalDescription" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      RTCSessionDescription* sdp = peerConnection.localDescription;
      if (nil == sdp) {
        result(nil);
      } else {
        NSString* type = [RTCSessionDescription stringForType:sdp.type];
        result(@{@"sdp" : sdp.sdp, @"type" : type});
      }
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"getRemoteDescription" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      RTCSessionDescription* sdp = peerConnection.remoteDescription;
      if (nil == sdp) {
        result(nil);
      } else {
        NSString* type = [RTCSessionDescription stringForType:sdp.type];
        result(@{@"sdp" : sdp.sdp, @"type" : type});
      }
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"setConfiguration" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSDictionary* configuration = argsMap[@"configuration"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection) {
      [self peerConnectionSetConfiguration:[self RTCConfiguration:configuration]
                            peerConnection:peerConnection];
      result(nil);
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
    }
  } else if ([@"addTrack" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* trackId = argsMap[@"trackId"];
    NSArray* streamIds = argsMap[@"streamIds"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }

    RTCMediaStreamTrack* track = [self trackForId:trackId];
    if (track == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: track not found!"]
                                 details:nil]);
      return;
    }
    RTCRtpSender* sender = [peerConnection addTrack:track streamIds:streamIds];
    if (sender == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection.addTrack failed!"]
                details:nil]);
      return;
    }

    result([self rtpSenderToMap:sender]);
  } else if ([@"removeTrack" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* senderId = argsMap[@"senderId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpSender* sender = [self getRtpSenderById:peerConnection Id:senderId];
    if (sender == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: sender not found!"]
                                 details:nil]);
      return;
    }
    result(@{@"result" : @([peerConnection removeTrack:sender])});
  } else if ([@"addTransceiver" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSDictionary* transceiverInit = argsMap[@"transceiverInit"];
    NSString* trackId = argsMap[@"trackId"];
    NSString* mediaType = argsMap[@"mediaType"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpTransceiver* transceiver = nil;
    BOOL hasAudio = NO;
    if (trackId != nil) {
      RTCMediaStreamTrack* track = [self trackForId:trackId];
      if (transceiverInit != nil) {
        RTCRtpTransceiverInit* init = [self mapToTransceiverInit:transceiverInit];
        transceiver = [peerConnection addTransceiverWithTrack:track init:init];
      } else {
        transceiver = [peerConnection addTransceiverWithTrack:track];
      }
      if ([track.kind isEqualToString:@"audio"]) {
        hasAudio = YES;
      }
    } else if (mediaType != nil) {
      RTCRtpMediaType rtpMediaType = [self stringToRtpMediaType:mediaType];
      if (transceiverInit != nil) {
        RTCRtpTransceiverInit* init = [self mapToTransceiverInit:transceiverInit];
        transceiver = [peerConnection addTransceiverOfType:(rtpMediaType) init:init];
      } else {
        transceiver = [peerConnection addTransceiverOfType:rtpMediaType];
      }
      if (rtpMediaType == RTCRtpMediaTypeAudio) {
        hasAudio = YES;
      }
    } else {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: Incomplete parameters!"]
                details:nil]);
      return;
    }

    if (transceiver == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: can't addTransceiver!"]
                                 details:nil]);
      return;
    }

    result([self transceiverToMap:transceiver]);
  } else if ([@"rtpTransceiverSetDirection" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* direction = argsMap[@"direction"];
    NSString* transceiverId = argsMap[@"transceiverId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpTransceiver* transcevier = [self getRtpTransceiverById:peerConnection Id:transceiverId];
    if (transcevier == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: transcevier not found!"]
                details:nil]);
      return;
    }
    [transcevier setDirection:[self stringToTransceiverDirection:direction] error:nil];
    result(nil);
  } else if ([@"rtpTransceiverGetCurrentDirection" isEqualToString:call.method] ||
             [@"rtpTransceiverGetDirection" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* transceiverId = argsMap[@"transceiverId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpTransceiver* transcevier = [self getRtpTransceiverById:peerConnection Id:transceiverId];
    if (transcevier == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: transcevier not found!"]
                details:nil]);
      return;
    }

    if ([@"rtpTransceiverGetDirection" isEqualToString:call.method]) {
      result(@{@"result" : [self transceiverDirectionString:transcevier.direction]});
    } else if ([@"rtpTransceiverGetCurrentDirection" isEqualToString:call.method]) {
      RTCRtpTransceiverDirection directionOut = transcevier.direction;
      if ([transcevier currentDirection:&directionOut]) {
        result(@{@"result" : [self transceiverDirectionString:directionOut]});
      } else {
        result(nil);
      }
    }
  } else if ([@"rtpTransceiverStop" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* transceiverId = argsMap[@"transceiverId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpTransceiver* transcevier = [self getRtpTransceiverById:peerConnection Id:transceiverId];
    if (transcevier == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: transcevier not found!"]
                details:nil]);
      return;
    }
    [transcevier stopInternal];
    result(nil);
  } else if ([@"rtpSenderSetParameters" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* senderId = argsMap[@"rtpSenderId"];
    NSDictionary* parameters = argsMap[@"parameters"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpSender* sender = [self getRtpSenderById:peerConnection Id:senderId];
    if (sender == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: sender not found!"]
                                 details:nil]);
      return;
    }
    [sender setParameters:[self updateRtpParameters:sender.parameters with:parameters]];

    result(@{@"result" : @(YES)});
  } else if ([@"rtpSenderReplaceTrack" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* senderId = argsMap[@"rtpSenderId"];
    NSString* trackId = argsMap[@"trackId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpSender* sender = [self getRtpSenderById:peerConnection Id:senderId];
    if (sender == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: sender not found!"]
                                 details:nil]);
      return;
    }
    RTCMediaStreamTrack* track = nil;
    if ([trackId length] > 0) {
      track = [self trackForId:trackId];
      if (track == nil) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                   message:[NSString stringWithFormat:@"Error: track not found!"]
                                   details:nil]);
        return;
      }
    }
    [sender setTrack:track];
    result(nil);
  } else if ([@"rtpSenderSetTrack" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* senderId = argsMap[@"rtpSenderId"];
    NSString* trackId = argsMap[@"trackId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpSender* sender = [self getRtpSenderById:peerConnection Id:senderId];
    if (sender == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: sender not found!"]
                                 details:nil]);
      return;
    }
    RTCMediaStreamTrack* track = nil;
    if ([trackId length] > 0) {
      track = [self trackForId:trackId];
      if (track == nil) {
        result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                   message:[NSString stringWithFormat:@"Error: track not found!"]
                                   details:nil]);
        return;
      }
    }
    [sender setTrack:track];
    result(nil);
  } else if ([@"rtpSenderDispose" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    NSString* senderId = argsMap[@"rtpSenderId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    RTCRtpSender* sender = [self getRtpSenderById:peerConnection Id:senderId];
    if (sender == nil) {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                                 message:[NSString stringWithFormat:@"Error: sender not found!"]
                                 details:nil]);
      return;
    }
    [peerConnection removeTrack:sender];
    result(nil);
  } else if ([@"getSenders" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }

    NSMutableArray* senders = [NSMutableArray array];
    for (RTCRtpSender* sender in peerConnection.senders) {
      [senders addObject:[self rtpSenderToMap:sender]];
    }

    result(@{@"senders" : senders});
  } else if ([@"getReceivers" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }

    NSMutableArray* receivers = [NSMutableArray array];
    for (RTCRtpReceiver* receiver in peerConnection.receivers) {
      [receivers addObject:[self receiverToMap:receiver]];
    }

    result(@{@"receivers" : receivers});
  } else if ([@"getTransceivers" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:[NSString stringWithFormat:@"%@Failed", call.method]
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }

    NSMutableArray* transceivers = [NSMutableArray array];
    for (RTCRtpTransceiver* transceiver in peerConnection.transceivers) {
      [transceivers addObject:[self transceiverToMap:transceiver]];
    }

    result(@{@"transceivers" : transceivers});
  } else if ([@"getDesktopSources" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    [self getDesktopSources:argsMap result:result];
  } else if ([@"updateDesktopSources" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    [self updateDesktopSources:argsMap result:result];
  } else if ([@"getDesktopSourceThumbnail" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    [self getDesktopSourceThumbnail:argsMap result:result];
  } else if ([@"setCodecPreferences" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    [self transceiverSetCodecPreferences:argsMap result:result];
  }  else if ([@"getRtpReceiverCapabilities" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    [self peerConnectionGetRtpReceiverCapabilities:argsMap result:result];
  } else if ([@"getRtpSenderCapabilities" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    [self peerConnectionGetRtpSenderCapabilities:argsMap result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)dealloc {
  [_localTracks removeAllObjects];
  _localTracks = nil;
  [_localStreams removeAllObjects];
  _localStreams = nil;

  for (NSString* peerConnectionId in _peerConnections) {
    RTCPeerConnection* peerConnection = _peerConnections[peerConnectionId];
    peerConnection.delegate = nil;
    [peerConnection close];
  }
  [_peerConnections removeAllObjects];
  _peerConnectionFactory = nil;
}

- (BOOL)hasLocalAudioTrack {
  for (id key in _localTracks.allKeys) {
    RTCMediaStreamTrack* track = [_localTracks objectForKey:key];
    if ([track.kind isEqualToString:@"audio"]) {
      return YES;
    }
  }
  return NO;
}

- (void)ensureAudioSession {
#if TARGET_OS_IPHONE
  [AudioUtils ensureAudioSessionWithRecording:[self hasLocalAudioTrack]];
  [AudioUtils setSpeakerphoneOn:_speakerOn];
#endif
}

- (void)deactiveRtcAudioSession {
#if TARGET_OS_IPHONE
  if (![self hasLocalAudioTrack] && self.peerConnections.count == 0) {
    [AudioUtils deactiveRtcAudioSession];
  }
#endif
}

- (void)mediaStreamGetTracks:(NSString*)streamId result:(FlutterResult)result {
  RTCMediaStream* stream = [self streamForId:streamId peerConnectionId:@""];
  if (stream) {
    NSMutableArray* audioTracks = [NSMutableArray array];
    NSMutableArray* videoTracks = [NSMutableArray array];

    for (RTCMediaStreamTrack* track in stream.audioTracks) {
      NSString* trackId = track.trackId;
      [self.localTracks setObject:track forKey:trackId];
      [audioTracks addObject:@{
        @"enabled" : @(track.isEnabled),
        @"id" : trackId,
        @"kind" : track.kind,
        @"label" : trackId,
        @"readyState" : @"live",
        @"remote" : @(NO)
      }];
    }

    for (RTCMediaStreamTrack* track in stream.videoTracks) {
      NSString* trackId = track.trackId;
      [_localTracks setObject:track forKey:trackId];
      [videoTracks addObject:@{
        @"enabled" : @(track.isEnabled),
        @"id" : trackId,
        @"kind" : track.kind,
        @"label" : trackId,
        @"readyState" : @"live",
        @"remote" : @(NO)
      }];
    }

    result(@{@"audioTracks" : audioTracks, @"videoTracks" : videoTracks});
  } else {
    result(nil);
  }
}

- (RTCMediaStream*)streamForId:(NSString*)streamId peerConnectionId:(NSString*)peerConnectionId {
  RTCMediaStream* stream = nil;
  if (peerConnectionId.length > 0) {
    RTCPeerConnection* peerConnection = [_peerConnections objectForKey:peerConnectionId];
    stream = peerConnection.remoteStreams[streamId];
  } else {
    for (RTCPeerConnection* peerConnection in _peerConnections.allValues) {
      stream = peerConnection.remoteStreams[streamId];
      if (stream) {
        break;
      }
    }
  }
  if (!stream) {
    stream = _localStreams[streamId];
  }
  return stream;
}

- (RTCMediaStreamTrack*)trackForId:(NSString*)trackId {
  RTCMediaStreamTrack* track = _localTracks[trackId];
  if (!track) {
    for (RTCPeerConnection* peerConnection in _peerConnections.allValues) {
      track = peerConnection.remoteTracks[trackId];
      if (!track) {
        for (RTCRtpTransceiver* transceiver in peerConnection.transceivers) {
          if (transceiver.receiver.track != nil &&
              [transceiver.receiver.track.trackId isEqual:trackId]) {
            track = transceiver.receiver.track;
            break;
          }
        }
      }
      if (track) {
        break;
      }
    }
  }
  return track;
}

- (RTCIceServer*)RTCIceServer:(id)json {
  if (!json) {
    NSLog(@"a valid iceServer value");
    return nil;
  }

  if (![json isKindOfClass:[NSDictionary class]]) {
    NSLog(@"must be an object");
    return nil;
  }

  NSArray<NSString*>* urls;
  if ([json[@"url"] isKindOfClass:[NSString class]]) {
    // TODO: 'url' is non-standard
    urls = @[ json[@"url"] ];
  } else if ([json[@"urls"] isKindOfClass:[NSString class]]) {
    urls = @[ json[@"urls"] ];
  } else {
    urls = (NSArray*)json[@"urls"];
  }

  if (json[@"username"] != nil || json[@"credential"] != nil) {
    return [[RTCIceServer alloc] initWithURLStrings:urls
                                           username:json[@"username"]
                                         credential:json[@"credential"]];
  }

  return [[RTCIceServer alloc] initWithURLStrings:urls];
}

- (nonnull RTCConfiguration*)RTCConfiguration:(id)json {
  RTCConfiguration* config = [[RTCConfiguration alloc] init];

  if (!json) {
    return config;
  }

  if (![json isKindOfClass:[NSDictionary class]]) {
    NSLog(@"must be an object");
    return config;
  }

  if (json[@"audioJitterBufferMaxPackets"] != nil &&
      [json[@"audioJitterBufferMaxPackets"] isKindOfClass:[NSNumber class]]) {
    config.audioJitterBufferMaxPackets = [json[@"audioJitterBufferMaxPackets"] intValue];
  }

  if (json[@"bundlePolicy"] != nil && [json[@"bundlePolicy"] isKindOfClass:[NSString class]]) {
    NSString* bundlePolicy = json[@"bundlePolicy"];
    if ([bundlePolicy isEqualToString:@"balanced"]) {
      config.bundlePolicy = RTCBundlePolicyBalanced;
    } else if ([bundlePolicy isEqualToString:@"max-compat"]) {
      config.bundlePolicy = RTCBundlePolicyMaxCompat;
    } else if ([bundlePolicy isEqualToString:@"max-bundle"]) {
      config.bundlePolicy = RTCBundlePolicyMaxBundle;
    }
  }

  if (json[@"iceBackupCandidatePairPingInterval"] != nil &&
      [json[@"iceBackupCandidatePairPingInterval"] isKindOfClass:[NSNumber class]]) {
    config.iceBackupCandidatePairPingInterval =
        [json[@"iceBackupCandidatePairPingInterval"] intValue];
  }

  if (json[@"iceConnectionReceivingTimeout"] != nil &&
      [json[@"iceConnectionReceivingTimeout"] isKindOfClass:[NSNumber class]]) {
    config.iceConnectionReceivingTimeout = [json[@"iceConnectionReceivingTimeout"] intValue];
  }

  if (json[@"iceServers"] != nil && [json[@"iceServers"] isKindOfClass:[NSArray class]]) {
    NSMutableArray<RTCIceServer*>* iceServers = [NSMutableArray new];
    for (id server in json[@"iceServers"]) {
      RTCIceServer* convert = [self RTCIceServer:server];
      if (convert != nil) {
        [iceServers addObject:convert];
      }
    }
    config.iceServers = iceServers;
  }

  if (json[@"iceTransportPolicy"] != nil &&
      [json[@"iceTransportPolicy"] isKindOfClass:[NSString class]]) {
    NSString* iceTransportPolicy = json[@"iceTransportPolicy"];
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
    NSString* rtcpMuxPolicy = json[@"rtcpMuxPolicy"];
    if ([rtcpMuxPolicy isEqualToString:@"negotiate"]) {
      config.rtcpMuxPolicy = RTCRtcpMuxPolicyNegotiate;
    } else if ([rtcpMuxPolicy isEqualToString:@"require"]) {
      config.rtcpMuxPolicy = RTCRtcpMuxPolicyRequire;
    }
  }

  if (json[@"sdpSemantics"] != nil && [json[@"sdpSemantics"] isKindOfClass:[NSString class]]) {
    NSString* sdpSemantics = json[@"sdpSemantics"];
    if ([sdpSemantics isEqualToString:@"plan-b"]) {
      config.sdpSemantics = RTCSdpSemanticsPlanB;
    } else if ([sdpSemantics isEqualToString:@"unified-plan"]) {
      config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    }
  }

  // === below is private api in webrtc ===
  if (json[@"tcpCandidatePolicy"] != nil &&
      [json[@"tcpCandidatePolicy"] isKindOfClass:[NSString class]]) {
    NSString* tcpCandidatePolicy = json[@"tcpCandidatePolicy"];
    if ([tcpCandidatePolicy isEqualToString:@"enabled"]) {
      config.tcpCandidatePolicy = RTCTcpCandidatePolicyEnabled;
    } else if ([tcpCandidatePolicy isEqualToString:@"disabled"]) {
      config.tcpCandidatePolicy = RTCTcpCandidatePolicyDisabled;
    }
  }

  // candidateNetworkPolicy (private api)
  if (json[@"candidateNetworkPolicy"] != nil &&
      [json[@"candidateNetworkPolicy"] isKindOfClass:[NSString class]]) {
    NSString* candidateNetworkPolicy = json[@"candidateNetworkPolicy"];
    if ([candidateNetworkPolicy isEqualToString:@"all"]) {
      config.candidateNetworkPolicy = RTCCandidateNetworkPolicyAll;
    } else if ([candidateNetworkPolicy isEqualToString:@"low_cost"]) {
      config.candidateNetworkPolicy = RTCCandidateNetworkPolicyLowCost;
    }
  }

  // KeyType (private api)
  if (json[@"keyType"] != nil && [json[@"keyType"] isKindOfClass:[NSString class]]) {
    NSString* keyType = json[@"keyType"];
    if ([keyType isEqualToString:@"RSA"]) {
      config.keyType = RTCEncryptionKeyTypeRSA;
    } else if ([keyType isEqualToString:@"ECDSA"]) {
      config.keyType = RTCEncryptionKeyTypeECDSA;
    }
  }

  // continualGatheringPolicy (private api)
  if (json[@"continualGatheringPolicy"] != nil &&
      [json[@"continualGatheringPolicy"] isKindOfClass:[NSString class]]) {
    NSString* continualGatheringPolicy = json[@"continualGatheringPolicy"];
    if ([continualGatheringPolicy isEqualToString:@"gather_once"]) {
      config.continualGatheringPolicy = RTCContinualGatheringPolicyGatherOnce;
    } else if ([continualGatheringPolicy isEqualToString:@"gather_continually"]) {
      config.continualGatheringPolicy = RTCContinualGatheringPolicyGatherContinually;
    }
  }

  // audioJitterBufferMaxPackets (private api)
  if (json[@"audioJitterBufferMaxPackets"] != nil &&
      [json[@"audioJitterBufferMaxPackets"] isKindOfClass:[NSNumber class]]) {
    NSNumber* audioJitterBufferMaxPackets = json[@"audioJitterBufferMaxPackets"];
    config.audioJitterBufferMaxPackets = [audioJitterBufferMaxPackets intValue];
  }

  // iceConnectionReceivingTimeout (private api)
  if (json[@"iceConnectionReceivingTimeout"] != nil &&
      [json[@"iceConnectionReceivingTimeout"] isKindOfClass:[NSNumber class]]) {
    NSNumber* iceConnectionReceivingTimeout = json[@"iceConnectionReceivingTimeout"];
    config.iceConnectionReceivingTimeout = [iceConnectionReceivingTimeout intValue];
  }

  // iceBackupCandidatePairPingInterval (private api)
  if (json[@"iceBackupCandidatePairPingInterval"] != nil &&
      [json[@"iceBackupCandidatePairPingInterval"] isKindOfClass:[NSNumber class]]) {
    NSNumber* iceBackupCandidatePairPingInterval = json[@"iceConnectionReceivingTimeout"];
    config.iceBackupCandidatePairPingInterval = [iceBackupCandidatePairPingInterval intValue];
  }

  // audioJitterBufferFastAccelerate (private api)
  if (json[@"audioJitterBufferFastAccelerate"] != nil &&
      [json[@"audioJitterBufferFastAccelerate"] isKindOfClass:[NSNumber class]]) {
    NSNumber* audioJitterBufferFastAccelerate = json[@"audioJitterBufferFastAccelerate"];
    config.audioJitterBufferFastAccelerate = [audioJitterBufferFastAccelerate boolValue];
  }

  // pruneTurnPorts (private api)
  if (json[@"pruneTurnPorts"] != nil && [json[@"pruneTurnPorts"] isKindOfClass:[NSNumber class]]) {
    NSNumber* pruneTurnPorts = json[@"pruneTurnPorts"];
    config.shouldPruneTurnPorts = [pruneTurnPorts boolValue];
  }

  // presumeWritableWhenFullyRelayed (private api)
  if (json[@"presumeWritableWhenFullyRelayed"] != nil &&
      [json[@"presumeWritableWhenFullyRelayed"] isKindOfClass:[NSNumber class]]) {
    NSNumber* presumeWritableWhenFullyRelayed = json[@"presumeWritableWhenFullyRelayed"];
    config.shouldPresumeWritableWhenFullyRelayed = [presumeWritableWhenFullyRelayed boolValue];
  }

  // cryptoOptions (private api)
  if (json[@"cryptoOptions"] != nil &&
      [json[@"cryptoOptions"] isKindOfClass:[NSDictionary class]]) {
    id options = json[@"cryptoOptions"];
    BOOL srtpEnableGcmCryptoSuites = NO;
    BOOL sframeRequireFrameEncryption = NO;
    BOOL srtpEnableEncryptedRtpHeaderExtensions = NO;
    BOOL srtpEnableAes128Sha1_32CryptoCipher = NO;

    if (options[@"enableGcmCryptoSuites"] != nil &&
                [options[@"enableGcmCryptoSuites"] isKindOfClass:[NSNumber class]]) {
      NSNumber* value = options[@"enableGcmCryptoSuites"];
      srtpEnableGcmCryptoSuites = [value boolValue];
    }

    if (options[@"requireFrameEncryption"] != nil &&
        [options[@"requireFrameEncryption"] isKindOfClass:[NSNumber class]]) {
      NSNumber* value = options[@"requireFrameEncryption"];
      sframeRequireFrameEncryption = [value boolValue];
    }

    if (options[@"enableEncryptedRtpHeaderExtensions"] != nil &&
        [options[@"enableEncryptedRtpHeaderExtensions"] isKindOfClass:[NSNumber class]]) {
      NSNumber* value = options[@"enableEncryptedRtpHeaderExtensions"];
      srtpEnableEncryptedRtpHeaderExtensions = [value boolValue];
    }

    if (options[@"enableAes128Sha1_32CryptoCipher"] != nil &&
        [options[@"enableAes128Sha1_32CryptoCipher"] isKindOfClass:[NSNumber class]]) {
      NSNumber* value = options[@"enableAes128Sha1_32CryptoCipher"];
      srtpEnableAes128Sha1_32CryptoCipher = [value boolValue];
    }

    config.cryptoOptions = [[RTCCryptoOptions alloc]
             initWithSrtpEnableGcmCryptoSuites:srtpEnableGcmCryptoSuites
           srtpEnableAes128Sha1_32CryptoCipher:srtpEnableAes128Sha1_32CryptoCipher
        srtpEnableEncryptedRtpHeaderExtensions:srtpEnableEncryptedRtpHeaderExtensions
                  sframeRequireFrameEncryption:(BOOL)sframeRequireFrameEncryption];
  }

  return config;
}

- (RTCDataChannelConfiguration*)RTCDataChannelConfiguration:(id)json {
  if (!json) {
    return nil;
  }
  if ([json isKindOfClass:[NSDictionary class]]) {
    RTCDataChannelConfiguration* init = [RTCDataChannelConfiguration new];

    if (json[@"id"]) {
      [init setChannelId:(int)[json[@"id"] integerValue]];
    }
    if (json[@"ordered"]) {
      init.isOrdered = [json[@"ordered"] boolValue];
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

- (CGRect)parseRect:(NSDictionary*)rect {
  return CGRectMake(
      [[rect valueForKey:@"left"] doubleValue], [[rect valueForKey:@"top"] doubleValue],
      [[rect valueForKey:@"width"] doubleValue], [[rect valueForKey:@"height"] doubleValue]);
}

- (NSDictionary*)dtmfSenderToMap:(id<RTCDtmfSender>)dtmf Id:(NSString*)Id {
  return @{
    @"dtmfSenderId" : Id,
    @"interToneGap" : @(dtmf.interToneGap / 1000.0),
    @"duration" : @(dtmf.duration / 1000.0),
  };
}

- (NSDictionary*)rtpParametersToMap:(RTCRtpParameters*)parameters {
  NSDictionary* rtcp = @{
    @"cname" : parameters.rtcp.cname,
    @"reducedSize" : @(parameters.rtcp.isReducedSize),
  };

  NSMutableArray* headerExtensions = [NSMutableArray array];
  for (RTCRtpHeaderExtension* headerExtension in parameters.headerExtensions) {
    [headerExtensions addObject:@{
      @"uri" : headerExtension.uri,
      @"encrypted" : @(headerExtension.encrypted),
      @"id" : @(headerExtension.id),
    }];
  }

  NSMutableArray* encodings = [NSMutableArray array];
  for (RTCRtpEncodingParameters* encoding in parameters.encodings) {
    // non-nil values
    NSMutableDictionary* obj = [@{@"active" : @(encoding.isActive)} mutableCopy];
    // optional values
    if (encoding.rid != nil)
      [obj setObject:encoding.rid forKey:@"rid"];
    if (encoding.minBitrateBps != nil)
      [obj setObject:encoding.minBitrateBps forKey:@"minBitrate"];
    if (encoding.maxBitrateBps != nil)
      [obj setObject:encoding.maxBitrateBps forKey:@"maxBitrate"];
    if (encoding.maxFramerate != nil)
      [obj setObject:encoding.maxFramerate forKey:@"maxFramerate"];
    if (encoding.numTemporalLayers != nil)
      [obj setObject:encoding.numTemporalLayers forKey:@"numTemporalLayers"];
    if (encoding.scaleResolutionDownBy != nil)
      [obj setObject:encoding.scaleResolutionDownBy forKey:@"scaleResolutionDownBy"];
    if (encoding.ssrc != nil)
      [obj setObject:encoding.ssrc forKey:@"ssrc"];

    [encodings addObject:obj];
  }

  NSMutableArray* codecs = [NSMutableArray array];
  for (RTCRtpCodecParameters* codec in parameters.codecs) {
    [codecs addObject:@{
      @"name" : codec.name,
      @"payloadType" : @(codec.payloadType),
      @"clockRate" : codec.clockRate,
      @"numChannels" : codec.numChannels ? codec.numChannels : @(1),
      @"parameters" : codec.parameters,
      @"kind" : codec.kind
    }];
  }

  return @{
    @"transactionId" : parameters.transactionId,
    @"rtcp" : rtcp,
    @"headerExtensions" : headerExtensions,
    @"encodings" : encodings,
    @"codecs" : codecs
  };
}

- (NSString*)streamTrackStateToString:(RTCMediaStreamTrackState)state {
  switch (state) {
    case RTCMediaStreamTrackStateLive:
      return @"live";
    case RTCMediaStreamTrackStateEnded:
      return @"ended";
    default:
      break;
  }
  return @"";
}

- (NSDictionary*)mediaStreamToMap:(RTCMediaStream*)stream ownerTag:(NSString*)ownerTag {
  NSMutableArray* audioTracks = [NSMutableArray array];
  NSMutableArray* videoTracks = [NSMutableArray array];

  for (RTCMediaStreamTrack* track in stream.audioTracks) {
    [audioTracks addObject:[self mediaTrackToMap:track]];
  }

  for (RTCMediaStreamTrack* track in stream.videoTracks) {
    [videoTracks addObject:[self mediaTrackToMap:track]];
  }

  return @{
    @"streamId" : stream.streamId,
    @"ownerTag" : ownerTag,
    @"audioTracks" : audioTracks,
    @"videoTracks" : videoTracks,

  };
}

- (NSDictionary*)mediaTrackToMap:(RTCMediaStreamTrack*)track {
  if (track == nil)
    return @{};
  NSDictionary* params = @{
    @"enabled" : @(track.isEnabled),
    @"id" : track.trackId,
    @"kind" : track.kind,
    @"label" : track.trackId,
    @"readyState" : [self streamTrackStateToString:track.readyState],
    @"remote" : @(YES)
  };
  return params;
}

- (NSDictionary*)rtpSenderToMap:(RTCRtpSender*)sender {
  NSDictionary* params = @{
    @"senderId" : sender.senderId,
    @"ownsTrack" : @(YES),
    @"rtpParameters" : [self rtpParametersToMap:sender.parameters],
    @"track" : [self mediaTrackToMap:sender.track],
    @"dtmfSender" : [self dtmfSenderToMap:sender.dtmfSender Id:sender.senderId]
  };
  return params;
}

- (NSDictionary*)receiverToMap:(RTCRtpReceiver*)receiver {
  NSDictionary* params = @{
    @"receiverId" : receiver.receiverId,
    @"rtpParameters" : [self rtpParametersToMap:receiver.parameters],
    @"track" : [self mediaTrackToMap:receiver.track],
  };
  return params;
}

- (RTCRtpTransceiver*)getRtpTransceiverById:(RTCPeerConnection*)peerConnection Id:(NSString*)Id {
  for (RTCRtpTransceiver* transceiver in peerConnection.transceivers) {
    if ([transceiver.mid isEqualToString:Id]) {
      return transceiver;
    }
  }
  return nil;
}

- (RTCRtpSender*)getRtpSenderById:(RTCPeerConnection*)peerConnection Id:(NSString*)Id {
  for (RTCRtpSender* sender in peerConnection.senders) {
    if ([sender.senderId isEqualToString:Id]) {
      return sender;
    }
  }
  return nil;
}

- (RTCRtpReceiver*)getRtpReceiverById:(RTCPeerConnection*)peerConnection Id:(NSString*)Id {
  for (RTCRtpReceiver* receiver in peerConnection.receivers) {
    if ([receiver.receiverId isEqualToString:Id]) {
      return receiver;
    }
  }
  return nil;
}

- (RTCRtpEncodingParameters*)mapToEncoding:(NSDictionary*)map {
  RTCRtpEncodingParameters* encoding = [[RTCRtpEncodingParameters alloc] init];
  encoding.isActive = YES;
  encoding.scaleResolutionDownBy = [NSNumber numberWithDouble:1.0];
  encoding.numTemporalLayers = [NSNumber numberWithInt:1];
#if TARGET_OS_IPHONE
  encoding.networkPriority = RTCPriorityLow;
  encoding.bitratePriority = 1.0;
#endif
  [encoding setRid:map[@"rid"]];

  if (map[@"active"] != nil) {
    [encoding setIsActive:((NSNumber*)map[@"active"]).boolValue];
  }

  if (map[@"minBitrate"] != nil) {
    [encoding setMinBitrateBps:(NSNumber*)map[@"minBitrate"]];
  }

  if (map[@"maxBitrate"] != nil) {
    [encoding setMaxBitrateBps:(NSNumber*)map[@"maxBitrate"]];
  }

  if (map[@"maxFramerate"] != nil) {
    [encoding setMaxFramerate:(NSNumber*)map[@"maxFramerate"]];
  }

  if (map[@"numTemporalLayers"] != nil) {
    [encoding setNumTemporalLayers:(NSNumber*)map[@"numTemporalLayers"]];
  }

  if (map[@"scaleResolutionDownBy"] != nil) {
    [encoding setScaleResolutionDownBy:(NSNumber*)map[@"scaleResolutionDownBy"]];
  }
  return encoding;
}

- (RTCRtpTransceiverInit*)mapToTransceiverInit:(NSDictionary*)map {
  NSArray<NSString*>* streamIds = map[@"streamIds"];
  NSArray<NSDictionary*>* encodingsParams = map[@"sendEncodings"];
  NSString* direction = map[@"direction"];

  RTCRtpTransceiverInit* init = [RTCRtpTransceiverInit alloc];

  if (direction != nil) {
    init.direction = [self stringToTransceiverDirection:direction];
  }

  if (streamIds != nil) {
    init.streamIds = streamIds;
  }

  if (encodingsParams != nil) {
    NSMutableArray<RTCRtpEncodingParameters*>* sendEncodings = [[NSMutableArray alloc] init];
    for (NSDictionary* map in encodingsParams) {
      [sendEncodings insertObject:[self mapToEncoding:map] atIndex:0];
    }
    [init setSendEncodings:sendEncodings];
  }
  return init;
}

- (RTCRtpMediaType)stringToRtpMediaType:(NSString*)type {
  if ([type isEqualToString:@"audio"]) {
    return RTCRtpMediaTypeAudio;
  } else if ([type isEqualToString:@"video"]) {
    return RTCRtpMediaTypeVideo;
  } else if ([type isEqualToString:@"data"]) {
    return RTCRtpMediaTypeData;
  }
  return RTCRtpMediaTypeAudio;
}

- (RTCRtpTransceiverDirection)stringToTransceiverDirection:(NSString*)type {
  if ([type isEqualToString:@"sendrecv"]) {
    return RTCRtpTransceiverDirectionSendRecv;
  } else if ([type isEqualToString:@"sendonly"]) {
    return RTCRtpTransceiverDirectionSendOnly;
  } else if ([type isEqualToString:@"recvonly"]) {
    return RTCRtpTransceiverDirectionRecvOnly;
  } else if ([type isEqualToString:@"inactive"]) {
    return RTCRtpTransceiverDirectionInactive;
  }
  return RTCRtpTransceiverDirectionInactive;
}

- (RTCRtpParameters*)updateRtpParameters:(RTCRtpParameters*)parameters
                                    with:(NSDictionary*)newParameters {
  // current encodings
  NSArray<RTCRtpEncodingParameters*>* currentEncodings = parameters.encodings;
  // new encodings
  NSArray* newEncodings = [newParameters objectForKey:@"encodings"];

  for (int i = 0; i < [newEncodings count]; i++) {
    RTCRtpEncodingParameters* currentParams = nil;
    NSDictionary* newParams = [newEncodings objectAtIndex:i];
    NSString* rid = [newParams objectForKey:@"rid"];

    // update by matching RID
    if ([rid isKindOfClass:[NSString class]] && [rid length] != 0) {
      // try to find current encoding with same rid
      NSUInteger result =
          [currentEncodings indexOfObjectPassingTest:^BOOL(RTCRtpEncodingParameters* _Nonnull obj,
                                                           NSUInteger idx, BOOL* _Nonnull stop) {
            // stop if found object with matching rid
            return (*stop = ([rid isEqualToString:obj.rid]));
          }];

      if (result != NSNotFound) {
        currentParams = [currentEncodings objectAtIndex:result];
      }
    }

    // fall back to update by index
    if (currentParams == nil && i < [currentEncodings count]) {
      currentParams = [currentEncodings objectAtIndex:i];
    }

    if (currentParams != nil) {
      // update values
      NSNumber* active = [newParams objectForKey:@"active"];
      if (active != nil)
        currentParams.isActive = [active boolValue];
      NSNumber* maxBitrate = [newParams objectForKey:@"maxBitrate"];
      if (maxBitrate != nil)
        currentParams.maxBitrateBps = maxBitrate;
      NSNumber* minBitrate = [newParams objectForKey:@"minBitrate"];
      if (minBitrate != nil)
        currentParams.minBitrateBps = minBitrate;
      NSNumber* maxFramerate = [newParams objectForKey:@"maxFramerate"];
      if (maxFramerate != nil)
        currentParams.maxFramerate = maxFramerate;
      NSNumber* numTemporalLayers = [newParams objectForKey:@"numTemporalLayers"];
      if (numTemporalLayers != nil)
        currentParams.numTemporalLayers = numTemporalLayers;
      NSNumber* scaleResolutionDownBy = [newParams objectForKey:@"scaleResolutionDownBy"];
      if (scaleResolutionDownBy != nil)
        currentParams.scaleResolutionDownBy = scaleResolutionDownBy;
    }
  }

  return parameters;
}

- (NSString*)transceiverDirectionString:(RTCRtpTransceiverDirection)direction {
  switch (direction) {
    case RTCRtpTransceiverDirectionSendRecv:
      return @"sendrecv";
    case RTCRtpTransceiverDirectionSendOnly:
      return @"sendonly";
    case RTCRtpTransceiverDirectionRecvOnly:
      return @"recvonly";
    case RTCRtpTransceiverDirectionInactive:
      return @"inactive";
    case RTCRtpTransceiverDirectionStopped:
      return @"stopped";
      break;
  }
  return nil;
}

- (NSDictionary*)transceiverToMap:(RTCRtpTransceiver*)transceiver {
  NSString* mid = transceiver.mid ? transceiver.mid : @"";
  NSDictionary* params = @{
    @"transceiverId" : mid,
    @"mid" : mid,
    @"direction" : [self transceiverDirectionString:transceiver.direction],
    @"sender" : [self rtpSenderToMap:transceiver.sender],
    @"receiver" : [self receiverToMap:transceiver.receiver]
  };
  return params;
}
@end
