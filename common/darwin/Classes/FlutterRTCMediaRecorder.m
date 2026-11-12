#import <WebRTC/WebRTC.h>
#import "FlutterRTCMediaRecorder.h"
#import "FlutterRTCAudioSink.h"
#import "FlutterRTCFrameCapturer.h"

@import AVFoundation;

@implementation FlutterRTCMediaRecorder {
    int framesCount;
    int audioFramesCount;
    bool isInitialized;
    bool isStopping;
    CGSize _renderSize;
    FlutterRTCAudioSink* _audioSink;
    AVAssetWriterInput* _audioWriter;
    int64_t _startTime;
    int64_t _lastFrameTime;
}

- (instancetype)initWithVideoTrack:(RTCVideoTrack *)video audioTrack:(RTCAudioTrack *)audio outputFile:(NSURL *)out {
    self = [super init];
    isInitialized = false;
    isStopping = false;
    self.videoTrack = video;
    self.output = out;
    [video addRenderer:self];
    framesCount = 0;
    audioFramesCount = 0;
    if (audio != nil)
        _audioSink = [[FlutterRTCAudioSink alloc] initWithAudioTrack:audio];
    else
        NSLog(@"[FlutterRTCMediaRecorder] Audio track is nil");
    _startTime = -1;
    _lastFrameTime = -1;
    return self;
}

- (void)initialize:(CGSize)size {
    int width = ((int)round(size.width)) & ~1;
    int height = ((int)round(size.height)) & ~1;
    if (width <= 0) width = 1280;
    if (height <= 0) height = 720;
    _renderSize = CGSizeMake(width, height);

    NSDictionary *videoSettings = @{
        AVVideoCompressionPropertiesKey: @{AVVideoAverageBitRateKey: @(6*1024*1024)},
        AVVideoCodecKey: AVVideoCodecTypeH264,
        AVVideoHeightKey: [NSNumber numberWithInt:height],
        AVVideoWidthKey: [NSNumber numberWithInt:width],
    };
    self.writerInput = [[AVAssetWriterInput alloc]
            initWithMediaType:AVMediaTypeVideo
               outputSettings:videoSettings];
    self.writerInput.expectsMediaDataInRealTime = true;
    self.writerInput.mediaTimeScale = 30;

    if (_audioSink != nil) {
        UInt32 channels = 1;
        if (_audioSink.format != NULL) {
            const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(_audioSink.format);
            if (asbd && asbd->mChannelsPerFrame > 0) {
                channels = asbd->mChannelsPerFrame;
            }
        }
        if (channels > 2) channels = 2;
        if (channels < 1) channels = 1;

        NSLog(@"[FlutterRTCMediaRecorder] Initializing AAC audio writer: sampleRate=48000, channels=%u", (unsigned int)channels);

        NSDictionary* audioSettings = @{
            AVFormatIDKey: [NSNumber numberWithInt: kAudioFormatMPEG4AAC],
            AVNumberOfChannelsKey: [NSNumber numberWithUnsignedInt: channels],
            AVSampleRateKey: @(48000.0),
            AVEncoderBitRateKey: [NSNumber numberWithInt: (channels >= 2 ? 128000 : 64000)],
        };

        _audioWriter = [[AVAssetWriterInput alloc]
                        initWithMediaType:AVMediaTypeAudio
                        outputSettings:audioSettings
                        sourceFormatHint:nil];
        _audioWriter.expectsMediaDataInRealTime = true;
    }
    
    NSError *error;
    self.assetWriter = [[AVAssetWriter alloc]
            initWithURL:self.output
               fileType:AVFileTypeMPEG4
                  error:&error];
    if (error != nil) {
        NSLog(@"[FlutterRTCMediaRecorder] AssetWriter init error: %@", [error localizedDescription]);
    }
    self.assetWriter.shouldOptimizeForNetworkUse = true;

    if ([self.assetWriter canAddInput:self.writerInput]) {
        [self.assetWriter addInput:self.writerInput];
    } else {
        NSLog(@"[FlutterRTCMediaRecorder] Cannot add video writerInput!");
    }

    if (_audioWriter != nil) {
        if ([self.assetWriter canAddInput:_audioWriter]) {
            [self.assetWriter addInput:_audioWriter];
        } else {
            NSLog(@"[FlutterRTCMediaRecorder] Cannot add _audioWriter input!");
        }
    }

    if (![self.assetWriter startWriting]) {
        NSLog(@"[FlutterRTCMediaRecorder] startWriting failed! Status: %ld, error: %@", (long)self.assetWriter.status, self.assetWriter.error);
    } else {
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    }
    
    if (_audioWriter != nil && _audioSink != nil) {
        __weak typeof(self) weakSelf = self;
        _audioSink.bufferCallback = ^(CMSampleBufferRef buffer){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || strongSelf->isStopping) return;

            AVAssetWriter *writer = strongSelf.assetWriter;
            AVAssetWriterInput *audioIn = strongSelf->_audioWriter;
            if (!writer || !audioIn) return;

            @synchronized(writer) {
                if (writer.status == AVAssetWriterStatusWriting && audioIn.readyForMoreMediaData) {
                    if ([audioIn appendSampleBuffer:buffer]) {
                        strongSelf->audioFramesCount++;
                    } else {
                        NSLog(@"[FlutterRTCMediaRecorder] Audio frame append failed: %@ (userInfo: %@)", writer.error, writer.error.userInfo);
                    }
                }
            }
        };
    }

    isInitialized = true;
}

