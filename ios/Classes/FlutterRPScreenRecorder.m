#import "FlutterRPScreenRecorder.h"
#import <ReplayKit/ReplayKit.h>

//See: https://developer.apple.com/videos/play/wwdc2017/606/

@implementation FlutterRPScreenRecorder {
	RPScreenRecorder *screenRecorder;
	RTCVideoSource *source;
}

- (instancetype)initWithDelegate:(__weak id<RTCVideoCapturerDelegate>)delegate {
    source = delegate;
    return [super initWithDelegate:delegate];
}

-(void)startCapture
{
    if(screenRecorder == NULL)
        screenRecorder = [RPScreenRecorder sharedRecorder];
    
	[screenRecorder setMicrophoneEnabled:NO];

	if (![screenRecorder isAvailable]) {
		NSLog(@"Screen recorder is not available!");
		return;
	}
	
	[screenRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
        if (bufferType == RPSampleBufferTypeVideo) {// We want video only now
			[self handleSourceBuffer:sampleBuffer sampleType:bufferType];
		}
	} completionHandler:^(NSError * _Nullable error) {
		if (error != nil)
            NSLog(@"!!! startCaptureWithHandler/completionHandler %@ !!!", error);
	}];
}

-(void)stopCapture
{
	[screenRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
        if (error != nil)
            NSLog(@"!!! stopCaptureWithHandler/completionHandler %@ !!!", error);
	}];
}

-(void)handleSourceBuffer:(CMSampleBufferRef)sampleBuffer sampleType:(RPSampleBufferType)sampleType
{
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
        !CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return;
    }
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);

    [source adaptOutputFormatToWidth:width/2 height:height/2 fps:8];
    
    RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
    int64_t timeStampNs =
    CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * NSEC_PER_SEC;
    RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
                                                             rotation:RTCVideoRotation_0
                                                          timeStampNs:timeStampNs];
    [self.delegate capturer:self didCaptureVideoFrame:videoFrame];
}

@end
