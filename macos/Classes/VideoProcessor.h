#import <Foundation/Foundation.h>
#import <WebRTC/RTCVideoFrame.h> 

// Define Processor class
@interface VideoProcessor : NSObject

// Declare any properties and methods needed
- (RTCVideoFrame *)onFrameReceived:(RTCVideoFrame *)frame;

@end