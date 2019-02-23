#import "FlutterWebRTCPlugin.h"

@interface RTCDataChannel (Flutter) <FLEStreamHandler>
@property (nonatomic, strong) NSString *peerConnectionId;
@property (nonatomic, strong) FLEEventSink eventSink;
@property (nonatomic, strong) FLEEventChannel* eventChannel;
@end

@interface FlutterWebRTCPlugin (RTCDataChannel) <RTCDataChannelDelegate>


-(void)createDataChannel:(nonnull NSString *)peerConnectionId
                   label:(nonnull NSString *)label
                  config:(nonnull RTCDataChannelConfiguration *)config
               messenger:(NSObject<FLEBinaryMessenger>*)messenger;

-(void)dataChannelClose:(nonnull NSString *)peerConnectionId
          dataChannelId:(nonnull NSString *)dataChannelId;


-(void)dataChannelSend:(nonnull NSString *)peerConnectionId
         dataChannelId:(nonnull NSString *)dataChannelId
                  data:(nonnull NSString *)data
                  type:(nonnull NSString *)type;

@end
