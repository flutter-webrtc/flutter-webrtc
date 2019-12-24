#import <objc/runtime.h>
#import "FlutterRTCDataChannel.h"
#import "FlutterRTCPeerConnection.h"
#import <WebRTC/RTCDataChannelConfiguration.h>

@implementation RTCDataChannel (Flutter)

- (NSString *)peerConnectionId
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPeerConnectionId:(NSString *)peerConnectionId
{
    objc_setAssociatedObject(self, @selector(peerConnectionId), peerConnectionId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventSink )eventSink
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventSink:(FlutterEventSink)eventSink
{
    objc_setAssociatedObject(self, @selector(eventSink), eventSink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)flutterChannelId
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlutterChannelId:(NSNumber *)flutterChannelId
{
    objc_setAssociatedObject(self, @selector(flutterChannelId), flutterChannelId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FlutterEventChannel *)eventChannel
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventChannel:(FlutterEventChannel *)eventChannel
{
    objc_setAssociatedObject(self, @selector(eventChannel), eventChannel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

@implementation FlutterWebRTCPlugin (RTCDataChannel)

-(void)createDataChannel:(nonnull NSString *)peerConnectionId
                              label:(NSString *)label
                             config:(RTCDataChannelConfiguration *)config
               messenger:(NSObject<FlutterBinaryMessenger>*)messenger
{
    RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
    RTCDataChannel *dataChannel = [peerConnection dataChannelForLabel:label configuration:config];
    
    if (nil != dataChannel) {
        dataChannel.peerConnectionId = peerConnectionId;
        NSNumber *dataChannelId = [NSNumber numberWithInteger:config.channelId];
        peerConnection.dataChannels[dataChannelId] = dataChannel;
        dataChannel.flutterChannelId = dataChannelId;
        dataChannel.delegate = self;
        
        FlutterEventChannel *eventChannel = [FlutterEventChannel
                                             eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/dataChannelEvent%d", [dataChannelId intValue]]
                                             binaryMessenger:messenger];
        
        dataChannel.eventChannel = eventChannel;
        [eventChannel setStreamHandler:dataChannel];
    }
}

-(void)dataChannelClose:(nonnull NSString *)peerConnectionId
                     dataChannelId:(nonnull NSString *)dataChannelId
{
    RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
    NSMutableDictionary *dataChannels = peerConnection.dataChannels;
    RTCDataChannel *dataChannel = dataChannels[dataChannelId];
    FlutterEventChannel *eventChannel  = dataChannel.eventChannel;
    [eventChannel setStreamHandler:nil];
    dataChannel.eventChannel = nil;
    [dataChannel close];
    [dataChannels removeObjectForKey:dataChannelId];
}

-(void)dataChannelSend:(nonnull NSString *)peerConnectionId
                    dataChannelId:(nonnull NSString *)dataChannelId
                             data:(id)data
                             type:(NSString *)type
{
    RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
    RTCDataChannel *dataChannel = peerConnection.dataChannels[dataChannelId];
    
    NSData *bytes = [type isEqualToString:@"binary"] ?
    ((FlutterStandardTypedData*)data).data :
    [data dataUsingEncoding:NSUTF8StringEncoding];
    
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:bytes isBinary:[type isEqualToString:@"binary"]];
    [dataChannel sendData:buffer];
}

- (NSString *)stringForDataChannelState:(RTCDataChannelState)state
{
  switch (state) {
    case RTCDataChannelStateConnecting: return @"connecting";
    case RTCDataChannelStateOpen: return @"open";
    case RTCDataChannelStateClosing: return @"closing";
    case RTCDataChannelStateClosed: return @"closed";
  }
  return nil;
}

#pragma mark - RTCDataChannelDelegate methods

// Called when the data channel state has changed.
- (void)dataChannelDidChangeState:(RTCDataChannel*)channel
{
    RTCPeerConnection *peerConnection = self.peerConnections[channel.peerConnectionId];
    FlutterEventSink eventSink = channel.eventSink;
    if(eventSink) {
        eventSink(@{ @"event" : @"dataChannelStateChanged",
                     @"id": channel.flutterChannelId,
                     @"state": [self stringForDataChannelState:channel.readyState]});
    }
}

// Called when a data buffer was successfully received.
- (void)dataChannel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    NSString *type;
    id data;
    if (buffer.isBinary) {
        type = @"binary";
        data = [FlutterStandardTypedData typedDataWithBytes:buffer.data];
    } else {
        type = @"text";
        data = [[NSString alloc] initWithData:buffer.data
                                     encoding:NSUTF8StringEncoding];
    }
    RTCPeerConnection *peerConnection = self.peerConnections[channel.peerConnectionId];
    FlutterEventSink eventSink = channel.eventSink;
    if(eventSink) {
        eventSink(@{ @"event" : @"dataChannelReceiveMessage",
                     @"id": channel.flutterChannelId,
                     @"type": type,
                     @"data": (data ? data : [NSNull null])});
    }
}

@end
