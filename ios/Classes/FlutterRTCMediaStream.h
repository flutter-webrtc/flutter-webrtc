#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (RTCMediaStream)

-(void)getUserMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;

-(void)getDisplayMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;

-(void)getSources:(FlutterResult)result;

-(void)mediaStreamTrackSwitchCamera:(RTCMediaStreamTrack *)track
                             result:(FlutterResult) result;

-(void)mediaStreamTrackCaptureFrame:(RTCMediaStreamTrack *)track
                             toPath:(NSString *) path
                             result:(FlutterResult) result;
@end
