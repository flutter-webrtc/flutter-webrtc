#import <Foundation/Foundation.h>
#import <WebRTC/RTCVideoFrame.h> // Include necessary headers for Processor

// Define Processor class
@interface Processor : NSObject

// Declare any properties and methods needed
- (RTCVideoFrame *)applyEffect:(RTCVideoFrame *)frame;

@end