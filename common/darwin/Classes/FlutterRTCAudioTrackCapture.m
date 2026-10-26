#import "FlutterRTCAudioTrackCapture.h"
#import "LocalAudioTrack.h"
#import <AVFoundation/AVFoundation.h>

@implementation FlutterRTCAudioTrackCapture {
  RTCAudioTrack* _track;
  LocalAudioTrack* _localTrack;
  FlutterEventSink _eventSink;
}

- (instancetype)initWithAudioTrack:(RTCAudioTrack*)track {
  self = [super init];
  _track = track;
  [_track addRenderer:self];
  return self;
}

- (instancetype)initWithLocalAudioTrack:(LocalAudioTrack*)track {
  self = [super init];
  _localTrack = track;
  [_localTrack addRenderer:self];
  return self;
}

- (void)close {
  if (_track != nil) {
    [_track removeRenderer:self];
    _track = nil;
  }
  if (_localTrack != nil) {
    [_localTrack removeRenderer:self];
    _localTrack = nil;
  }
  _eventSink = nil;
}

- (FlutterError*)onListenWithArguments:(id)arguments
                           eventSink:(FlutterEventSink)events {
  _eventSink = events;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  _eventSink = nil;
  return nil;
}

// RTCAudioRenderer: PCM for one track — decoded samples for remote tracks,
// capture post-processing samples for local tracks. Arrives on a webrtc
// worker thread; the AVAudioPCMBuffer is only valid during the call, so
// samples are copied into s16le mono before the main-queue hop.
- (void)renderPCMBuffer:(AVAudioPCMBuffer*)pcmBuffer {
  const AVAudioFrameCount frames = pcmBuffer.frameLength;
  if (frames == 0) return;
  const AVAudioFormat* fmt = pcmBuffer.format;
  const int channels = (int)fmt.channelCount;
  if (channels <= 0) return;

  // The remote renderer path delivers non-interleaved float32; the local
  // APM adapter delivers non-interleaved int16. Downmix either to mono
  // s16le.
  NSMutableData* data =
      [NSMutableData dataWithLength:(NSUInteger)frames * 2];
  int16_t* out = (int16_t*)data.mutableBytes;
  const BOOL isFloat = fmt.commonFormat == AVAudioPCMFormatFloat32;
  for (AVAudioFrameCount i = 0; i < frames; i++) {
    float acc = 0;
    for (int c = 0; c < channels; c++) {
      const AVAudioFrameCount idx =
          fmt.isInterleaved ? i * channels + c : i;
      const int plane = fmt.isInterleaved ? 0 : c;
      if (isFloat) {
        acc += pcmBuffer.floatChannelData[plane][idx];
      } else {
        acc += pcmBuffer.int16ChannelData[plane][idx] / 32768.0f;
      }
    }
    acc /= channels;
    int v = (int)(acc * 32767.0f);
    out[i] = (int16_t)(v > 32767 ? 32767 : (v < -32768 ? -32768 : v));
  }

  FlutterEventSink sink = _eventSink;
  if (sink == nil) return;
  FlutterStandardTypedData* pcm =
      [FlutterStandardTypedData typedDataWithBytes:data];
  NSDictionary* frame = @{
    @"pcm" : pcm,
    @"sampleRate" : @((int)fmt.sampleRate),
    @"channels" : @1,
  };
  dispatch_async(dispatch_get_main_queue(), ^{
    FlutterEventSink s = _eventSink;
    if (s != nil) s(frame);
  });
}

@end
