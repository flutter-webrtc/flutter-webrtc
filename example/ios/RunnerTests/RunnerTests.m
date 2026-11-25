#import <XCTest/XCTest.h>
#import <WebRTC/RTCMutableI420Buffer.h>
#import <flutter_webrtc/FlutterWebRTCPlugin.h>
#import <flutter_webrtc/LocalVideoTrack.h>
#import <flutter_webrtc/VideoProcessingAdapter.h>

// Stand in for the video source so we can inspect exactly what capture delivers.
@interface RecordingSource : NSObject <RTCVideoCapturerDelegate>
@property(nonatomic, strong) RTCVideoFrame *lastFrame;
@end

@implementation RecordingSource
- (void)capturer:(RTCVideoCapturer *)capturer didCaptureVideoFrame:(RTCVideoFrame *)frame {
  self.lastFrame = frame;
}
@end

@interface RunnerTests : XCTestCase
@end

@implementation RunnerTests

- (void)testChannelRejectsAnOldCameraTrackAndUnknownOrientation {
  RecordingSource *source = [RecordingSource new];
  CameraVideoProcessingAdapter *adapter =
      [[CameraVideoProcessingAdapter alloc] initWithRTCVideoSource:(RTCVideoSource *)source];
  LocalVideoTrack *track = [LocalVideoTrack new];
  track.processing = adapter;
  FlutterWebRTCPlugin *plugin = [FlutterWebRTCPlugin new];
  plugin.localTracks = [@{@"camera-track": track} mutableCopy];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"mediaStreamTrackSetCameraCaptureOrientation"
                     arguments:@{@"trackId": @"camera-track", @"orientation": @"diagonal"}];
  __block id reply = nil;
  [plugin handleMethodCall:call result:^(id value) { reply = value; }];
  XCTAssertEqualObjects([(FlutterError *)reply code], @"camera_not_found");

  // Use the same adapter as the active capture source.
  plugin.videoCapturer = (RTCCameraVideoCapturer *)[[RTCVideoCapturer alloc] initWithDelegate:adapter];
  [plugin handleMethodCall:call result:^(id value) { reply = value; }];
  XCTAssertEqualObjects([(FlutterError *)reply code], @"invalid_orientation");

  for (id choice in @[@"landscapeLeft", [NSNull null]]) {
    call = [FlutterMethodCall methodCallWithMethodName:call.method
                                             arguments:@{@"trackId": @"camera-track", @"orientation": choice}];
    reply = FlutterMethodNotImplemented;
    [plugin handleMethodCall:call result:^(id value) { reply = value; }];
    XCTAssertNil(reply);
  }
}

- (void)testLockUsesSelectedOrientationAndActiveLens {
  RecordingSource *source = [RecordingSource new];
  CameraVideoProcessingAdapter *adapter =
      [[CameraVideoProcessingAdapter alloc] initWithRTCVideoSource:(RTCVideoSource *)source];
  RTCMutableI420Buffer *buffer = [[RTCMutableI420Buffer alloc] initWithWidth:4 height:2];
  RTCVideoFrame *frame = [[RTCVideoFrame alloc] initWithBuffer:buffer
                                                      rotation:RTCVideoRotation_270
                                                   timeStampNs:123456789];
  frame.timeStamp = 456;
  RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:adapter];

  NSArray<NSString *> *orientations = @[@"portraitUp", @"landscapeLeft", @"portraitDown", @"landscapeRight"];
  NSArray<NSNumber *> *frontRotations = @[@90, @0, @270, @180];
  NSArray<NSNumber *> *backRotations = @[@90, @180, @270, @0];
  for (NSUInteger i = 0; i < orientations.count; i++) {
    XCTAssertTrue([adapter setCaptureOrientationNamed:orientations[i]]);
    adapter.cameraPosition = AVCaptureDevicePositionFront;
    [adapter capturer:capturer didCaptureVideoFrame:frame];
    XCTAssertEqual(source.lastFrame.rotation, frontRotations[i].intValue);
    XCTAssertEqual(source.lastFrame.buffer, buffer);
    XCTAssertEqual(source.lastFrame.timeStampNs, frame.timeStampNs);
    XCTAssertEqual(source.lastFrame.timeStamp, frame.timeStamp);

    // Switch lenses without unlocking or reselecting the orientation.
    adapter.cameraPosition = AVCaptureDevicePositionBack;
    [adapter capturer:capturer didCaptureVideoFrame:frame];
    XCTAssertEqual(source.lastFrame.rotation, backRotations[i].intValue);
  }
}

- (void)testUnlockRestoresCaptureFramesAndInvalidRequestKeepsLock {
  RecordingSource *source = [RecordingSource new];
  CameraVideoProcessingAdapter *adapter =
      [[CameraVideoProcessingAdapter alloc] initWithRTCVideoSource:(RTCVideoSource *)source];
  RTCMutableI420Buffer *buffer = [[RTCMutableI420Buffer alloc] initWithWidth:4 height:2];
  RTCVideoFrame *frame = [[RTCVideoFrame alloc] initWithBuffer:buffer
                                                      rotation:RTCVideoRotation_0
                                                   timeStampNs:1000];
  RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:adapter];
  [adapter capturer:capturer didCaptureVideoFrame:frame];
  XCTAssertEqual(source.lastFrame, frame);

  XCTAssertTrue([adapter setCaptureOrientationNamed:@"portraitDown"]);
  XCTAssertFalse([adapter setCaptureOrientationNamed:@"diagonal"]);
  [adapter capturer:capturer didCaptureVideoFrame:frame];
  XCTAssertEqual(source.lastFrame.rotation, RTCVideoRotation_270);
  XCTAssertTrue([adapter setCaptureOrientationNamed:nil]);
  [adapter capturer:capturer didCaptureVideoFrame:frame];
  XCTAssertEqual(source.lastFrame, frame);
}

@end
