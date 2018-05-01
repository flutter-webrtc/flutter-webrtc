#import "FlutterWebRTCPlugin.h"
#import <WebRTC/RTCDataChannel.h>

@interface RTCDataChannel (Flutter)

@property (nonatomic, strong) NSString *peerConnectionId;

@end

@interface FlutterWebRTCPlugin (RTCDataChannel) <RTCDataChannelDelegate>


-(void)createDataChannel:(nonnull NSString *)peerConnectionId
                   label:(nonnull NSString *)label
                  config:(nonnull RTCDataChannelConfiguration *)config;

-(void)dataChannelClose:(nonnull NSString *)peerConnectionId
          dataChannelId:(nonnull NSString *)dataChannelId;


-(void)dataChannelSend:(nonnull NSString *)peerConnectionId
         dataChannelId:(nonnull NSString *)dataChannelId
                  data:(nonnull NSString *)data
                  type:(nonnull NSString *)type;

@end
