#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <Flutter/Flutter.h>
#else
#import <FlutterMacOS/FlutterMacOS.h>
#endif

NS_ASSUME_NONNULL_BEGIN

// Shows how an app or another native plugin can modify the frames of a
// flutter_webrtc local video track on iOS and macOS. It attaches a black and
// white filter to a track through -[LocalVideoTrack addProcessing:].
//
// This file is shared by the iOS and macOS runners, the Darwin counterpart of
// cpp/video_processor_sample.cpp. It handles the
// "flutter_webrtc_example/video_processor" method channel:
//   setGrayscale({trackId, enabled})
//   remove({trackId})
// See lib/src/video_processor_sample.dart for the Dart side.
@interface VideoProcessorSample : NSObject <FlutterPlugin>
@end

NS_ASSUME_NONNULL_END
