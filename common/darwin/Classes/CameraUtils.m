#import "CameraUtils.h"

@implementation FlutterWebRTCPlugin (CameraUtils)

-(AVCaptureDevice*) currentDevice {
  if (!self.videoCapturer) {
    return nil;
  }
  if (self.videoCapturer.captureSession.inputs.count == 0) {
    return nil;
  }
  AVCaptureDeviceInput* deviceInput = [self.videoCapturer.captureSession.inputs objectAtIndex:0];
  return deviceInput.device;
}

- (void)mediaStreamTrackHasTorch:(RTCMediaStreamTrack*)track result:(FlutterResult)result {
#if TARGET_OS_IPHONE
  AVCaptureDevice* device = [self currentDevice];

  if (!device) {
    NSLog(@"Video capturer is null. Can't check torch");
    result(@NO);
    return;
  }
  result(@([device isTorchModeSupported:AVCaptureTorchModeOn]));
#else
  NSLog(@"Not supported on macOS. Can't check torch");
  result(@NO);
#endif
}

- (void)mediaStreamTrackSetTorch:(RTCMediaStreamTrack*)track
                           torch:(BOOL)torch
                          result:(FlutterResult)result {
  AVCaptureDevice* device = [self currentDevice];
  if (!device) {
    NSLog(@"Video capturer is null. Can't set torch");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetTorchFailed" message:@"device is nil" details:nil]);
    return;
  }
  
  if (![device isTorchModeSupported:AVCaptureTorchModeOn]) {
    NSLog(@"Current capture device does not support torch. Can't set torch");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetTorchFailed" message:@"device does not support torch" details:nil]);
    return;
  }

  NSError* error;
  if ([device lockForConfiguration:&error] == NO) {
    NSLog(@"Failed to aquire configuration lock. %@", error.localizedDescription);
    result([FlutterError errorWithCode:@"mediaStreamTrackSetTorchFailed" message:error.localizedDescription details:nil]);
    return;
  }

  device.torchMode = torch ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
  [device unlockForConfiguration];

  result(nil);
}

- (void)mediaStreamTrackSetZoom:(RTCMediaStreamTrack*)track
                           zoomLevel:(double)zoomLevel
                          result:(FlutterResult)result {
#if TARGET_OS_IPHONE
  AVCaptureDevice* device = [self currentDevice];
  if (!device) {
    NSLog(@"Video capturer is null. Can't set zoom");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetZoomFailed" message:@"device is nil" details:nil]);
    return;
  }

  NSError* error;
  if ([device lockForConfiguration:&error] == NO) {
    NSLog(@"Failed to acquire configuration lock. %@", error.localizedDescription);
    result([FlutterError errorWithCode:@"mediaStreamTrackSetZoomFailed" message:error.localizedDescription details:nil]);
    return;
  }
  
  CGFloat desiredZoomFactor = (CGFloat)zoomLevel;
  device.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, device.activeFormat.videoMaxZoomFactor));
  [device unlockForConfiguration];

  result(nil);
#else
  NSLog(@"Not supported on macOS. Can't set zoom");
  result([FlutterError errorWithCode:@"mediaStreamTrackSetZoomFailed" message:@"Not supported on macOS" details:nil]);
#endif
}

- (void)applyFocusMode:(NSString*)focusMode onDevice:(AVCaptureDevice *)captureDevice {
#if TARGET_OS_IPHONE
  [captureDevice lockForConfiguration:nil];
  if([@"locked" isEqualToString:focusMode]) {
      if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
      }
    } else if([@"auto" isEqualToString:focusMode]) {
      if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
      } else if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
      }
  }
  [captureDevice unlockForConfiguration];
#endif
}

- (void)mediaStreamTrackSetFocusMode:(nonnull RTCMediaStreamTrack*)track
                           focusMode:(nonnull NSString*)focusMode
                          result:(nonnull FlutterResult)result {
#if TARGET_OS_IPHONE
  AVCaptureDevice *device = [self currentDevice];
  if (!device) {
    NSLog(@"Video capturer is null. Can't set focusMode");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetFocusModeFailed" message:@"device is nil" details:nil]);
    return;
  }
  self.focusMode = focusMode;
  [self applyFocusMode:focusMode onDevice:device];
  result(nil);
#else
  NSLog(@"Not supported on macOS. Can't focusMode");
  result([FlutterError errorWithCode:@"mediaStreamTrackSetFocusModeFailed" message:@"Not supported on macOS" details:nil]);
#endif
}

