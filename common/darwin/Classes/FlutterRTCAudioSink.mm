#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "FlutterRTCAudioSink.h"

@interface FlutterRTCAudioSink () <RTCAudioRenderer>
@end

@implementation FlutterRTCAudioSink {
    RTCAudioTrack *_audioTrack;
    int64_t _sampleOffset;
    BOOL _isClosed;
}

- (instancetype)initWithAudioTrack:(RTCAudioTrack *)audio {
    self = [super init];
    if (self) {
        _audioTrack = audio;
        _sampleOffset = 0;
        _isClosed = NO;
        if (audio != nil) {
            NSLog(@"[FlutterRTCAudioSink] Adding audio renderer to track...");
            [audio addRenderer:self];
        }
    }
    return self;
}

- (void)close {
    RTCAudioTrack *track = nil;
    @synchronized(self) {
        if (_isClosed) return;
        _isClosed = YES;
        self.bufferCallback = nil;
        track = _audioTrack;
        _audioTrack = nil;
    }
    if (track != nil) {
        NSLog(@"[FlutterRTCAudioSink] Removing audio renderer from track...");
        [track removeRenderer:self];
        NSLog(@"[FlutterRTCAudioSink] Audio renderer removed.");
    }
}

- (void)dealloc {
    [self close];
    if (_format != NULL) {
        CFRelease(_format);
        _format = NULL;
    }
}

- (void)renderPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer {
    if (pcmBuffer == nil || pcmBuffer.frameLength == 0) {
        return;
    }

    void (^callback)(CMSampleBufferRef) = nil;
    int64_t currentOffset = 0;

    const AudioStreamBasicDescription *asbd = pcmBuffer.format.streamDescription;
    if (asbd == NULL || asbd->mSampleRate <= 0) {
        return;
    }

    CMAudioFormatDescriptionRef formatDesc = NULL;
    OSStatus status = CMAudioFormatDescriptionCreate(
        kCFAllocatorDefault,
        asbd,
        0,
        NULL,
        0,
        NULL,
        NULL,
        &formatDesc
    );
    if (status != noErr || formatDesc == NULL) {
        return;
    }

    @synchronized(self) {
        if (_isClosed) {
            CFRelease(formatDesc);
            return;
        }

        if (self.format == NULL) {
            self.format = (CMAudioFormatDescriptionRef)CFRetain(formatDesc);
            NSLog(@"[FlutterRTCAudioSink] Captured stream audio format: sampleRate=%.1f, channels=%u, bitsPerChannel=%u",
                  asbd->mSampleRate, (unsigned int)asbd->mChannelsPerFrame, (unsigned int)asbd->mBitsPerChannel);
        }

        callback = self.bufferCallback;
        if (!callback) {
            CFRelease(formatDesc);
            return;
        }
        currentOffset = _sampleOffset;
        _sampleOffset += pcmBuffer.frameLength;
    }

    int32_t sampleRate = (int32_t)asbd->mSampleRate;
    CMSampleTimingInfo timing = {
        .duration = CMTimeMake(1, sampleRate),
        .presentationTimeStamp = CMTimeMake(currentOffset, sampleRate),
        .decodeTimeStamp = kCMTimeInvalid
    };

    CMSampleBufferRef sampleBuffer = NULL;
    status = CMSampleBufferCreate(
        kCFAllocatorDefault,
        NULL,
        true,
        NULL,
        NULL,
        formatDesc,
        pcmBuffer.frameLength,
        1,
        &timing,
        0,
        NULL,
        &sampleBuffer
    );

    if (status == noErr && sampleBuffer != NULL) {
        status = CMSampleBufferSetDataBufferFromAudioBufferList(
            sampleBuffer,
            kCFAllocatorDefault,
            kCFAllocatorDefault,
            0,
            pcmBuffer.audioBufferList
        );
        if (status == noErr) {
            callback(sampleBuffer);
        } else {
            NSLog(@"[FlutterRTCAudioSink] CMSampleBufferSetDataBufferFromAudioBufferList failed: %d", (int)status);
        }
        CFRelease(sampleBuffer);
    }

    CFRelease(formatDesc);
}

@end
