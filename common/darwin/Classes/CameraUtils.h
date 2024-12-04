#import <Foundation/Foundation.h>
#import "FlutterWebRTCPlugin.h"

@interface FlutterWebRTCPlugin (CameraUtils)

- (void)mediaStreamTrackHasTorch:(nonnull RTCMediaStreamTrack*)track result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSetTorch:(nonnull RTCMediaStreamTrack*)track
                           torch:(BOOL)torch
                          result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSetZoom:(nonnull RTCMediaStreamTrack*)track
                           zoomLevel:(double)zoomLevel
                          result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSetFocusMode:(nonnull RTCMediaStreamTrack*)track
                           focusMode:(nonnull NSString*)focusMode
                          result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSetFocusPoint:(nonnull RTCMediaStreamTrack*)track
                           focusPoint:(nonnull NSDictionary*)focusPoint
                          result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSetExposureMode:(nonnull RTCMediaStreamTrack*)track
                           exposureMode:(nonnull NSString*)exposureMode
                          result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSetExposurePoint:(nonnull RTCMediaStreamTrack*)track
                           exposurePoint:(nonnull NSDictionary*)exposurePoint
                            result:(nonnull FlutterResult)result;

- (void)mediaStreamTrackSwitchCamera:(nonnull RTCMediaStreamTrack*)track result:(nonnull FlutterResult)result;

- (NSInteger)selectFpsForFormat:(nonnull AVCaptureDeviceFormat*)format targetFps:(NSInteger)targetFps;

- (nullable AVCaptureDeviceFormat*)selectFormatForDevice:(nonnull AVCaptureDevice*)device
                                    targetWidth:(NSInteger)targetWidth
                                   targetHeight:(NSInteger)targetHeight;

- (nullable AVCaptureDevice*)findDeviceForPosition:(AVCaptureDevicePosition)position;


@end
