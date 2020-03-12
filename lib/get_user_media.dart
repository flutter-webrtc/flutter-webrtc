import 'dart:async';
import 'package:flutter/services.dart';

import 'media_stream.dart';
import 'utils.dart';

class navigator {
  /// Get a MediaStream from video capture.
  /// Use |mediaConstraints| to limit video size,
  /// frame rate, and video devices
  static Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    MethodChannel channel = WebRTC.methodChannel();
    try {
      final Map<dynamic, dynamic> response = await channel.invokeMethod(
        'getUserMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      return MediaStream.fromMap(response);
    } on PlatformException catch (e) {
      throw 'Unable to getUserMedia: ${e.message}';
    }
  }

/* Implement screen sharing,
 * use MediaProjection for Android and use ReplayKit for iOS
 * TODO: implement for native layer.
 * */
  static Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    MethodChannel channel = WebRTC.methodChannel();
    try {
      final Map<dynamic, dynamic> response = await channel.invokeMethod(
        'getDisplayMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      return MediaStream.fromMap(response);
    } on PlatformException catch (e) {
      throw 'Unable to getDisplayMedia: ${e.message}';
    }
  }

  /// Enumerate the currently available video capture devices,
  /// returns a list of video devices and the sourceId.
  static Future<List<dynamic>> getSources() async {
    MethodChannel channel = WebRTC.methodChannel();
    try {
      final Map<dynamic, dynamic> response = await channel.invokeMethod(
        'getSources',
        <String, dynamic>{},
      );
      List<dynamic> sources = response["sources"];
      return sources;
    } on PlatformException catch (e) {
      throw 'Unable to getSources: ${e.message}';
    }
  }
}