- (void)mediaStreamTrackSetFocusPoint:(nonnull RTCMediaStreamTrack*)track
                           focusPoint:(nonnull NSDictionary*)focusPoint
                          result:(nonnull FlutterResult)result {
#if TARGET_OS_IPHONE
  AVCaptureDevice *device = [self currentDevice];
  if (!device) {
    NSLog(@"Video capturer is null. Can't set focusPoint");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetFocusPointFailed" message:@"device is nil" details:nil]);
    return;
  }
  BOOL reset = ((NSNumber *)focusPoint[@"reset"]).boolValue;
  double x = 0.5;
  double y = 0.5;
  if (!reset) {
    x = ((NSNumber *)focusPoint[@"x"]).doubleValue;
    y = ((NSNumber *)focusPoint[@"y"]).doubleValue;
  }
  if (!device.isFocusPointOfInterestSupported) {
    NSLog(@"Focus point of interest is not supported. Can't set focusPoint");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetFocusPointFailed" message:@"Focus point of interest is not supported" details:nil]);
    return;
  }

  if (!device.isFocusPointOfInterestSupported) {
    NSLog(@"Focus point of interest is not supported. Can't set focusPoint");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetFocusPointFailed" message:@"Focus point of interest is not supported" details:nil]);
    return;
  }
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [device lockForConfiguration:nil];

  [device setFocusPointOfInterest:[self getCGPointForCoordsWithOrientation:orientation
                                                                                 x:x
                                                                                 y:y]];
  [device unlockForConfiguration];

  [self applyFocusMode:self.focusMode onDevice:device];
  result(nil);
#else
  NSLog(@"Not supported on macOS. Can't focusPoint");
  result([FlutterError errorWithCode:@"mediaStreamTrackSetFocusPointFailed" message:@"Not supported on macOS" details:nil]);
#endif
}

- (void) applyExposureMode:(NSString*)exposureMode onDevice:(AVCaptureDevice *)captureDevice {
#if TARGET_OS_IPHONE
  [captureDevice lockForConfiguration:nil];
  if([@"locked" isEqualToString:exposureMode]) {
      if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
      }
    } else if([@"auto" isEqualToString:exposureMode]) {
      if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
      } else if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
      }
  }
  [captureDevice unlockForConfiguration];
#endif
}

- (void)mediaStreamTrackSetExposureMode:(nonnull RTCMediaStreamTrack*)track
                           exposureMode:(nonnull NSString*)exposureMode
                          result:(nonnull FlutterResult)result{
#if TARGET_OS_IPHONE
  AVCaptureDevice *device = [self currentDevice];
  if (!device) {
    NSLog(@"Video capturer is null. Can't set exposureMode");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetExposureModeFailed" message:@"device is nil" details:nil]);
    return;
  }
  self.exposureMode = exposureMode;
  [self applyExposureMode:exposureMode onDevice:device];
  result(nil);
#else
  NSLog(@"Not supported on macOS. Can't exposureMode");
  result([FlutterError errorWithCode:@"mediaStreamTrackSetExposureModeFailed" message:@"Not supported on macOS" details:nil]);
#endif
}

#if TARGET_OS_IPHONE
- (CGPoint)getCGPointForCoordsWithOrientation:(UIDeviceOrientation)orientation
                                            x:(double)x
                                            y:(double)y {
  double oldX = x, oldY = y;
  switch (orientation) {
    case UIDeviceOrientationPortrait:  // 90 ccw
      y = 1 - oldX;
      x = oldY;
      break;
    case UIDeviceOrientationPortraitUpsideDown:  // 90 cw
      x = 1 - oldY;
      y = oldX;
      break;
    case UIDeviceOrientationLandscapeRight:  // 180
      x = 1 - x;
      y = 1 - y;
      break;
    case UIDeviceOrientationLandscapeLeft:
    default:
      // No rotation required
      break;
  }
  return CGPointMake(x, y);
}
#endif

