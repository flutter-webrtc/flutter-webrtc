#import <WebRTC/WebRTC.h>
#import "FlutterRTCMediaRecorder.h"
#import "FlutterRTCAudioSink.h"
#import "FlutterRTCFrameCapturer.h"

@import AVFoundation;

@implementation FlutterRTCMediaRecorder {
    int framesCount;
    bool isInitialized;
    CGSize _renderSize;
    FlutterRTCAudioSink* _audioSink;
    AVAssetWriterInput* _audioWriter;
    int64_t _startTime;
}

- (instancetype)initWithVideoTrack:(RTCVideoTrack *)video audioTrack:(RTCAudioTrack *)audio outputFile:(NSURL *)out {
    self = [super init];
    isInitialized = false;
    self.videoTrack = video;
    self.output = out;
    [video addRenderer:self];
    framesCount = 0;
    if (audio != nil)
        _audioSink = [[FlutterRTCAudioSink alloc] initWithAudioTrack:audio];
    else
        NSLog(@"Audio track is nil");
    _startTime = -1;
    return self;
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
    CMVideoFormatDescriptionRef formatDescription = NULL;
    OSStatus status = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBufferRef, &formatDescription);
    
    if (status != noErr || formatDescription == NULL) {
        NSLog(@"Failed to create format description: %d", (int)status);
        if (shouldRelease) {
            CVPixelBufferRelease(pixelBufferRef);
        }
        return;
    }

    CMSampleTimingInfo timingInfo;
    
    timingInfo.decodeTimeStamp = kCMTimeInvalid;
    if (_startTime == -1) {
        _startTime = frame.timeStampNs / 1000;
    }
    int64_t frameTime = (frame.timeStampNs / 1000) - _startTime;
    timingInfo.presentationTimeStamp = CMTimeMake(frameTime, 1000000);
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
        if (![self.writerInput appendSampleBuffer:outBuffer]) {
            NSLog(@"Frame not appended %@", self.assetWriter.error);
        }
    } else {
        NSLog(@"Failed to create sample buffer: %d", (int)status);
    }
    
    // Release Core Foundation objects to prevent memory leaks
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
