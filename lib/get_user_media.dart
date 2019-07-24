import 'dart:async';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'utils.dart';

class navigator {
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
