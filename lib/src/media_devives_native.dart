import 'dart:async';

import 'package:flutter/services.dart';

import 'media_stream_native.dart';
import 'model/media_device.dart';
import 'model/media_stream.dart';
import 'utils.dart';

class MediaDevicesNative extends MediaDevices {
  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    var channel = WebRTC.methodChannel();
    try {
      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getUserMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      String streamId = response['streamId'];
      var stream = MediaStreamNative(streamId, 'local');
      stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getUserMedia: ${e.message}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    var channel = WebRTC.methodChannel();
    try {
      final response = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDisplayMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      String streamId = response['streamId'];
      var stream = MediaStreamNative(streamId, 'local');
      stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getDisplayMedia: ${e.message}';
    }
  }

  @override
  Future<List<dynamic>> getSources() async {
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
