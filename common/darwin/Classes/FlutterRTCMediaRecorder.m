#import <WebRTC/WebRTC.h>
#import "FlutterRTCMediaRecorder.h"
#import "FlutterRTCAudioSink.h"
#import "FlutterRTCFrameCapturer.h"

@import AVFoundation;

@implementation FlutterRTCMediaRecorder {
    int framesCount;
    bool isInitialized;
    CGSize _renderSize;
    RTCVideoRotation _rotation;
    FlutterRTCAudioSink* _audioSink;
    AVAssetWriterInput* _audioWriter;
    int _additionalRotation;
    int64_t _startTime;
}

- (instancetype)initWithVideoTrack:(RTCVideoTrack *)video rotationDegrees:(NSNumber *)rotation audioTrack:(RTCAudioTrack *)audio outputFile:(NSURL *)out {
    self = [super init];
    _rotation = -1;
    isInitialized = false;
    self.videoTrack = video;
    self.output = out;
    _additionalRotation = rotation.intValue;
    [video addRenderer:self];
    framesCount = 0;
    if (audio != nil)
        _audioSink = [[FlutterRTCAudioSink alloc] initWithAudioTrack:audio];
    else
        NSLog(@"Audio track is nil");
    _startTime = -1;
    return self;
}

- (void)changeVideoTrack:(RTCVideoTrack *)track {
    if (self.videoTrack) {
        [self.videoTrack removeRenderer:self];
    }
    self.videoTrack = track;
    [track addRenderer:self];
}

- (void)initialize:(CGSize)size {
    _renderSize = size;
    NSDictionary *videoSettings = @{
        AVVideoCompressionPropertiesKey: @{AVVideoAverageBitRateKey: @(6*1024*1024)},
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoHeightKey: @(size.height),
        AVVideoWidthKey: @(size.width),
    };
    self.writerInput = [[AVAssetWriterInput alloc]
            initWithMediaType:AVMediaTypeVideo
               outputSettings:videoSettings];
    self.writerInput.expectsMediaDataInRealTime = true;
    self.writerInput.mediaTimeScale = 30;
    int rotationDegrees = _additionalRotation;
    switch (_rotation) {
        case RTCVideoRotation_0: break;
        case RTCVideoRotation_90: rotationDegrees += 90; break;
        case RTCVideoRotation_180: rotationDegrees += 180; break;
        case RTCVideoRotation_270: rotationDegrees += 270; break;
        default: break;
    }
    rotationDegrees %= 360;
    self.writerInput.transform = CGAffineTransformMakeRotation(M_PI * rotationDegrees / 180);
    
    if (_audioSink != nil) {
        AudioChannelLayout acl;
        bzero(&acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        NSDictionary* audioSettings = @{
            AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatMPEG4AAC],
            AVNumberOfChannelsKey: @1,
            AVSampleRateKey: @44100.0,
            AVChannelLayoutKey: [NSData dataWithBytes:&acl length:sizeof(AudioChannelLayout)],
            AVEncoderBitRateKey: @64000,
        };
        _audioWriter = [[AVAssetWriterInput alloc]
                        initWithMediaType:AVMediaTypeAudio
                        outputSettings:audioSettings
                        sourceFormatHint:_audioSink.format];
        _audioWriter.expectsMediaDataInRealTime = true;
    }
    
    NSError *error;
    self.assetWriter = [[AVAssetWriter alloc]
            initWithURL:self.output
               fileType:AVFileTypeMPEG4
                  error:&error];
    if (error != nil)
        NSLog(@"%@",[error localizedDescription]);
    self.assetWriter.shouldOptimizeForNetworkUse = true;
    [self.assetWriter addInput:self.writerInput];
    if (_audioWriter != nil) {
        [self.assetWriter addInput:_audioWriter];
        _audioSink.bufferCallback = ^(CMSampleBufferRef buffer){
            if (self->_audioWriter.readyForMoreMediaData) {
                if ([self->_audioWriter appendSampleBuffer:buffer])
                    NSLog(@"Audio frame appended");
                else
                    NSLog(@"Audioframe not appended %@", self.assetWriter.error);
            }
        };
    }
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    isInitialized = true;
}

- (void)setSize:(CGSize)size {
}

- (void)renderFrame:(nullable RTCVideoFrame *)frame {
    if (frame == nil) {
        return;
    }
    if (!isInitialized) {
        _rotation = frame.rotation;
        [self initialize:CGSizeMake((CGFloat) frame.width, (CGFloat) frame.height)];
    }
    if (!self.writerInput.readyForMoreMediaData) {
        NSLog(@"Drop frame, not ready");
        return;
    }
    id <RTCVideoFrameBuffer> buffer = frame.buffer;
    CVPixelBufferRef pixelBufferRef;
    BOOL shouldRelease = false;
    if ([buffer isKindOfClass:[RTCCVPixelBuffer class]]) {
        pixelBufferRef = ((RTCCVPixelBuffer *) buffer).pixelBuffer;
    } else {
        pixelBufferRef = [FlutterRTCFrameCapturer convertToCVPixelBuffer:frame];
        shouldRelease = true;
    }
    CMVideoFormatDescriptionRef formatDescription;
    OSStatus status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBufferRef, &formatDescription);

    CMSampleTimingInfo timingInfo;
    
    timingInfo.decodeTimeStamp = kCMTimeInvalid;
    if (_startTime == -1) {
        _startTime = frame.timeStampNs / 1000;
    }
    int64_t frameTime = (frame.timeStampNs / 1000) - _startTime;
    timingInfo.presentationTimeStamp = CMTimeMake(frameTime, 1000000);
    framesCount++;

    CMSampleBufferRef outBuffer;

    status = CMSampleBufferCreateReadyWithImageBuffer(
        kCFAllocatorDefault,
        pixelBufferRef,
        formatDescription,
        &timingInfo,
        &outBuffer
    );

    if (![self.writerInput appendSampleBuffer:outBuffer]) {
        NSLog(@"Frame not appended %@", self.assetWriter.error);
    }
    #if TARGET_OS_IPHONE
    if (shouldRelease) {
        CVPixelBufferRelease(pixelBufferRef);
    }
    #endif
}

- (void)stop:(FlutterResult _Nonnull) result {
    if (_audioSink != nil) {
        _audioSink.bufferCallback = nil;
        [_audioSink close];
    }
    [self.videoTrack removeRenderer:self];
    [self.writerInput markAsFinished];
    [_audioWriter markAsFinished];
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.assetWriter finishWritingWithCompletionHandler:^{
           NSError* error = self.assetWriter.error;
           if (error == nil) {
               result(nil);
           } else {
               result([FlutterError errorWithCode:@"Failed to save recording"
                                          message:[error localizedDescription]
                                          details:nil]);
           }
       }];
    });
}

@end
