#import "FlutterRemoteAudioTap.h"
#import <WebRTC/WebRTC.h>
#import <stdatomic.h>
#import "FlutterWebRTCPlugin.h"

// Up to 1 s of 48 kHz stereo between the audio thread and the delivery queue.
static const NSUInteger kMaxBufferedSamples = 48000 * 2;

// The renderer runs on the SDK's audio (playout) thread. It never waits: it
// tryLocks, copies into a preallocated buffer and returns. A timer on a private
// serial queue drains the buffer every 10 ms and posts it to the main thread.
@interface FlutterRemoteAudioTap : NSObject <RTCAudioRenderer, FlutterStreamHandler>
@property(nonatomic, copy) NSString* tapId;
@property(nonatomic, strong) RTCAudioTrack* track;
@property(nonatomic, strong) FlutterEventChannel* channel;
@property(nonatomic, copy, nullable) FlutterEventSink sink;
@end

@implementation FlutterRemoteAudioTap {
  NSLock* _lock;
  int16_t* _buffer;
  NSUInteger _count;
  int _rate, _channels;
  BOOL _silenced;
  double _previousVolume;
  dispatch_queue_t _queue;
  dispatch_source_t _timer;
  _Atomic uint64_t _callbacks, _deliveredFrames, _events, _contendedFrames, _overflowFrames,
      _formatDroppedFrames, _unsupportedFrames;
}

- (instancetype)initWithId:(NSString*)tapId
                     track:(RTCAudioTrack*)track
                   silence:(BOOL)silence
                 messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if ((self = [super init])) {
    _tapId = tapId;
    _track = track;
    _lock = [NSLock new];
    _buffer = malloc(kMaxBufferedSamples * sizeof(int16_t));
    _channel = [FlutterEventChannel
        eventChannelWithName:[NSString stringWithFormat:@"FlutterWebRTC/remoteAudioTap/%@", tapId]
             binaryMessenger:messenger];
    [_channel setStreamHandler:self];
    _queue = dispatch_queue_create("FlutterWebRTC.remoteAudioTap", DISPATCH_QUEUE_SERIAL);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_MSEC, 2 * NSEC_PER_MSEC);
    __weak FlutterRemoteAudioTap* weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
      [weakSelf drain];
    });
    dispatch_resume(_timer);
    _silenced = silence;
    if (silence) {
      _previousVolume = track.source.volume;
      track.source.volume = 0;  // mixer gain only; the renderer still receives PCM
    }
    [track addRenderer:self];
  }
  return self;
}

- (void)renderPCMBuffer:(AVAudioPCMBuffer*)pcmBuffer {
  atomic_fetch_add(&_callbacks, 1);
  int16_t* const* data = pcmBuffer.int16ChannelData;
  const NSUInteger frames = pcmBuffer.frameLength;
  const int channels = (int)pcmBuffer.format.channelCount;
  const int rate = (int)pcmBuffer.format.sampleRate;
  if (!data || channels <= 0) {
    atomic_fetch_add(&_unsupportedFrames, frames);
    return;
  }
  if (![_lock tryLock]) {
    atomic_fetch_add(&_contendedFrames, frames);
    return;
  }
  const NSUInteger n = frames * channels;  // interleaved in channel 0
  if (_count > 0 && (rate != _rate || channels != _channels)) {
    atomic_fetch_add(&_formatDroppedFrames, frames);
  } else if (_count + n > kMaxBufferedSamples) {
    atomic_fetch_add(&_overflowFrames, frames);
  } else {
    _rate = rate;
    _channels = channels;
    memcpy(_buffer + _count, data[0], n * sizeof(int16_t));
    _count += n;
  }
  [_lock unlock];
}

- (void)drain {
  [_lock lock];
  if (_count == 0) {
    [_lock unlock];
    return;
  }
  NSData* bytes = [NSData dataWithBytes:_buffer length:_count * sizeof(int16_t)];
  const int rate = _rate, channels = _channels;
  const NSUInteger frames = _count / channels;
  _count = 0;
  [_lock unlock];
  atomic_fetch_add(&_deliveredFrames, frames);
  atomic_fetch_add(&_events, 1);
  dispatch_async(dispatch_get_main_queue(), ^{
    FlutterEventSink sink = self.sink;
    if (sink) {
      sink(@{
        @"data" : [FlutterStandardTypedData typedDataWithBytes:bytes],
        @"sampleRate" : @(rate),
        @"channels" : @(channels),
        @"frames" : @(frames)
      });
    }
  });
}

- (NSDictionary*)stats {
  return @{
    @"callbacks" : @(atomic_load(&_callbacks)),
    @"deliveredFrames" : @(atomic_load(&_deliveredFrames)),
    @"events" : @(atomic_load(&_events)),
    @"contendedFrames" : @(atomic_load(&_contendedFrames)),
    @"overflowFrames" : @(atomic_load(&_overflowFrames)),
    @"formatDroppedFrames" : @(atomic_load(&_formatDroppedFrames)),
    @"unsupportedFrames" : @(atomic_load(&_unsupportedFrames)),
    @"silencedNativePlayout" : @(_silenced)
  };
}

- (void)close {
  [_track removeRenderer:self];
  if (_silenced) _track.source.volume = _previousVolume;
  if (_timer) {
    dispatch_source_cancel(_timer);
    _timer = nil;
  }
  [_channel setStreamHandler:nil];
  self.sink = nil;
}

- (void)dealloc {
  free(_buffer);
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
  self.sink = events;
  return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  self.sink = nil;
  return nil;
}
@end

@implementation FlutterRemoteAudioTaps {
  __weak FlutterWebRTCPlugin* _plugin;
  NSObject<FlutterBinaryMessenger>* _messenger;
  NSMutableDictionary<NSString*, FlutterRemoteAudioTap*>* _taps;
}

- (instancetype)initWithPlugin:(FlutterWebRTCPlugin*)plugin
                     messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if ((self = [super init])) {
    _plugin = plugin;
    _messenger = messenger;
    _taps = [NSMutableDictionary new];
  }
  return self;
}

- (void)handleCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
  if ([call.method isEqualToString:@"remoteAudioTapAttach"]) {
    RTCMediaStreamTrack* track = [_plugin remoteTrackForId:args[@"trackId"]];
    if (![track isKindOfClass:RTCAudioTrack.class]) {
      result([FlutterError errorWithCode:@"remote_audio_tap_track"
                                 message:@"No remote audio track"
                                 details:args[@"trackId"]]);
      return;
    }
    NSString* tapId = [[NSUUID UUID] UUIDString];
    _taps[tapId] = [[FlutterRemoteAudioTap alloc] initWithId:tapId
                                                       track:(RTCAudioTrack*)track
                                                     silence:[args[@"silenceNativePlayout"] boolValue]
                                                   messenger:_messenger];
    result(@{@"tapId" : tapId});
    return;
  }
  FlutterRemoteAudioTap* tap = _taps[args[@"tapId"]];
  if ([call.method isEqualToString:@"remoteAudioTapDetach"]) {
    [tap close];
    if (args[@"tapId"]) [_taps removeObjectForKey:args[@"tapId"]];
    result(nil);
    return;
  }
  if (!tap) {
    result([FlutterError errorWithCode:@"remote_audio_tap_closed" message:@"Unknown remote audio tap" details:nil]);
    return;
  }
  if ([call.method isEqualToString:@"remoteAudioTapStats"]) {
    result([tap stats]);
    return;
  }
  result(FlutterMethodNotImplemented);
}

- (void)close {
  for (FlutterRemoteAudioTap* tap in _taps.allValues) [tap close];
  [_taps removeAllObjects];
}
@end
