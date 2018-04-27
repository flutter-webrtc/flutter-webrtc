#import <objc/runtime.h>
#import "FlutterRTCDataChannel.h"
#import "FlutterRTCPeerConnection.h"
#import <WebRTC/RTCDataChannelConfiguration.h>

@implementation RTCDataChannel (Flutter)

- (NSNumber *)peerConnectionId
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPeerConnectionId:(NSNumber *)peerConnectionId
{
    objc_setAssociatedObject(self, @selector(peerConnectionId), peerConnectionId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FlutterWebRTCPlugin (RTCDataChannel)

-(void)createDataChannel:(nonnull NSNumber *)peerConnectionId
                              label:(NSString *)label
                             config:(RTCDataChannelConfiguration *)config
{
  RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
  RTCDataChannel *dataChannel = [peerConnection dataChannelForLabel:label configuration:config];
  // XXX RTP data channels are not defined by the WebRTC standard, have been
  // deprecated in Chromium, and Google have decided (in 2015) to no longer
  // support them (in the face of multiple reported issues of breakages).
  if (-1 != dataChannel.channelId) {
    //dataChannel.peerConnectionId = peerConnectionId;
    NSNumber *dataChannelId = [NSNumber numberWithInteger:dataChannel.channelId];
    self.dataChannels[dataChannelId] = dataChannel;
    dataChannel.delegate = self;
  }
}

-(void)dataChannelClose:(nonnull NSNumber *)peerConnectionId
                     dataChannelId:(nonnull NSNumber *)dataChannelId
{
  RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
  NSMutableDictionary *dataChannels = self.dataChannels;
  RTCDataChannel *dataChannel = dataChannels[dataChannelId];
  [dataChannel close];
  [dataChannels removeObjectForKey:dataChannelId];
}

-(void)dataChannelSend:(nonnull NSNumber *)peerConnectionId
                    dataChannelId:(nonnull NSNumber *)dataChannelId
                             data:(NSString *)data
                             type:(NSString *)type
{
  RTCPeerConnection *peerConnection = self.peerConnections[peerConnectionId];
  RTCDataChannel *dataChannel = self.dataChannels[dataChannelId];
  NSData *bytes = [type isEqualToString:@"binary"] ?
    [[NSData alloc] initWithBase64EncodedString:data options:0] :
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
  NSDictionary *event = @{@"id": @(channel.channelId),
                          @"peerConnectionId": channel.peerConnectionId,
                          @"state": [self stringForDataChannelState:channel.readyState]};

    if(_eventSink) {
        _eventSink(@{ @"event" : @"dataChannelStateChanged", @"body": event, });
    }
}

// Called when a data buffer was successfully received.
- (void)dataChannel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
  NSString *type;
  NSString *data;
  if (buffer.isBinary) {
    type = @"binary";
    data = [buffer.data base64EncodedStringWithOptions:0];
  } else {
    type = @"text";
    // XXX NSData has a length property which means that, when it represents
    // text, the value of its bytes property does not have to be terminated by
    // null. In such a case, NSString's stringFromUTF8String may fail and return
    // nil (which would crash the process when inserting data into NSDictionary
    // without the nil protection implemented below).
    data = [[NSString alloc] initWithData:buffer.data
                                 encoding:NSUTF8StringEncoding];
  }
  NSDictionary *event = @{@"id": @(channel.channelId),
                          @"peerConnectionId": channel.peerConnectionId,
                          @"type": type,
                          // XXX NSDictionary will crash the process upon
                          // attempting to insert nil. Such behavior is
                          // unacceptable given that protection in such a
                          // scenario is extremely simple.
                          @"data": (data ? data : [NSNull null])};

    if(_eventSink) {
        _eventSink(@{ @"event" : @"dataChannelReceiveMessage", @"body": event, });
    }
}

@end
