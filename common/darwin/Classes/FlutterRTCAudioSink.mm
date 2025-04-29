#import <AVFoundation/AVFoundation.h>
#import "FlutterRTCAudioSink.h"
#import "RTCAudioSource+Private.h"
#include "media_stream_interface.h"
#include "audio_sink_bridge.cpp"

@implementation FlutterRTCAudioSink {
    AudioSinkBridge *_bridge;
    webrtc::AudioSourceInterface* _audioSource;
}

- (instancetype) initWithAudioTrack:(RTCAudioTrack* )audio {
    self = [super init];
    rtc::scoped_refptr<webrtc::AudioSourceInterface> audioSourcePtr = audio.source.nativeAudioSource;
    _audioSource = audioSourcePtr.get();
    _bridge = new AudioSinkBridge((void*)CFBridgingRetain(self));
    _audioSource->AddSink(_bridge);
    return self;
}

- (void) close {
    _audioSource->RemoveSink(_bridge);
    delete _bridge;
    _bridge = nil;
    _audioSource = nil;
}

void RTCAudioSinkCallback (void *object, const void *audio_data, int bits_per_sample, int sample_rate, size_t number_of_channels, size_t number_of_frames)
{
    AudioBufferList audioBufferList;
    AudioBuffer audioBuffer;
    audioBuffer.mData = (void*) audio_data;
    audioBuffer.mDataByteSize = bits_per_sample / 8 * number_of_channels * number_of_frames;
    audioBuffer.mNumberChannels = number_of_channels;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0] = audioBuffer;
    AudioStreamBasicDescription audioDescription;
    audioDescription.mBytesPerFrame = bits_per_sample / 8 * number_of_channels;
    audioDescription.mBitsPerChannel = bits_per_sample;
    audioDescription.mBytesPerPacket = bits_per_sample / 8 * number_of_channels;
    audioDescription.mChannelsPerFrame = number_of_channels;
    audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    audioDescription.mFramesPerPacket = 1;
    audioDescription.mReserved = 0;
    audioDescription.mSampleRate = sample_rate;
    CMAudioFormatDescriptionRef formatDesc;
    CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &audioDescription, 0, nil, 0, nil, nil, &formatDesc);
    CMSampleBufferRef buffer;
    CMSampleTimingInfo timing;
    timing.decodeTimeStamp = kCMTimeInvalid;
    timing.presentationTimeStamp = CMTimeMake(0, sample_rate);
    timing.duration = CMTimeMake(1, sample_rate);
    CMSampleBufferCreate(kCFAllocatorDefault, nil, false, nil, nil, formatDesc, number_of_frames * number_of_channels, 1, &timing, 0, nil, &buffer);
    CMSampleBufferSetDataBufferFromAudioBufferList(buffer, kCFAllocatorDefault, kCFAllocatorDefault, 0, &audioBufferList);
    @autoreleasepool {
        FlutterRTCAudioSink* sink = (__bridge FlutterRTCAudioSink*)(object);
        sink.format = formatDesc;
        if (sink.bufferCallback != nil) {
            sink.bufferCallback(buffer);
        } else {
            NSLog(@"Buffer callback is nil");
        }
    }
}

@end