- (void)setSize:(CGSize)size {
}

- (void)renderFrame:(nullable RTCVideoFrame *)frame {
    if (frame == nil || isStopping) {
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

    if (!isInitialized) {
        size_t pbWidth = CVPixelBufferGetWidth(pixelBufferRef);
        size_t pbHeight = CVPixelBufferGetHeight(pixelBufferRef);
        if (pbWidth > 0 && pbHeight > 0) {
            [self initialize:CGSizeMake((CGFloat)pbWidth, (CGFloat)pbHeight)];
        } else {
            [self initialize:CGSizeMake((CGFloat) frame.width, (CGFloat) frame.height)];
        }
    }
    if (!self.writerInput.readyForMoreMediaData) {
        if (shouldRelease) {
            CVPixelBufferRelease(pixelBufferRef);
        }
        return;
    }
    CMVideoFormatDescriptionRef formatDescription = NULL;
    OSStatus status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBufferRef, &formatDescription);
    
    if (status != noErr || formatDescription == NULL) {
        NSLog(@"Failed to create format description: %d", (int)status);
        if (shouldRelease) {
            CVPixelBufferRelease(pixelBufferRef);
        }
        return;
    }

    if (_startTime == -1) {
        _startTime = frame.timeStampNs / 1000;
    }
    int64_t frameTime = (frame.timeStampNs / 1000) - _startTime;
    if (frameTime < 0) {
        frameTime = 0;
    }
    if (frameTime <= _lastFrameTime && _lastFrameTime >= 0) {
        frameTime = _lastFrameTime + 1000;
    }
    _lastFrameTime = frameTime;

    CMSampleTimingInfo timingInfo = {
        .duration = kCMTimeInvalid,
        .presentationTimeStamp = CMTimeMake(frameTime, 1000000),
        .decodeTimeStamp = kCMTimeInvalid
    };
    framesCount++;

    CMSampleBufferRef outBuffer = NULL;

    status = CMSampleBufferCreateReadyWithImageBuffer(
        kCFAllocatorDefault,
        pixelBufferRef,
        formatDescription,
        &timingInfo,
        &outBuffer
    );

    if (status == noErr && outBuffer != NULL) {
        if (!isStopping) {
            AVAssetWriter *writer = self.assetWriter;
            if (writer != nil) {
                @synchronized(writer) {
                    if (writer.status == AVAssetWriterStatusWriting && self.writerInput.readyForMoreMediaData) {
                        if (![self.writerInput appendSampleBuffer:outBuffer]) {
                            NSLog(@"[FlutterRTCMediaRecorder] Video frame append failed: %@ (userInfo: %@)", writer.error, writer.error.userInfo);
                        }
                    }
                }
            }
        }
    } else {
        NSLog(@"Failed to create sample buffer: %d", (int)status);
    }
    
    if (outBuffer != NULL) {
        CFRelease(outBuffer);
    }
    if (formatDescription != NULL) {
        CFRelease(formatDescription);
    }
    if (shouldRelease) {
        CVPixelBufferRelease(pixelBufferRef);
    }
}

