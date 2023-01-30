#import "FlutterRTCPeerConnection.h"
#import <objc/runtime.h>
#import "AudioUtils.h"
#import "FlutterRTCDataChannel.h"
#import "FlutterWebRTCPlugin.h"

#import <WebRTC/WebRTC.h>

@implementation RTCPeerConnection (Flutter)

@dynamic eventSink;

- (NSString*)flutterId {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlutterId:(NSString*)flutterId {
  objc_setAssociatedObject(self, @selector(flutterId), flutterId,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventSink)eventSink {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventSink:(FlutterEventSink)eventSink {
  objc_setAssociatedObject(self, @selector(eventSink), eventSink,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventChannel*)eventChannel {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventChannel:(FlutterEventChannel*)eventChannel {
  objc_setAssociatedObject(self, @selector(eventChannel), eventChannel,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString*, RTCDataChannel*>*)dataChannels {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setDataChannels:(NSMutableDictionary<NSString*, RTCDataChannel*>*)dataChannels {
  objc_setAssociatedObject(self, @selector(dataChannels), dataChannels,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString*, RTCMediaStream*>*)remoteStreams {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setRemoteStreams:(NSMutableDictionary<NSString*, RTCMediaStream*>*)remoteStreams {
  objc_setAssociatedObject(self, @selector(remoteStreams), remoteStreams,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString*, RTCMediaStreamTrack*>*)remoteTracks {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setRemoteTracks:(NSMutableDictionary<NSString*, RTCMediaStreamTrack*>*)remoteTracks {
  objc_setAssociatedObject(self, @selector(remoteTracks), remoteTracks,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  self.eventSink = nil;
  return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)sink {
  self.eventSink = sink;
  return nil;
}

@end

@implementation FlutterWebRTCPlugin (RTCPeerConnection)

- (void)peerConnectionSetConfiguration:(RTCConfiguration*)configuration
                        peerConnection:(RTCPeerConnection*)peerConnection {
  [peerConnection setConfiguration:configuration];
}

- (void)peerConnectionCreateOffer:(NSDictionary*)constraints
                   peerConnection:(RTCPeerConnection*)peerConnection
                           result:(FlutterResult)result {
  [peerConnection
      offerForConstraints:[self parseMediaConstraints:constraints]
        completionHandler:^(RTCSessionDescription* sdp, NSError* error) {
          if (error) {
            result([FlutterError
                errorWithCode:@"CreateOfferFailed"
                      message:[NSString stringWithFormat:@"Error %@", error.userInfo[@"error"]]
                      details:nil]);
          } else {
            NSString* type = [RTCSessionDescription stringForType:sdp.type];
            result(@{@"sdp" : sdp.sdp, @"type" : type});
          }
        }];
}

- (void)peerConnectionCreateAnswer:(NSDictionary*)constraints
                    peerConnection:(RTCPeerConnection*)peerConnection
                            result:(FlutterResult)result {
  [peerConnection
      answerForConstraints:[self parseMediaConstraints:constraints]
         completionHandler:^(RTCSessionDescription* sdp, NSError* error) {
           if (error) {
             result([FlutterError
                 errorWithCode:@"CreateAnswerFailed"
                       message:[NSString stringWithFormat:@"Error %@", error.userInfo[@"error"]]
                       details:nil]);
           } else {
             NSString* type = [RTCSessionDescription stringForType:sdp.type];
             result(@{@"sdp" : sdp.sdp, @"type" : type});
           }
         }];
}

- (void)peerConnectionSetLocalDescription:(RTCSessionDescription*)sdp
                           peerConnection:(RTCPeerConnection*)peerConnection
                                   result:(FlutterResult)result {
  [peerConnection
      setLocalDescription:sdp
        completionHandler:^(NSError* error) {
          if (error) {
            result([FlutterError
                errorWithCode:@"SetLocalDescriptionFailed"
                      message:[NSString stringWithFormat:@"Error %@", error.localizedDescription]
                      details:nil]);
          } else {
            result(nil);
          }
        }];
}

- (void)peerConnectionSetRemoteDescription:(RTCSessionDescription*)sdp
                            peerConnection:(RTCPeerConnection*)peerConnection
                                    result:(FlutterResult)result {
  [peerConnection
      setRemoteDescription:sdp
         completionHandler:^(NSError* error) {
           if (error) {
             result([FlutterError
                 errorWithCode:@"SetRemoteDescriptionFailed"
                       message:[NSString stringWithFormat:@"Error %@", error.localizedDescription]
                       details:nil]);
           } else {
             result(nil);
           }
         }];
}

- (void)peerConnectionAddICECandidate:(RTCIceCandidate*)candidate
                       peerConnection:(RTCPeerConnection*)peerConnection
                               result:(FlutterResult)result {
  [peerConnection
        addIceCandidate:candidate
      completionHandler:^(NSError* _Nullable error) {
        if (error) {
          result([FlutterError
              errorWithCode:@"AddIceCandidateFailed"
                    message:[NSString stringWithFormat:@"Error %@", error.localizedDescription]
                    details:nil]);
        } else {
          result(nil);
        }
      }];
}

- (void)peerConnectionClose:(RTCPeerConnection*)peerConnection {
  [peerConnection close];

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

- (void)peerConnectionGetStatsForTrackId:(nonnull NSString*)trackID
                          peerConnection:(nonnull RTCPeerConnection*)peerConnection
                                  result:(nonnull FlutterResult)result {
  RTCRtpSender* sender = nil;
  RTCRtpReceiver* receiver = nil;

  for (RTCRtpSender* s in peerConnection.senders) {
    if (s.track != nil && [s.track.trackId isEqualToString:trackID]) {
      sender = s;
    }
  }

  for (RTCRtpReceiver* r in peerConnection.receivers) {
    if (r.track != nil && [r.track.trackId isEqualToString:trackID]) {
      receiver = r;
    }
  }

  if (sender != nil) {
    [peerConnection statisticsForSender:sender
                      completionHandler:^(RTCStatisticsReport* statsReport) {
                        NSMutableArray* stats = [NSMutableArray array];
                        for (id key in statsReport.statistics) {
                          RTCStatistics* report = [statsReport.statistics objectForKey:key];
                          [stats addObject:@{
                            @"id" : report.id,
                            @"type" : report.type,
                            @"timestamp" : @(report.timestamp_us),
                            @"values" : report.values
                          }];
                        }
                        result(@{@"stats" : stats});
                      }];
  } else if (receiver != nil) {
    [peerConnection statisticsForReceiver:receiver
                        completionHandler:^(RTCStatisticsReport* statsReport) {
                          NSMutableArray* stats = [NSMutableArray array];
                          for (id key in statsReport.statistics) {
                            RTCStatistics* report = [statsReport.statistics objectForKey:key];
                            [stats addObject:@{
                              @"id" : report.id,
                              @"type" : report.type,
                              @"timestamp" : @(report.timestamp_us),
                              @"values" : report.values
                            }];
                          }
                          result(@{@"stats" : stats});
                        }];
  } else {
    result([FlutterError errorWithCode:@"GetStatsFailed"
                               message:[NSString stringWithFormat:@"Error %@", @""]
                               details:nil]);
  }
}

- (void)peerConnectionGetStats:(nonnull RTCPeerConnection*)peerConnection
                        result:(nonnull FlutterResult)result {
  [peerConnection statisticsWithCompletionHandler:^(RTCStatisticsReport* statsReport) {
    NSMutableArray* stats = [NSMutableArray array];
    for (id key in statsReport.statistics) {
      RTCStatistics* report = [statsReport.statistics objectForKey:key];
      [stats addObject:@{
        @"id" : report.id,
        @"type" : report.type,
        @"timestamp" : @(report.timestamp_us),
        @"values" : report.values
      }];
    }
    result(@{@"stats" : stats});
  }];
}

- (NSString*)stringForICEConnectionState:(RTCIceConnectionState)state {
  switch (state) {
    case RTCIceConnectionStateNew:
      return @"new";
    case RTCIceConnectionStateChecking:
      return @"checking";
    case RTCIceConnectionStateConnected:
      return @"connected";
    case RTCIceConnectionStateCompleted:
      return @"completed";
    case RTCIceConnectionStateFailed:
      return @"failed";
    case RTCIceConnectionStateDisconnected:
      return @"disconnected";
    case RTCIceConnectionStateClosed:
      return @"closed";
    case RTCIceConnectionStateCount:
      return @"count";
  }
  return nil;
}

- (NSString*)stringForICEGatheringState:(RTCIceGatheringState)state {
  switch (state) {
    case RTCIceGatheringStateNew:
      return @"new";
    case RTCIceGatheringStateGathering:
      return @"gathering";
    case RTCIceGatheringStateComplete:
      return @"complete";
  }
  return nil;
}

- (NSString*)stringForSignalingState:(RTCSignalingState)state {
  switch (state) {
    case RTCSignalingStateStable:
      return @"stable";
    case RTCSignalingStateHaveLocalOffer:
      return @"have-local-offer";
    case RTCSignalingStateHaveLocalPrAnswer:
      return @"have-local-pranswer";
    case RTCSignalingStateHaveRemoteOffer:
      return @"have-remote-offer";
    case RTCSignalingStateHaveRemotePrAnswer:
      return @"have-remote-pranswer";
    case RTCSignalingStateClosed:
      return @"closed";
  }
  return nil;
}

- (NSString*)stringForPeerConnectionState:(RTCPeerConnectionState)state {
  switch (state) {
    case RTCPeerConnectionStateNew:
      return @"new";
    case RTCPeerConnectionStateConnecting:
      return @"connecting";
    case RTCPeerConnectionStateConnected:
      return @"connected";
    case RTCPeerConnectionStateDisconnected:
      return @"disconnected";
    case RTCPeerConnectionStateFailed:
      return @"failed";
    case RTCPeerConnectionStateClosed:
      return @"closed";
  }
  return nil;
}

/**
 * Parses the constraint keys and values of a specific JavaScript object into
 * a specific <tt>NSMutableDictionary</tt> in a format suitable for the
 * initialization of a <tt>RTCMediaConstraints</tt> instance.
 *
 * @param src The JavaScript object which defines constraint keys and values and
 * which is to be parsed into the specified <tt>dst</tt>.
 * @param dst The <tt>NSMutableDictionary</tt> into which the constraint keys
 * and values defined by <tt>src</tt> are to be written in a format suitable for
 * the initialization of a <tt>RTCMediaConstraints</tt> instance.
 */
- (void)parseJavaScriptConstraints:(NSDictionary*)src
             intoWebRTCConstraints:(NSMutableDictionary<NSString*, NSString*>*)dst {
  for (id srcKey in src) {
    id srcValue = src[srcKey];
    NSString* dstValue;

    if ([srcValue isKindOfClass:[NSNumber class]]) {
      dstValue = [srcValue boolValue] ? @"true" : @"false";
    } else {
      dstValue = [srcValue description];
    }
    dst[[srcKey description]] = dstValue;
  }
}

/**
 * Parses a JavaScript object into a new <tt>RTCMediaConstraints</tt> instance.
 *
 * @param constraints The JavaScript object to parse into a new
 * <tt>RTCMediaConstraints</tt> instance.
 * @returns A new <tt>RTCMediaConstraints</tt> instance initialized with the
 * mandatory and optional constraint keys and values specified by
 * <tt>constraints</tt>.
 */
- (RTCMediaConstraints*)parseMediaConstraints:(NSDictionary*)constraints {
  id mandatory = constraints[@"mandatory"];
  NSMutableDictionary<NSString*, NSString*>* mandatory_ = [NSMutableDictionary new];

  if ([mandatory isKindOfClass:[NSDictionary class]]) {
    [self parseJavaScriptConstraints:(NSDictionary*)mandatory intoWebRTCConstraints:mandatory_];
  }

  id optional = constraints[@"optional"];
  NSMutableDictionary<NSString*, NSString*>* optional_ = [NSMutableDictionary new];

  if ([optional isKindOfClass:[NSArray class]]) {
    for (id o in (NSArray*)optional) {
      if ([o isKindOfClass:[NSDictionary class]]) {
        [self parseJavaScriptConstraints:(NSDictionary*)o intoWebRTCConstraints:optional_];
      }
    }
  }

  return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory_
                                               optionalConstraints:optional_];
}

#pragma mark - RTCPeerConnectionDelegate methods
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didChangeSignalingState:(RTCSignalingState)newState {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{@"event" : @"signalingState", @"state" : [self stringForSignalingState:newState]});
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
           mediaStream:(RTCMediaStream*)stream
           didAddTrack:(RTCVideoTrack*)track {
  peerConnection.remoteTracks[track.trackId] = track;
  NSString* streamId = stream.streamId;
  peerConnection.remoteStreams[streamId] = stream;

  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onAddTrack",
      @"streamId" : streamId,
      @"trackId" : track.trackId,
      @"track" : @{
        @"id" : track.trackId,
        @"kind" : track.kind,
        @"label" : track.trackId,
        @"enabled" : @(track.isEnabled),
        @"remote" : @(YES),
        @"readyState" : @"live"
      }
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
           mediaStream:(RTCMediaStream*)stream
        didRemoveTrack:(RTCVideoTrack*)track {
  [peerConnection.remoteTracks removeObjectForKey:track.trackId];
  NSString* streamId = stream.streamId;
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onRemoveTrack",
      @"streamId" : streamId,
      @"trackId" : track.trackId,
      @"track" : @{
        @"id" : track.trackId,
        @"kind" : track.kind,
        @"label" : track.trackId,
        @"enabled" : @(track.isEnabled),
        @"remote" : @(YES),
        @"readyState" : @"live"
      }
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection didAddStream:(RTCMediaStream*)stream {
  NSMutableArray* audioTracks = [NSMutableArray array];
  NSMutableArray* videoTracks = [NSMutableArray array];

  BOOL hasAudio = NO;
  for (RTCAudioTrack* track in stream.audioTracks) {
    peerConnection.remoteTracks[track.trackId] = track;
    [audioTracks addObject:@{
      @"id" : track.trackId,
      @"kind" : track.kind,
      @"label" : track.trackId,
      @"enabled" : @(track.isEnabled),
      @"remote" : @(YES),
      @"readyState" : @"live"
    }];
    hasAudio = YES;
  }

  for (RTCVideoTrack* track in stream.videoTracks) {
    peerConnection.remoteTracks[track.trackId] = track;
    [videoTracks addObject:@{
      @"id" : track.trackId,
      @"kind" : track.kind,
      @"label" : track.trackId,
      @"enabled" : @(track.isEnabled),
      @"remote" : @(YES),
      @"readyState" : @"live"
    }];
  }

  NSString* streamId = stream.streamId;
  peerConnection.remoteStreams[streamId] = stream;

  if (hasAudio) {
    [self ensureAudioSession];
  }

  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onAddStream",
      @"streamId" : streamId,
      @"audioTracks" : audioTracks,
      @"videoTracks" : videoTracks,
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection didRemoveStream:(RTCMediaStream*)stream {
  NSArray* keysArray = [peerConnection.remoteStreams allKeysForObject:stream];
  // We assume there can be only one object for 1 key
  if (keysArray.count > 1) {
    NSLog(@"didRemoveStream - more than one stream entry found for stream instance with id: %@",
          stream.streamId);
  }
  NSString* streamId = stream.streamId;

  for (RTCVideoTrack* track in stream.videoTracks) {
    [peerConnection.remoteTracks removeObjectForKey:track.trackId];
  }
  for (RTCAudioTrack* track in stream.audioTracks) {
    [peerConnection.remoteTracks removeObjectForKey:track.trackId];
  }
  [peerConnection.remoteStreams removeObjectForKey:streamId];

  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onRemoveStream",
      @"streamId" : streamId,
    });
  }
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection*)peerConnection {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onRenegotiationNeeded",
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didChangeIceConnectionState:(RTCIceConnectionState)newState {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"iceConnectionState",
      @"state" : [self stringForICEConnectionState:newState]
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didChangeIceGatheringState:(RTCIceGatheringState)newState {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(
        @{@"event" : @"iceGatheringState", @"state" : [self stringForICEGatheringState:newState]});
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didGenerateIceCandidate:(RTCIceCandidate*)candidate {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onCandidate",
      @"candidate" : @{
        @"candidate" : candidate.sdp,
        @"sdpMLineIndex" : @(candidate.sdpMLineIndex),
        @"sdpMid" : candidate.sdpMid
      }
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
  if (-1 == dataChannel.channelId) {
    return;
  }

  NSString* flutterChannelId = [[NSUUID UUID] UUIDString];
  NSNumber* dataChannelId = [NSNumber numberWithInteger:dataChannel.channelId];
  dataChannel.peerConnectionId = peerConnection.flutterId;
  dataChannel.delegate = self;
  peerConnection.dataChannels[flutterChannelId] = dataChannel;

  FlutterEventChannel* eventChannel = [FlutterEventChannel
      eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/dataChannelEvent%1$@%2$@",
                                                      peerConnection.flutterId, flutterChannelId]
           binaryMessenger:self.messenger];

  dataChannel.eventChannel = eventChannel;
  dataChannel.flutterChannelId = flutterChannelId;
  dataChannel.eventQueue = nil;

  dispatch_async(dispatch_get_main_queue(), ^{
    // setStreamHandler on main thread
    [eventChannel setStreamHandler:dataChannel];
    FlutterEventSink eventSink = peerConnection.eventSink;
    if (eventSink) {
      eventSink(@{
        @"event" : @"didOpenDataChannel",
        @"id" : dataChannelId,
        @"label" : dataChannel.label,
        @"flutterId" : flutterChannelId
      });
    }
  });
}

/** Called any time the PeerConnectionState changes. */
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didChangeConnectionState:(RTCPeerConnectionState)newState {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"peerConnectionState",
      @"state" : [self stringForPeerConnectionState:newState]
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didStartReceivingOnTransceiver:(RTCRtpTransceiver*)transceiver {
}

/** Called when a receiver and its track are created. */
- (void)peerConnection:(RTCPeerConnection*)peerConnection
        didAddReceiver:(RTCRtpReceiver*)rtpReceiver
               streams:(NSArray<RTCMediaStream*>*)mediaStreams {
  // For unified-plan
  NSMutableArray* streams = [NSMutableArray array];
  for (RTCMediaStream* stream in mediaStreams) {
    [streams addObject:[self mediaStreamToMap:stream ownerTag:peerConnection.flutterId]];
  }
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    NSMutableDictionary* event = [NSMutableDictionary dictionary];
    [event addEntriesFromDictionary:@{
      @"event" : @"onTrack",
      @"track" : [self mediaTrackToMap:rtpReceiver.track],
      @"receiver" : [self receiverToMap:rtpReceiver],
      @"streams" : streams,
    }];

    if (peerConnection.configuration.sdpSemantics == RTCSdpSemanticsUnifiedPlan) {
      for (RTCRtpTransceiver* transceiver in peerConnection.transceivers) {
        if (transceiver.receiver != nil &&
            [transceiver.receiver.receiverId isEqualToString:rtpReceiver.receiverId]) {
          [event setValue:[self transceiverToMap:transceiver] forKey:@"transceiver"];
        }
      }
    }

    peerConnection.remoteTracks[rtpReceiver.track.trackId] = rtpReceiver.track;
    if (mediaStreams.count > 0) {
      peerConnection.remoteStreams[mediaStreams[0].streamId] = mediaStreams[0];
    }

    if ([rtpReceiver.track.kind isEqualToString:@"audio"]) {
      [self ensureAudioSession];
    }
    eventSink(event);
  }
}

/** Called when the receiver and its track are removed. */
- (void)peerConnection:(RTCPeerConnection*)peerConnection
     didRemoveReceiver:(RTCRtpReceiver*)rtpReceiver {
}

/** Called when the selected ICE candidate pair is changed. */
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didChangeLocalCandidate:(RTCIceCandidate*)local
            remoteCandidate:(RTCIceCandidate*)remote
             lastReceivedMs:(int)lastDataReceivedMs
               changeReason:(NSString*)reason {
  FlutterEventSink eventSink = peerConnection.eventSink;
  if (eventSink) {
    eventSink(@{
      @"event" : @"onSelectedCandidatePairChanged",
      @"local" : @{
        @"candidate" : local.sdp,
        @"sdpMLineIndex" : @(local.sdpMLineIndex),
        @"sdpMid" : local.sdpMid
      },
      @"remote" : @{
        @"candidate" : remote.sdp,
        @"sdpMLineIndex" : @(remote.sdpMLineIndex),
        @"sdpMid" : remote.sdpMid
      },
      @"reason" : reason,
      @"lastDataReceivedMs" : @(lastDataReceivedMs)
    });
  }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didRemoveIceCandidates:(NSArray<RTCIceCandidate*>*)candidates {
}

RTCRtpMediaType mediaTypeFromString(NSString *kind) {
    RTCRtpMediaType mediaType = RTCRtpMediaTypeUnsupported;
    if([kind isEqualToString:@"audio"]) {
        mediaType = RTCRtpMediaTypeAudio;
    } else if([kind isEqualToString:@"video"]) {
        mediaType = RTCRtpMediaTypeVideo;
    } else if([kind isEqualToString:@"data"]) {
        mediaType = RTCRtpMediaTypeData;
    }
    return mediaType;
}

NSString *parametersToString(NSDictionary<NSString *, NSString *> *parameters) {
    NSMutableArray* kvs = [NSMutableArray array];
    for(NSString *key in parameters) {
        if(key.length > 0) {
            [kvs addObject:[NSString stringWithFormat:@"%@=%@", key, parameters[key]]];
        } else {
            [kvs addObject:parameters[key]];
        }
    }
    return [kvs componentsJoinedByString:@";"];
}

NSDictionary<NSString *, NSString *> *stringToParameters(NSString *str) {
    NSMutableDictionary<NSString *, NSString *> *parameters = [NSMutableDictionary dictionary];
    NSArray<NSString *> *kvs = [str componentsSeparatedByString:@";"];
    for(NSString *kv in kvs) {
        NSArray<NSString *> *kvArr = [kv componentsSeparatedByString:@"="];
        if(kvArr.count == 2) {
            parameters[kvArr[0]] = kvArr[1];
        } else if(kvArr.count == 1) {
            parameters[@""] = kvArr[0];
        }
    }
    return parameters;
}

- (void)peerConnectionGetRtpReceiverCapabilities:(nonnull NSDictionary*)argsMap result:(nonnull FlutterResult)result {
    NSString* kind = argsMap[@"kind"];
    RTCRtpCapabilities *caps = [self.peerConnectionFactory rtpReceiverCapabilitiesFor:mediaTypeFromString(kind)];
    NSMutableArray* codecsMap = [NSMutableArray array];
    for( RTCRtpCodecCapability *c in caps.codecs) {
        if([kind isEqualToString:@"audio"]) {
            [codecsMap addObject:@{
              @"channels" : c.numChannels,
              @"clockRate" : c.clockRate,
              @"mimeType" : c.mimeType,
              @"sdpFmtpLine" : parametersToString(c.parameters),
            }];
        }else if([kind isEqualToString:@"video"]) {
            [codecsMap addObject:@{
              @"clockRate" : c.clockRate,
              @"mimeType" : c.mimeType,
              @"sdpFmtpLine" : parametersToString(c.parameters),
            }];
        }
    }
    result(@{@"codecs": codecsMap,
             @"headerExtensions": @[],
             @"fecMechanisms": @[],
           });
}

- (void)peerConnectionGetRtpSenderCapabilities:(nonnull NSDictionary*)argsMap result:(nonnull FlutterResult)result {
    NSString* kind = argsMap[@"kind"];
    RTCRtpCapabilities *caps = [self.peerConnectionFactory rtpSenderCapabilitiesFor:mediaTypeFromString(kind)];
    NSMutableArray* codecsMap = [NSMutableArray array];
    for( RTCRtpCodecCapability *c in caps.codecs) {
        if([kind isEqualToString:@"audio"]) {
            [codecsMap addObject:@{
              @"channels" : c.numChannels,
              @"clockRate" : c.clockRate,
              @"mimeType" : c.mimeType,
              @"sdpFmtpLine" : parametersToString(c.parameters),
            }];
        }else if([kind isEqualToString:@"video"]) {
            [codecsMap addObject:@{
              @"clockRate" : c.clockRate,
              @"mimeType" : c.mimeType,
              @"sdpFmtpLine" : parametersToString(c.parameters),
            }];
        }
    }
    result(@{@"codecs": codecsMap,
             @"headerExtensions": @[],
             @"fecMechanisms": @[],
           });
}

- (void)transceiverSetCodecPreferences:(nonnull NSDictionary*)argsMap result:(nonnull FlutterResult)result {
    NSString* peerConnectionId = argsMap[@"peerConnectionId"];
    RTCPeerConnection* peerConnection = self.peerConnections[peerConnectionId];
    if (peerConnection == nil) {
      result([FlutterError
          errorWithCode:@"transceiverSetCodecPreferencesFailed"
                message:[NSString stringWithFormat:@"Error: peerConnection not found!"]
                details:nil]);
      return;
    }
    NSString* transceiverId = argsMap[@"transceiverId"];
    RTCRtpTransceiver* transcevier = [self getRtpTransceiverById:peerConnection Id:transceiverId];
    if (transcevier == nil) {
      result([FlutterError
          errorWithCode:@"transceiverSetCodecPreferencesFailed"
                message:[NSString stringWithFormat:@"Error: transcevier not found!"]
                details:nil]);
      return;
    }
    id codecs = argsMap[@"codecs"];
    NSMutableArray* codecCaps = [NSMutableArray array];
    for(id c in codecs) {
        NSLog(@"codec %@", c);
        NSArray *kindAndName = [c[@"mimeType"] componentsSeparatedByString:@"/"];
        RTCRtpCodecCapability *codec = [[RTCRtpCodecCapability alloc] init];
        codec.clockRate = c[@"clockRate"];
        codec.kind = mediaTypeFromString([kindAndName[0] lowercaseString]);
        codec.name = kindAndName[1];
        if(c[@"sdpFmtpLine"] != nil) {
            codec.parameters = stringToParameters((NSString *)c[@"sdpFmtpLine"]);
        }
        if(c[@"channels"] != nil) {
            codec.numChannels = c[@"channels"];
        }
        [codecCaps addObject:codec];
    }
    [transcevier setCodecPreferences:codecCaps];
    result(nil);
}

@end
