#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (RTCMediaStream)

-(void)getUserMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;
#if TARGET_OS_IPHONE
-(void)getDisplayMedia:(NSDictionary *)constraints
                result:(FlutterResult)result;
#endif
-(void)createLocalMediaStream:(FlutterResult)result;

-(void)getSources:(FlutterResult)result;

-(void)mediaStreamTrackHasTorch:(RTCMediaStreamTrack *)track
                         result:(FlutterResult) result;

-(void)mediaStreamTrackSetTorch:(RTCMediaStreamTrack *)track
                          torch:(BOOL) torch
                         result:(FlutterResult) result;

-(void)mediaStreamTrackSwitchCamera:(RTCMediaStreamTrack *)track
                             result:(FlutterResult) result;

-(void)mediaStreamTrackCaptureFrame:(RTCMediaStreamTrack *)track
                             toPath:(NSString *) path
                             result:(FlutterResult) result;

-(void)mediaStreamTrackStartRecordToPath:(NSString *) path
                              videoTrack:(RTCVideoTrack *)track
                              audioTrack:(RTCVideoTrack *)track
                              recorderId:(int) recorderId
                                  result:(FlutterResult) result;

-(void)mediaStreamTrackStopRecordToPath:(int) recorderId
                                 result:(FlutterResult) result;
@end
