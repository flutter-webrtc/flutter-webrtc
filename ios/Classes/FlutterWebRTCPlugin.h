#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

#import <WebRTC/RTCDataChannel.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCDataChannel.h>
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <WebRTC/RTCMediaStreamTrack.h>

@class RTCVideoView;

@interface FlutterWebRTCPlugin : NSObject<FlutterPlugin, RTCPeerConnectionDelegate>

@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCPeerConnection *> *peerConnections;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStream *> *localStreams;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCMediaStreamTrack *> *localTracks;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, RTCVideoView *> *renders;
@property (nonatomic, retain) UIViewController *viewController;

- (RTCMediaStream*)streamForId:(NSString*)streamId;

@end
