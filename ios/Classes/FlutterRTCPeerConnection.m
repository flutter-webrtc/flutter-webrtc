#import <objc/runtime.h>
#import "FlutterWebRTCPlugin.h"
#import "FlutterRTCPeerConnection.h"
#import "FlutterRTCDataChannel.h"

#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCLegacyStatsReport.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCMediaStream.h>

@implementation RTCPeerConnection (Flutter)

@dynamic eventSink;

- (NSString *)flutterId
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlutterId:(NSString *)flutterId
{
    objc_setAssociatedObject(self, @selector(flutterId), flutterId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventSink)eventSink
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventSink:(FlutterEventSink)eventSink
{
    objc_setAssociatedObject(self, @selector(eventSink), eventSink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventChannel *)eventChannel
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventChannel:(FlutterEventChannel *)eventChannel
{
    objc_setAssociatedObject(self, @selector(eventChannel), eventChannel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *, RTCDataChannel *> *)dataChannels
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDataChannels:(NSMutableDictionary<NSString *, RTCDataChannel *> *)dataChannels
{
    objc_setAssociatedObject(self, @selector(dataChannels), dataChannels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *, RTCMediaStream *> *)remoteStreams
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRemoteStreams:(NSMutableDictionary<NSString *,RTCMediaStream *> *)remoteStreams
{
    objc_setAssociatedObject(self, @selector(remoteStreams), remoteStreams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *)remoteTracks
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRemoteTracks:(NSMutableDictionary<NSString *,RTCMediaStreamTrack *> *)remoteTracks
{
    objc_setAssociatedObject(self, @selector(remoteTracks), remoteTracks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

-(void) peerConnectionSetConfiguration:(RTCConfiguration*)configuration
                        peerConnection:(RTCPeerConnection*)peerConnection
{
    [peerConnection setConfiguration:configuration];
}

-(void) peerConnectionCreateOffer:(NSDictionary *)constraints
                   peerConnection:(RTCPeerConnection*)peerConnection
                           result:(FlutterResult)result
{
    [peerConnection
     offerForConstraints:[self parseMediaConstraints:constraints]
     completionHandler:^(RTCSessionDescription *sdp, NSError *error) {
         if (error) {
             result([FlutterError errorWithCode:@"CreateOfferFailed"
                                        message:[NSString stringWithFormat:@"Error %@", error.userInfo[@"error"]]
                                        details:nil]);
         } else {
             NSString *type = [RTCSessionDescription stringForType:sdp.type];
             result(@{@"sdp": sdp.sdp, @"type": type});
         }
     }];
}

-(void) peerConnectionCreateAnswer:(NSDictionary *)constraints
                    peerConnection:(RTCPeerConnection *)peerConnection
                            result:(FlutterResult)result
{
    [peerConnection
     answerForConstraints:[self parseMediaConstraints:constraints]
     completionHandler:^(RTCSessionDescription *sdp, NSError *error) {
         if (error) {
             result([FlutterError errorWithCode:@"CreateAnswerFailed"
                                        message:[NSString stringWithFormat:@"Error %@", error.userInfo[@"error"]]
                                        details:nil]);
         } else {
             NSString *type = [RTCSessionDescription stringForType:sdp.type];
             result(@{@"sdp": sdp.sdp, @"type": type});
         }
     }];
}

-(void) peerConnectionSetLocalDescription:(RTCSessionDescription *)sdp
                           peerConnection:(RTCPeerConnection *)peerConnection
                                   result:(FlutterResult)result
{
    [peerConnection setLocalDescription:sdp completionHandler: ^(NSError *error) {
        if (error) {
            result([FlutterError errorWithCode:@"SetLocalDescriptionFailed"
                                       message:[NSString stringWithFormat:@"Error %@", error.localizedDescription]
                                       details:nil]);
        } else {
            result(nil);
        }
    }];
}

-(void) peerConnectionSetRemoteDescription:(RTCSessionDescription *)sdp
                            peerConnection:(RTCPeerConnection *)peerConnection
                                    result:(FlutterResult)result
{
    [peerConnection setRemoteDescription: sdp completionHandler: ^(NSError *error) {
        if (error) {
            result([FlutterError errorWithCode:@"SetRemoteDescriptionFailed"
                                       message:[NSString stringWithFormat:@"Error %@", error.localizedDescription]
                                       details:nil]);
        } else {
            result(nil);
        }
    }];
}

-(void) peerConnectionAddICECandidate:(RTCIceCandidate*)candidate
                       peerConnection:(RTCPeerConnection *)peerConnection
                               result:(FlutterResult)result
{
    [peerConnection addIceCandidate:candidate];
    result(nil);
    //NSLog(@"addICECandidateresult: %@", candidate);
}

-(void) peerConnectionClose:(RTCPeerConnection *)peerConnection
{
    [peerConnection close];
    
    // Clean up peerConnection's streams and tracks
    [peerConnection.remoteStreams removeAllObjects];
    [peerConnection.remoteTracks removeAllObjects];
    
    // Clean up peerConnection's dataChannels.
    NSMutableDictionary<NSString *, RTCDataChannel *> *dataChannels
    = peerConnection.dataChannels;
    for (NSString *dataChannelId in dataChannels) {
        dataChannels[dataChannelId].delegate = nil;
        // There is no need to close the RTCDataChannel because it is owned by the
        // RTCPeerConnection and the latter will close the former.
    }
    [dataChannels removeAllObjects];
}

-(void) peerConnectionGetStats:(nonnull NSString *)trackID
                peerConnection:(nonnull RTCPeerConnection *)peerConnection
                        result:(nonnull FlutterResult)result
{
    RTCMediaStreamTrack *track = nil;
    if (!trackID
        || !trackID.length
        || (track = self.localTracks[trackID])
        || (track = peerConnection.remoteTracks[trackID])) {
        [peerConnection statsForTrack:track
                     statsOutputLevel:RTCStatsOutputLevelStandard
                    completionHandler:^(NSArray<RTCLegacyStatsReport *> *reports) {
                        
                        NSMutableArray *stats = [NSMutableArray array];
                        
                        for (RTCLegacyStatsReport *report in reports) {
                            [stats addObject:@{@"id": report.reportId,
                                               @"type": report.type,
                                               @"timestamp": @(report.timestamp),
                                               @"values": report.values
                                               }];
                        }
                        
                        result(@{@"stats": stats});
                    }];
    }else{
        result([FlutterError errorWithCode:@"GetStatsFailed"
                                   message:[NSString stringWithFormat:@"Error %@", @""]
                                   details:nil]);
    }
}

- (NSString *)stringForICEConnectionState:(RTCIceConnectionState)state {
    switch (state) {
        case RTCIceConnectionStateNew: return @"new";
        case RTCIceConnectionStateChecking: return @"checking";
        case RTCIceConnectionStateConnected: return @"connected";
        case RTCIceConnectionStateCompleted: return @"completed";
        case RTCIceConnectionStateFailed: return @"failed";
        case RTCIceConnectionStateDisconnected: return @"disconnected";
        case RTCIceConnectionStateClosed: return @"closed";
        case RTCIceConnectionStateCount: return @"count";
    }
    return nil;
}

- (NSString *)stringForICEGatheringState:(RTCIceGatheringState)state {
    switch (state) {
        case RTCIceGatheringStateNew: return @"new";
        case RTCIceGatheringStateGathering: return @"gathering";
        case RTCIceGatheringStateComplete: return @"complete";
    }
    return nil;
}

- (NSString *)stringForSignalingState:(RTCSignalingState)state {
    switch (state) {
        case RTCSignalingStateStable: return @"stable";
        case RTCSignalingStateHaveLocalOffer: return @"have-local-offer";
        case RTCSignalingStateHaveLocalPrAnswer: return @"have-local-pranswer";
        case RTCSignalingStateHaveRemoteOffer: return @"have-remote-offer";
        case RTCSignalingStateHaveRemotePrAnswer: return @"have-remote-pranswer";
        case RTCSignalingStateClosed: return @"closed";
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
- (void)parseJavaScriptConstraints:(NSDictionary *)src
             intoWebRTCConstraints:(NSMutableDictionary<NSString *, NSString *> *)dst {
    for (id srcKey in src) {
        id srcValue = src[srcKey];
        NSString *dstValue;
        
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
- (RTCMediaConstraints *)parseMediaConstraints:(NSDictionary *)constraints {
    id mandatory = constraints[@"mandatory"];
    NSMutableDictionary<NSString *, NSString *> *mandatory_
    = [NSMutableDictionary new];
    
    if ([mandatory isKindOfClass:[NSDictionary class]]) {
        [self parseJavaScriptConstraints:(NSDictionary *)mandatory
                   intoWebRTCConstraints:mandatory_];
    }
    
    id optional = constraints[@"optional"];
    NSMutableDictionary<NSString *, NSString *> *optional_
    = [NSMutableDictionary new];
    
    if ([optional isKindOfClass:[NSArray class]]) {
        for (id o in (NSArray *)optional) {
            if ([o isKindOfClass:[NSDictionary class]]) {
                [self parseJavaScriptConstraints:(NSDictionary *)o
                           intoWebRTCConstraints:optional_];
            }
        }
    }
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory_
                                                 optionalConstraints:optional_];
}

#pragma mark - RTCPeerConnectionDelegate methods

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)newState {
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"signalingState",
                    @"state" : [self stringForSignalingState:newState]});
    }
}

-(void)peerConnection:(RTCPeerConnection *)peerConnection
          mediaStream:(RTCMediaStream *)stream didAddTrack:(RTCVideoTrack*)track{
    
    peerConnection.remoteTracks[track.trackId] = track;
    NSString *streamId = stream.streamId;
    peerConnection.remoteStreams[streamId] = stream;
    
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"onAddTrack",
                    @"streamId": streamId,
                    @"trackId": track.trackId,
                    @"track": @{
                            @"id": track.trackId,
                            @"kind": track.kind,
                            @"label": track.trackId,
                            @"enabled": @(track.isEnabled),
                            @"remote": @(YES),
                            @"readyState": @"live"}
                    });
    }
}

-(void)peerConnection:(RTCPeerConnection *)peerConnection
          mediaStream:(RTCMediaStream *)stream didRemoveTrack:(RTCVideoTrack*)track{
    [peerConnection.remoteTracks removeObjectForKey:track.trackId];
    NSString *streamId = stream.streamId;
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"onRemoveTrack",
                    @"streamId": streamId,
                    @"trackId": track.trackId,
                    @"track": @{
                            @"id": track.trackId,
                            @"kind": track.kind,
                            @"label": track.trackId,
                            @"enabled": @(track.isEnabled),
                            @"remote": @(YES),
                            @"readyState": @"live"}
                    });
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    NSMutableArray *audioTracks = [NSMutableArray array];
    NSMutableArray *videoTracks = [NSMutableArray array];

    for (RTCAudioTrack *track in stream.audioTracks) {
        peerConnection.remoteTracks[track.trackId] = track;
        [audioTracks addObject:@{@"id": track.trackId, @"kind": track.kind, @"label": track.trackId, @"enabled": @(track.isEnabled), @"remote": @(YES), @"readyState": @"live"}];
    }
    
    for (RTCVideoTrack *track in stream.videoTracks) {
        peerConnection.remoteTracks[track.trackId] = track;
        [videoTracks addObject:@{@"id": track.trackId, @"kind": track.kind, @"label": track.trackId, @"enabled": @(track.isEnabled), @"remote": @(YES), @"readyState": @"live"}];
    }
    
    NSString *streamId = stream.streamId;
    peerConnection.remoteStreams[streamId] = stream;
    
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"onAddStream",
                    @"streamId": streamId,
                    @"audioTracks": audioTracks,
                    @"videoTracks": videoTracks,
                    });
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream {
    NSArray *keysArray = [peerConnection.remoteStreams allKeysForObject:stream];
    // We assume there can be only one object for 1 key
    if (keysArray.count > 1) {
        NSLog(@"didRemoveStream - more than one stream entry found for stream instance with id: %@", stream.streamId);
    }
    NSString *streamId = stream.streamId;
    
    for (RTCVideoTrack *track in stream.videoTracks) {
        [peerConnection.remoteTracks removeObjectForKey:track.trackId];
    }
    for (RTCAudioTrack *track in stream.audioTracks) {
        [peerConnection.remoteTracks removeObjectForKey:track.trackId];
    }
    [peerConnection.remoteStreams removeObjectForKey:streamId];
    
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"onRemoveStream",
                    @"streamId": streamId,
                    });
    }
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{@"event" : @"onRenegotiationNeeded",});
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"iceConnectionState",
                    @"state" : [self stringForICEConnectionState:newState]
                    });
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"iceGatheringState",
                    @"state" : [self stringForICEGatheringState:newState]
                    });
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"onCandidate",
                    @"candidate" : @{@"candidate": candidate.sdp, @"sdpMLineIndex": @(candidate.sdpMLineIndex), @"sdpMid": candidate.sdpMid}
                    });
    }
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel {
    if (-1 == dataChannel.channelId) {
        return;
    }

    NSNumber *dataChannelId = [NSNumber numberWithInteger:dataChannel.channelId];
    dataChannel.peerConnectionId = peerConnection.flutterId;
    dataChannel.delegate = self;
    peerConnection.dataChannels[dataChannelId] = dataChannel;
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel
                                         eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/dataChannelEvent%d", dataChannel.channelId]
                                         binaryMessenger:self.messenger];
    
    dataChannel.eventChannel = eventChannel;
    dataChannel.flutterChannelId = dataChannelId;
    [eventChannel setStreamHandler:dataChannel];
    
    FlutterEventSink eventSink = peerConnection.eventSink;
    if(eventSink){
        eventSink(@{
                    @"event" : @"didOpenDataChannel",
                    @"id": dataChannelId,
                    @"label": dataChannel.label
                    });
    }
}

@end

