#import "WebRTCService.h"

@implementation WebRTCService

// Static variable for the singleton instance
static WebRTCService *instance = nil;

// Private initializer to prevent instantiation from outside
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        // Initialization logic if any
    }
    return self;
}

// Singleton instance method
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    return instance;
}

// Method to set the Processor
- (void)setVideoProcessor:(VideoProcessor *)videoProcessor {
    _videoProcessor = videoProcessor;
}

// Method to get the current Processor
- (VideoProcessor *)getVideoProcessor {
    return _videoProcessor;
}

@end