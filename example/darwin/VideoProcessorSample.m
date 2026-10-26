#import "VideoProcessorSample.h"

#import <WebRTC/WebRTC.h>
#import <flutter_webrtc/FlutterWebRTCPlugin.h>
#import <flutter_webrtc/LocalVideoTrack.h>
#import <stdatomic.h>
#import <string.h>

// Removes the color of a frame: keeps the Y (luma) plane and sets both chroma
// planes to 128, the neutral value, which gives a black and white picture.
// -onFrame: runs on the capture thread while enabled is set from the platform
// thread, hence the atomic.
@interface GrayscaleProcessor : NSObject <ExternalVideoProcessingDelegate>
- (void)setEnabled:(BOOL)enabled;
@end

@implementation GrayscaleProcessor {
  atomic_bool _enabled;
}

- (void)setEnabled:(BOOL)enabled {
  atomic_store(&_enabled, enabled);
}

- (RTC_OBJC_TYPE(RTCVideoFrame) *)onFrame:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
  if (!atomic_load(&_enabled)) return frame;

  // Camera frames usually come as NV12 CVPixelBuffers; toI420 handles that
  // and any cropping, and returns I420 buffers as they are.
  id<RTC_OBJC_TYPE(RTCI420Buffer)> src = [frame.buffer toI420];
  const int width = src.width;
  const int height = src.height;
  const int chromaHeight = src.chromaHeight;

  // The input frame must not be modified, so build a new one.
  RTC_OBJC_TYPE(RTCMutableI420Buffer) *dst =
      [[RTC_OBJC_TYPE(RTCMutableI420Buffer) alloc] initWithWidth:width height:height];
  for (int row = 0; row < height; ++row) {
    memcpy(dst.mutableDataY + row * dst.strideY, src.dataY + row * src.strideY, width);
  }
  memset(dst.mutableDataU, 128, (size_t)dst.strideU * chromaHeight);
  memset(dst.mutableDataV, 128, (size_t)dst.strideV * chromaHeight);

  return [[RTC_OBJC_TYPE(RTCVideoFrame) alloc] initWithBuffer:dst
                                                     rotation:frame.rotation
                                                  timeStampNs:frame.timeStampNs];
}

@end

@implementation VideoProcessorSample {
  // Filters by track id. Only touched on the platform thread.
  NSMutableDictionary<NSString*, GrayscaleProcessor*>* _processors;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"flutter_webrtc_example/video_processor"
                                  binaryMessenger:[registrar messenger]];
  VideoProcessorSample* instance = [[VideoProcessorSample alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _processors = [NSMutableDictionary new];
  }
  return self;
}

// Returns nil if `trackId` is not a local video track of flutter_webrtc.
- (LocalVideoTrack*)localVideoTrackForId:(NSString*)trackId {
  id<LocalTrack> track = FlutterWebRTCPlugin.sharedSingleton.localTracks[trackId];
  return [track isKindOfClass:[LocalVideoTrack class]] ? (LocalVideoTrack*)track : nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : nil;
  NSString* trackId = args[@"trackId"];
  if (![trackId isKindOfClass:[NSString class]]) {
    result([FlutterError errorWithCode:@"bad_args" message:@"trackId is required" details:nil]);
    return;
  }

  if ([call.method isEqualToString:@"setGrayscale"]) {
    NSNumber* enabled = args[@"enabled"];
    if (![enabled isKindOfClass:[NSNumber class]]) {
      result([FlutterError errorWithCode:@"bad_args" message:@"enabled is required" details:nil]);
      return;
    }
    GrayscaleProcessor* processor = _processors[trackId];
    if (processor == nil) {
      LocalVideoTrack* track = [self localVideoTrackForId:trackId];
      if (track == nil) {
        result([FlutterError
            errorWithCode:@"no_track"
                  message:[@"not a local video track of flutter_webrtc: "
                              stringByAppendingString:trackId]
                  details:nil]);
        return;
      }
      processor = [GrayscaleProcessor new];
      [track addProcessing:processor];
      _processors[trackId] = processor;
    }
    [processor setEnabled:enabled.boolValue];
    result(nil);
  } else if ([call.method isEqualToString:@"remove"]) {
    GrayscaleProcessor* processor = _processors[trackId];
    if (processor != nil) {
      // The track is gone if it was disposed first, and the processor went
      // with its adapter. Either way it is safe to drop it now.
      [[self localVideoTrackForId:trackId] removeProcessing:processor];
      [_processors removeObjectForKey:trackId];
    }
    result(@(processor != nil));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
