import 'dart:async';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'utils.dart';

class navigator {
  static Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    var channel = WebRTC.methodChannel();
    try {
      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getUserMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      String streamId = response['streamId'];
      var stream = MediaStream(streamId, 'local');
      stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
      return stream;
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
    var channel = WebRTC.methodChannel();
    try {
      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDisplayMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      String streamId = response['streamId'];
      var stream = MediaStream(streamId, 'local');
      stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getDisplayMedia: ${e.message}';
    }
  }

  static Future<List<dynamic>> getSources() async {
    var channel = WebRTC.methodChannel();
    try {
      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getSources',
        <String, dynamic>{},
      );
      List<dynamic> sources = response['sources'];
      return sources;
    } on PlatformException catch (e) {
      throw 'Unable to getSources: ${e.message}';
    }
  }
}
