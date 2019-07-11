#import "FlutterWebRTCPlugin.h"
#import <WebRTC/RTCDataChannel.h>

@interface RTCDataChannel (Flutter) <FlutterStreamHandler>
@property (nonatomic, strong) NSString *peerConnectionId;
@property (nonatomic, strong) NSNumber *flutterChannelId;
@property (nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) FlutterEventChannel* eventChannel;
@end

@interface FlutterWebRTCPlugin (RTCDataChannel) <RTCDataChannelDelegate>


-(void)createDataChannel:(nonnull NSString *)peerConnectionId
                   label:(nonnull NSString *)label
                  config:(nonnull RTCDataChannelConfiguration *)config
               messenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(void)dataChannelClose:(nonnull NSString *)peerConnectionId
          dataChannelId:(nonnull NSString *)dataChannelId;


-(void)dataChannelSend:(nonnull NSString *)peerConnectionId
         dataChannelId:(nonnull NSString *)dataChannelId
                  data:(nonnull NSString *)data
                  type:(nonnull NSString *)type;

@end
