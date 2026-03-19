import 'dart:math';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'utils.dart';

enum CameraFocusMode { auto, locked }

enum CameraExposureMode { auto, locked }

class CameraUtils {
  static Future<void> setZoom(
      MediaStreamTrack videoTrack, double zoomLevel) async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'mediaStreamTrackSetZoom',
        <String, dynamic>{'trackId': videoTrack.id, 'zoomLevel': zoomLevel},
      );
    } else {
      throw Exception('setZoom only support for mobile devices!');
    }
  }

  /// Set the exposure point for the camera, focusMode can be:
  /// 'auto', 'locked'
  static Future<void> setFocusMode(
      MediaStreamTrack videoTrack, CameraFocusMode focusMode) async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'mediaStreamTrackSetFocusMode',
        <String, dynamic>{
          'trackId': videoTrack.id,
          'focusMode': focusMode.name,
        },
      );
    } else {
      throw Exception('setFocusMode only support for mobile devices!');
    }
  }

  static Future<void> setFocusPoint(
      MediaStreamTrack videoTrack, Point<double>? point) async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'mediaStreamTrackSetFocusPoint',
        <String, dynamic>{
          'trackId': videoTrack.id,
          'focusPoint': {
            'reset': point == null,
            'x': point?.x,
            'y': point?.y,
          },
        },
      );
    } else {
      throw Exception('setFocusPoint only support for mobile devices!');
    }
  }

  static Future<void> setExposureMode(
      MediaStreamTrack videoTrack, CameraExposureMode exposureMode) async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'mediaStreamTrackSetExposureMode',
        <String, dynamic>{
          'trackId': videoTrack.id,
          'exposureMode': exposureMode.name,
        },
      );
    } else {
      throw Exception('setExposureMode only support for mobile devices!');
    }
  }

  static Future<void> setExposurePoint(
      MediaStreamTrack videoTrack, Point<double>? point) async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'mediaStreamTrackSetExposurePoint',
        <String, dynamic>{
          'trackId': videoTrack.id,
          'exposurePoint': {
            'reset': point == null,
            'x': point?.x,
            'y': point?.y,
          },
        },
      );
    } else {
      throw Exception('setExposurePoint only support for mobile devices!');
    }
  }

  /// Set the capture format to a high resolution (e.g. 4K) while adapting
  /// the output format to a lower resolution (e.g. 1080p) for encoding.
  /// This allows the ISP to use more sensor photosites when zoomed,
  /// resulting in significantly better quality at high zoom levels.
  /// iOS only.
  static Future<void> setCaptureFormat(
    MediaStreamTrack videoTrack, {
    int captureWidth = 3840,
    int captureHeight = 2160,
    int outputWidth = 1920,
    int outputHeight = 1080,
    int fps = 30,
  }) async {
    if (WebRTC.platformIsIOS) {
      await WebRTC.invokeMethod(
        'mediaStreamTrackSetCaptureFormat',
        <String, dynamic>{
          'trackId': videoTrack.id,
          'captureWidth': captureWidth,
          'captureHeight': captureHeight,
          'outputWidth': outputWidth,
          'outputHeight': outputHeight,
          'fps': fps,
        },
      );
    }
  }
}
