#import <CoreVideo/CoreVideo.h>
#import <WebRTC/RTCCVPixelBuffer.h>
#import <WebRTC/RTCMutableI420Buffer.h>
#import <XCTest/XCTest.h>
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

- (void)testFixedTrackDimensionsMatchUprightPixelsForEveryCameraRotation {
  RecordingSource *source = [RecordingSource new];
  NSDictionary *constraints = @{@"normalizeCaptureOrientation": @YES, @"width": @1280, @"height": @720};
  VideoProcessingAdapter *adapter = [[VideoProcessingAdapter alloc]
      initWithRTCVideoSource:(RTCVideoSource *)source cameraConstraints:constraints];
  RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:adapter];
  RTCMutableI420Buffer *camera = [[RTCMutableI420Buffer alloc] initWithWidth:640 height:480];
  const uint8_t quadrants[] = {40, 80, 140, 200};
  for (int y = 0; y < 480; y++) {
    for (int x = 0; x < 640; x++) {
      uint8_t quadrant = quadrants[(y < 240 ? 0 : 2) + (x < 320 ? 0 : 1)];
      camera.mutableDataY[y * camera.strideY + x] = (x < 130 || x >= 510) ? quadrant + 11 : quadrant;
    }
  }
  memset(camera.mutableDataU, 87, camera.strideU * camera.chromaHeight);
  memset(camera.mutableDataV, 165, camera.strideV * camera.chromaHeight);
  // A quarter turn crops away the sensor's left and right strips (+11).
  const uint8_t expected[][4] = {
    {51, 91, 151, 211}, {140, 40, 200, 80}, {211, 151, 91, 51}, {80, 200, 40, 140}
  };
  const RTCVideoRotation rotations[] = {
    RTCVideoRotation_0, RTCVideoRotation_90, RTCVideoRotation_180, RTCVideoRotation_270
  };
  CMVideoDimensions reported = [adapter trackDimensionsForCaptureDimensions:(CMVideoDimensions){640, 480}];
  XCTAssertEqual(reported.width, 1280);
  XCTAssertEqual(reported.height, 720);
  for (NSUInteger i = 0; i < 4; i++) {
    RTCVideoFrame *input = [[RTCVideoFrame alloc] initWithBuffer:camera rotation:rotations[i] timeStampNs:1000];
    input.timeStamp = 90;
    [adapter capturer:capturer didCaptureVideoFrame:input];
    RTCVideoFrame *output = source.lastFrame;
    XCTAssertEqual(output.width, reported.width);
    XCTAssertEqual(output.height, reported.height);
    XCTAssertEqual(output.rotation, RTCVideoRotation_0);
    XCTAssertEqual(output.timeStampNs, input.timeStampNs);
    XCTAssertEqual(output.timeStamp, input.timeStamp);
    if (output.width != 1280 || output.height != 720) continue;
    id<RTCI420Buffer> pixels = [output.buffer toI420];
    XCTAssertEqual(pixels.dataY[10 * pixels.strideY + 10], expected[i][0]);
    XCTAssertEqual(pixels.dataY[10 * pixels.strideY + 1270], expected[i][1]);
    XCTAssertEqual(pixels.dataY[710 * pixels.strideY + 10], expected[i][2]);
    XCTAssertEqual(pixels.dataY[710 * pixels.strideY + 1270], expected[i][3]);
    XCTAssertEqual(pixels.dataU[0], 87);
    XCTAssertEqual(pixels.dataV[0], 165);
  }
}

- (void)testOrdinaryCameraKeepsItsFrameAndSelectedCaptureDimensions {
  RecordingSource *source = [RecordingSource new];
  VideoProcessingAdapter *adapter = [[VideoProcessingAdapter alloc]
      initWithRTCVideoSource:(RTCVideoSource *)source cameraConstraints:@{@"width": @1280, @"height": @720}];
  RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:adapter];
  RTCMutableI420Buffer *camera = [[RTCMutableI420Buffer alloc] initWithWidth:640 height:480];
  RTCVideoFrame *input = [[RTCVideoFrame alloc] initWithBuffer:camera rotation:RTCVideoRotation_90 timeStampNs:1];
  [adapter capturer:capturer didCaptureVideoFrame:input];
  XCTAssertEqual(source.lastFrame, input);
  CMVideoDimensions reported = [adapter trackDimensionsForCaptureDimensions:(CMVideoDimensions){640, 480}];
  XCTAssertEqual(reported.width, 640);
  XCTAssertEqual(reported.height, 480);
}

