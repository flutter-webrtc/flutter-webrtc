#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#elif TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#endif
#import <WebRTC/WebRTC.h>

@class LocalAudioTrack;

/// Decoded-audio tap on one audio track. Remote tracks go through the public
/// RTCAudioRenderer protocol on RTCAudioTrack; local tracks go through
/// LocalAudioTrack.addRenderer:, which the AudioManager feeds from the
/// capture post-processing adapter (the SDK only drives track renderers
/// from the remote decode side). Frames arrive as
/// {pcm: s16le mono, sampleRate, channels: 1} maps on the event channel.
@interface FlutterRTCAudioTrackCapture
    : NSObject <FlutterStreamHandler, RTCAudioRenderer>

/// Remote track: decoded PCM via RTCAudioTrack.addRenderer:.
- (instancetype)initWithAudioTrack:(RTCAudioTrack*)track;

/// Local track: captured PCM via LocalAudioTrack's APM renderer.
- (instancetype)initWithLocalAudioTrack:(LocalAudioTrack*)track;

- (void)close;

@end
