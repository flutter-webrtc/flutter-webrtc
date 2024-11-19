#import "VideoProcessingAdapter.h"
#import <os/lock.h>

@implementation VideoProcessingAdapter {
    RTCVideoSource* _videoSource;
    CGSize _frameSize;
    NSArray<id<ExternalVideoFrameProcessing>> *_processors;
    os_unfair_lock _lock;
}

- (instancetype)initWithRTCVideoSource:(RTCVideoSource *)source {
    self = [super init];
    if (self) {
        _lock = OS_UNFAIR_LOCK_INIT;
        _videoSource = source;
        _processors = [NSArray<id<ExternalVideoFrameProcessing>> new];
    }
    return self;
}

-(void)addProcessing:(id<ExternalVideoFrameProcessing>)processor {
    os_unfair_lock_lock(&_lock);
    _processors = [_processors arrayByAddingObject:processor];
    os_unfair_lock_unlock(&_lock);
}

-(void)removeProcessing:(id<ExternalVideoFrameProcessing>)processor {
    os_unfair_lock_lock(&_lock);
    _processors = [_processors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != processor;
    }]];
    os_unfair_lock_unlock(&_lock);
}

- (void)setSize:(CGSize)size {
    _frameSize = size;
}

-(void)capturer : (RTC_OBJC_TYPE(RTCVideoCapturer) *)capturer didCaptureVideoFrame
                : (RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
    os_unfair_lock_lock(&_lock);
    for (id<ExternalVideoFrameProcessing> processor in _processors) {
        [processor processVideoFrame:frame];
    }
    [_videoSource capturer:capturer didCaptureVideoFrame:frame];
    os_unfair_lock_unlock(&_lock);
}

@end