- (void)testIncompleteNormalizedSizeOnlyRotatesPixels {
  RecordingSource *source = [RecordingSource new];
  VideoProcessingAdapter *adapter = [[VideoProcessingAdapter alloc]
      initWithRTCVideoSource:(RTCVideoSource *)source cameraConstraints:@{@"normalizeCaptureOrientation": @YES, @"width": @800}];
  RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:adapter];
  RTCMutableI420Buffer *camera = [[RTCMutableI420Buffer alloc] initWithWidth:4 height:2];
  RTCVideoFrame *input = [[RTCVideoFrame alloc] initWithBuffer:camera rotation:RTCVideoRotation_90 timeStampNs:10];
  [adapter capturer:capturer didCaptureVideoFrame:input];
  CMVideoDimensions reported = [adapter trackDimensionsForCaptureDimensions:(CMVideoDimensions){4, 2}];
  XCTAssertEqual(reported.width, 4);
  XCTAssertEqual(reported.height, 2);
  XCTAssertEqual(source.lastFrame.width, 2);
  XCTAssertEqual(source.lastFrame.height, 4);
  XCTAssertEqual(source.lastFrame.rotation, RTCVideoRotation_0);
}

- (void)testNormalizationPreservesTheCropAlreadyAppliedByWebRTC {
  CVPixelBufferRef pixels = NULL;
  CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, 200, 100,
                                       kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, NULL, &pixels);
  XCTAssertEqual(status, kCVReturnSuccess);
  if (status != kCVReturnSuccess) return;

  CVPixelBufferLockBaseAddress(pixels, 0);
  uint8_t* y = CVPixelBufferGetBaseAddressOfPlane(pixels, 0);
  size_t stride = CVPixelBufferGetBytesPerRowOfPlane(pixels, 0);
  memset(y, 5, stride * 100);
  for (int row = 20; row < 80; ++row) {
    memset(y + row * stride + 50, 150, 100);
  }
  memset(CVPixelBufferGetBaseAddressOfPlane(pixels, 1), 128,
         50 * CVPixelBufferGetBytesPerRowOfPlane(pixels, 1));
  CVPixelBufferUnlockBaseAddress(pixels, 0);

  RTCCVPixelBuffer* visible = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixels
                                                           adaptedWidth:100
                                                          adaptedHeight:60
                                                              cropWidth:100
                                                             cropHeight:60
                                                                  cropX:50
                                                                  cropY:20];
  CVPixelBufferRelease(pixels);
  RTCVideoFrame* frame = [[RTCVideoFrame alloc] initWithBuffer:visible
                                                    rotation:RTCVideoRotation_0
                                                 timeStampNs:1];
  RecordingSource *source = [RecordingSource new];
  VideoProcessingAdapter *adapter = [[VideoProcessingAdapter alloc]
      initWithRTCVideoSource:(RTCVideoSource *)source cameraConstraints:@{@"normalizeCaptureOrientation": @YES, @"width": @{@"ideal": @160}, @"height": @{@"exact": @96}}];
  RTCVideoCapturer *capturer = [[RTCVideoCapturer alloc] initWithDelegate:adapter];
  [adapter capturer:capturer didCaptureVideoFrame:frame];
  RTCVideoFrame *output = source.lastFrame;
  XCTAssertEqual(output.width, 160);
  XCTAssertEqual(output.height, 96);
  if (output.width != 160 || output.height != 96) return;

  id<RTCI420Buffer> i420 = [output.buffer toI420];
  XCTAssertEqual(i420.dataY[0], 150);
  XCTAssertEqual(i420.dataY[95 * i420.strideY + 159], 150);
}

@end
