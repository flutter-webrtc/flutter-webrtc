#import "WebRTCService.h"

@implementation WebRTCService

// Static variable for the singleton instance
static WebRTCService *instance = nil;

// Private initializer to prevent instantiation from outside
- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        NSLog(@"WebRTCService instance created");
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
- (void)setProcessor:(Processor *)processor {
    _processor = processor;
    NSLog(@"Processor Set successfully");
}

// Method to get the current Processor
- (Processor *)getProcessor {
    return _processor;
}

@end