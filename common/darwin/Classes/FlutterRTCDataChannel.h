#import "FlutterWebRTCPlugin.h"

@interface RTCDataChannel (Flutter) <FlutterStreamHandler>
@property(nonatomic, strong, nonnull) NSString* peerConnectionId;
@property(nonatomic, strong, nonnull) NSString* flutterChannelId;
@property(nonatomic, strong, nullable) FlutterEventSink eventSink;
@property(nonatomic, strong, nullable) FlutterEventChannel* eventChannel;
@property(nonatomic, strong, nullable) NSArray<id>* eventQueue;
@end

@interface FlutterWebRTCPlugin (RTCDataChannel) <RTCDataChannelDelegate>

- (void)createDataChannel:(nonnull NSString*)peerConnectionId
                    label:(nonnull NSString*)label
                   config:(nonnull RTCDataChannelConfiguration*)config
                messenger:(nonnull NSObject<FlutterBinaryMessenger>*)messenger
                   result:(nonnull FlutterResult)result;

- (void)dataChannelClose:(nonnull NSString*)peerConnectionId
           dataChannelId:(nonnull NSString*)dataChannelId;

- (void)dataChannelSend:(nonnull NSString*)peerConnectionId
          dataChannelId:(nonnull NSString*)dataChannelId
                   data:(nonnull NSString*)data
                   type:(nonnull NSString*)type;

- (void)dataChannelGetBufferedAmount:(nonnull NSString*)peerConnectionId
          dataChannelId:(nonnull NSString*)dataChannelId 
                result:(nonnull FlutterResult)result;
@end
