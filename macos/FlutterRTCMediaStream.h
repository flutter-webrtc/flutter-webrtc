#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (RTCMediaStream)

-(void)getUserMedia:(NSDictionary *)constraints
             result:(FLEMethodResult)result;

-(void)getSources:(FLEMethodResult)result;

-(void)mediaStreamTrackSwitchCamera:(RTCMediaStreamTrack *)track;
@end


