#import <TargetConditionals.h>

#if TARGET_OS_IPHONE

#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterRTCPictureInPictureStateHandler)(NSString* state,
                                                       NSString* _Nullable error);

API_AVAILABLE(ios(15.0))
@interface FlutterRTCPictureInPictureController
    : NSObject <RTCVideoRenderer, AVPictureInPictureControllerDelegate>

@property(nonatomic, strong, nullable) RTCVideoTrack* videoTrack;
@property(nonatomic, copy, nullable) FlutterRTCPictureInPictureStateHandler stateHandler;

+ (BOOL)isSupported;

/// Returns a transparent view positioned at `frame` inside `rootView`, to be
/// used as the source view when the video is drawn by a Flutter texture.
- (UIView*)anchorViewInView:(UIView*)rootView frame:(CGRect)frame;

- (void)configureWithSourceView:(UIView*)sourceView
                    aspectRatio:(CGFloat)aspectRatio
                      autoEnter:(BOOL)autoEnter
                   videoGravity:(AVLayerVideoGravity)videoGravity;

- (BOOL)start;
- (void)stop;
- (BOOL)isActive;
- (void)dispose;

@end

NS_ASSUME_NONNULL_END

#endif
