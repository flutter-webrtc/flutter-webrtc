#import "FlutterWebRTCPlugin.h"
#import <WebRTC/RTCDataChannel.h>

@interface RTCDataChannel (Flutter)

@property (nonatomic, strong) NSString *peerConnectionId;

@end

@interface FlutterWebRTCPlugin (RTCDataChannel) <RTCDataChannelDelegate>

@end
