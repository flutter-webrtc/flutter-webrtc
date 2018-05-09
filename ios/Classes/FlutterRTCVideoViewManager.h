#import "FlutterWebRTCPlugin.h"

#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCVideoFrame.h>
#import <WebRTC/RTCVideoTrack.h>

/**
 * In the fashion of
 * https://www.w3.org/TR/html5/embedded-content-0.html#dom-video-videowidth
 * and https://www.w3.org/TR/html5/rendering.html#video-object-fit, resembles
 * the CSS style {@code object-fit}.
 */
typedef NS_ENUM(NSInteger, RTCVideoViewObjectFit) {
    /**
     * The contain value defined by https://www.w3.org/TR/css3-images/#object-fit:
     *
     * The replaced content is sized to maintain its aspect ratio while fitting
     * within the element's content box.
     */
    RTCVideoViewObjectFitContain,
    /**
     * The cover value defined by https://www.w3.org/TR/css3-images/#object-fit:
     *
     * The replaced content is sized to maintain its aspect ratio while filling
     * the element's entire content box.
     */
    RTCVideoViewObjectFitCover
};

/**
 * Implements an equivalent of {@code HTMLVideoElement} i.e. Web's video
 * element.
 */
@interface RTCVideoView : NSObject <FlutterTexture, RTCVideoRenderer, RTCEAGLVideoViewDelegate>

/**
 * The indicator which determines whether this {@code RTCVideoView} is to mirror
 * the video specified by {@link #videoTrack} during its rendering. Typically,
 * applications choose to mirror the front/user-facing camera.
 */
@property (nonatomic) BOOL mirror;

/**
 * In the fashion of
 * https://www.w3.org/TR/html5/embedded-content-0.html#dom-video-videowidth
 * and https://www.w3.org/TR/html5/rendering.html#video-object-fit, resembles
 * the CSS style {@code object-fit}.
 */
@property (nonatomic) RTCVideoViewObjectFit objectFit;

/**
 * The {@link RTCVideoTrack}, if any, which this instance renders.
 */
@property (nonatomic, strong) RTCVideoTrack *videoTrack;
@property (copy, nonatomic) void(^onNewFrame)(void);

- (instancetype)initWithSize:(CGSize)renderSize;

- (void)dispose;

@end


@interface FlutterWebRTCPlugin (RTCVideoViewManager)

- (RTCVideoView *)createWithSize:(CGSize)size onNewFrame:(void(^)(void))onNewFrame;

-(void)setStreamId:(NSString*)streamId view:(RTCVideoView*)view;

@end
