#import <Foundation/Foundation.h>
#import "Processor.h" // Import Processor header file

@interface WebRTCService : NSObject

@property (nonatomic, strong) Processor *processor;

// Singleton instance method
+ (instancetype)sharedInstance;

// Method to set the Processor
- (void)setProcessor:(Processor *)processor;

// Method to get the current Processor
- (Processor *)getProcessor;

@end
