import 'dart:async';
import 'dart:html' as html;
import 'dart:js';
import 'dart:js_util' as jsutil;

import '../interface/media_stream.dart';
import '../interface/navigator.dart';
import 'media_stream_impl.dart';

class NavigatorWeb extends Navigator {
  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    mediaConstraints ??= <String, dynamic>{};

    try {
      if (mediaConstraints['video'] is Map) {
        if (mediaConstraints['video']['facingMode'] != null) {
          mediaConstraints['video'].remove('facingMode');
        }
      }

      mediaConstraints.putIfAbsent('video', () => false);
      mediaConstraints.putIfAbsent('audio', () => false);

      final mediaDevices = html.window.navigator.mediaDevices;
      final jsStream = await mediaDevices.getUserMedia(mediaConstraints);
      return MediaStreamWeb(jsStream, 'local');
    } catch (e) {
      throw 'Unable to getUserMedia: ${e.toString()}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (jsutil.hasProperty(mediaDevices, 'getDisplayMedia')) {
        final arg = JsObject.jsify(mediaConstraints);

        final jsStream = await jsutil.promiseToFuture<html.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getDisplayMedia', [arg]));
        return MediaStreamWeb(jsStream, 'local');
      } else {
        final jsStream = await html.window.navigator.getUserMedia(
            video: {'mediaSource': 'screen'},
            audio: mediaConstraints['audio'] ?? false);
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getDisplayMedia: ${e.toString()}';
    }
  }

  @override
  Future<List<dynamic>> getSources() async {
    final devices = await html.window.navigator.mediaDevices.enumerateDevices();
    final result = <dynamic>[];
    for (final device in devices) {
      result.add(<String, String>{
        'deviceId': device.deviceId,
        'groupId': device.groupId,
        'kind': device.kind,
        'label': device.label
      });
    }
    return result;
  }
}
