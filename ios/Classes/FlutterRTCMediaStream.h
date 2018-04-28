#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

@interface RTCMediaStream (Flutter)
@property (nonatomic, strong) FlutterEventSink eventSink;
@end

@interface FlutterWebRTCPlugin (RTCMediaStream)

-(void)getUserMedia:(NSDictionary *)constraints
             result:(FlutterResult)result;
@end