- (void)mediaStreamTrackSetExposurePoint:(nonnull RTCMediaStreamTrack*)track
                           exposurePoint:(nonnull NSDictionary*)exposurePoint
                            result:(nonnull FlutterResult)result {
#if TARGET_OS_IPHONE
  AVCaptureDevice *device = [self currentDevice];

  if (!device) {
    NSLog(@"Video capturer is null. Can't set exposurePoint");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetExposurePointFailed" message:@"device is nil" details:nil]);
    return;
  }

  BOOL reset = ((NSNumber *)exposurePoint[@"reset"]).boolValue;
  double x = 0.5;
  double y = 0.5;
  if (!reset) {
    x = ((NSNumber *)exposurePoint[@"x"]).doubleValue;
    y = ((NSNumber *)exposurePoint[@"y"]).doubleValue;
  }
  if (!device.isExposurePointOfInterestSupported) {
    NSLog(@"Exposure point of interest is not supported. Can't set exposurePoint");
    result([FlutterError errorWithCode:@"mediaStreamTrackSetExposurePointFailed" message:@"Exposure point of interest is not supported" details:nil]);
    return;
  }
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [device lockForConfiguration:nil];
  [device setExposurePointOfInterest:[self getCGPointForCoordsWithOrientation:orientation
                                                                                    x:x
                                                                                    y:y]];
  [device unlockForConfiguration];

  [self applyExposureMode:self.exposureMode onDevice:device];
  result(nil);
#else
  NSLog(@"Not supported on macOS. Can't exposurePoint");
  result([FlutterError errorWithCode:@"mediaStreamTrackSetExposurePointFailed" message:@"Not supported on macOS" details:nil]);
#endif
}

- (void)mediaStreamTrackSwitchCamera:(RTCMediaStreamTrack*)track result:(FlutterResult)result {
  if (!self.videoCapturer) {
    NSLog(@"Video capturer is null. Can't switch camera");
    return;
  }
#if TARGET_OS_IPHONE
  [self.videoCapturer stopCapture];
#endif
  self._usingFrontCamera = !self._usingFrontCamera;
  AVCaptureDevicePosition position =
      self._usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
  AVCaptureDevice* videoDevice = [self findDeviceForPosition:position];
  AVCaptureDeviceFormat* selectedFormat = [self selectFormatForDevice:videoDevice
                                                          targetWidth:self._lastTargetWidth
                                                         targetHeight:self._lastTargetHeight];
  [self.videoCapturer startCaptureWithDevice:videoDevice
                                      format:selectedFormat
                                         fps:[self selectFpsForFormat:selectedFormat
                                                            targetFps:self._lastTargetFps]
                           completionHandler:^(NSError* error) {
                             if (error != nil) {
                               result([FlutterError errorWithCode:@"Error while switching camera"
                                                          message:@"Error while switching camera"
                                                          details:error]);
                             } else {
                               result([NSNumber numberWithBool:self._usingFrontCamera]);
                             }
                           }];
}


- (AVCaptureDevice*)findDeviceForPosition:(AVCaptureDevicePosition)position {
  if (position == AVCaptureDevicePositionUnspecified) {
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  }
  NSArray<AVCaptureDevice*>* captureDevices = [RTCCameraVideoCapturer captureDevices];
  for (AVCaptureDevice* device in captureDevices) {
    if (device.position == position) {
      return device;
    }
  }
  return captureDevices[0];
}

- (AVCaptureDeviceFormat*)selectFormatForDevice:(AVCaptureDevice*)device
                                    targetWidth:(NSInteger)targetWidth
                                   targetHeight:(NSInteger)targetHeight {
  NSArray<AVCaptureDeviceFormat*>* formats =
      [RTCCameraVideoCapturer supportedFormatsForDevice:device];
  AVCaptureDeviceFormat* selectedFormat = nil;
  long currentDiff = INT_MAX;
  for (AVCaptureDeviceFormat* format in formats) {
    CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
    FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
    //NSLog(@"AVCaptureDeviceFormats,fps %d, dimension: %dx%d", format.videoSupportedFrameRateRanges, dimension.width, dimension.height);
      long diff = labs(targetWidth - dimension.width) + labs(targetHeight - dimension.height);
    if (diff < currentDiff) {
      selectedFormat = format;
      currentDiff = diff;
    } else if (diff == currentDiff &&
               pixelFormat == [self.videoCapturer preferredOutputPixelFormat]) {
      selectedFormat = format;
    }
  }
  return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat*)format targetFps:(NSInteger)targetFps {
  Float64 maxSupportedFramerate = 0;
  for (AVFrameRateRange* fpsRange in format.videoSupportedFrameRateRanges) {
    maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
  }
  return fmin(maxSupportedFramerate, targetFps);
}


@end
