
#import <Foundation/Foundation.h>
#import "VideoProcessor.h" // Import Processor header file

@interface WebRTCService : NSObject

@property (nonatomic, strong) VideoProcessor *videoProcessor;

// Singleton instance method
+ (instancetype)sharedInstance;

// Method to set the Processor
- (void)setVideoProcessor:(VideoProcessor *)videoProcessor;

// Method to get the current Processor
- (VideoProcessor *)getVideoProcessor;

@end