- (void)stop:(FlutterResult _Nonnull) result {
    NSLog(@"[FlutterRTCMediaRecorder] stop requested. Video frames: %d, Audio frames: %d", framesCount, audioFramesCount);
    
    @synchronized(self) {
        if (isStopping) {
            result(nil);
            return;
        }
        isStopping = true;
    }

    // 1. Unbind audio sink callback immediately
    if (_audioSink != nil) {
        _audioSink.bufferCallback = nil;
        FlutterRTCAudioSink *sink = _audioSink;
        _audioSink = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [sink close];
        });
    }

    // 2. Unbind video renderer asynchronously
    if (self.videoTrack != nil) {
        RTCVideoTrack *vTrack = self.videoTrack;
        self.videoTrack = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [vTrack removeRenderer:self];
        });
    }

    __block BOOL hasCompleted = NO;
    void (^completeOnce)(id) = ^(id res) {
        @synchronized(self) {
            if (hasCompleted) return;
            hasCompleted = YES;
        }
        if ([NSThread isMainThread]) {
            result(res);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(res);
            });
        }
    };

    // Safety fallback timeout: guaranteed to return within 5.0 seconds no matter what
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!hasCompleted) {
            NSLog(@"[FlutterRTCMediaRecorder] Safety timer expired; force resolving stop()");
            completeOnce(nil);
        }
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            AVAssetWriter *writer = self.assetWriter;
            if (writer == nil) {
                NSLog(@"[FlutterRTCMediaRecorder] assetWriter is nil (no frames received); completing.");
                completeOnce(nil);
                return;
            }

            @synchronized(writer) {
                if (writer.status != AVAssetWriterStatusWriting) {
                    NSLog(@"[FlutterRTCMediaRecorder] assetWriter status not writing (%ld), error: %@ (userInfo: %@)", (long)writer.status, writer.error, writer.error.userInfo);
                    completeOnce([FlutterError errorWithCode:@"RecordingFailed"
                                                    message:[NSString stringWithFormat:@"Writer failed with status %ld: %@", (long)writer.status, writer.error.localizedDescription]
                                                    details:writer.error.userInfo ? [NSString stringWithFormat:@"%@", writer.error.userInfo] : nil]);
                    return;
                }

                if (self.writerInput != nil) {
                    [self.writerInput markAsFinished];
                }
                if (self->_audioWriter != nil) {
                    [self->_audioWriter markAsFinished];
                }
            }

            NSLog(@"[FlutterRTCMediaRecorder] Finalizing asset writer...");
            [writer finishWritingWithCompletionHandler:^{
                NSLog(@"[FlutterRTCMediaRecorder] finishWriting finished with status: %ld, error: %@ (userInfo: %@)", (long)writer.status, writer.error, writer.error.userInfo);
                if (writer.status == AVAssetWriterStatusCompleted) {
                    completeOnce(nil);
                } else {
                    completeOnce([FlutterError errorWithCode:@"RecordingFailed"
                                                    message:[NSString stringWithFormat:@"finishWriting failed: %@", writer.error.localizedDescription]
                                                    details:writer.error.userInfo ? [NSString stringWithFormat:@"%@", writer.error.userInfo] : nil]);
                }
            }];
        } @catch (NSException *e) {
            NSLog(@"[FlutterRTCMediaRecorder] Exception in stop: %@", e);
            completeOnce([FlutterError errorWithCode:@"RecordingException" message:e.reason details:nil]);
        }
    });
}

@end
