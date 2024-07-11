#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@interface CustomCapturerDelegate : NSObject <RTCVideoCapturerDelegate>

@property (nonatomic, strong) RTCVideoSource *videoSource;

- (instancetype)initWithVideoSource:(RTCVideoSource *)videoSource;

@end