import 'dart:async';

import 'package:dart_webrtc/dart_webrtc.dart' as js;

import '../interface/media_stream.dart';
import '../interface/mediadevices.dart';
import 'media_stream_impl.dart';

class MediaDevicesWeb extends MediaDevices {
  final js.MediaDevices _mediaDevices = js.navigator.mediaDevices;
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
      var jsStream = await _mediaDevices.getUserMedia(
          constraints: js.MediaStreamConstraints(
              audio: mediaConstraints['audio'],
              video: mediaConstraints['video']));
      return MediaStreamWeb(jsStream, 'local');
    } catch (e) {
      throw 'Unable to getUserMedia: ${e.toString()}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      mediaConstraints.putIfAbsent('video', () => false);
      mediaConstraints.putIfAbsent('audio', () => false);
      var jsStream = await _mediaDevices.getDisplayMedia(
          constraints: js.MediaStreamConstraints(
              audio: mediaConstraints['audio'],
              video: mediaConstraints['video']));
      return MediaStreamWeb(jsStream, 'local');
    } catch (e) {
      throw 'Unable to getDisplayMedia: ${e.toString()}';
    }
  }

  @override
  Future<List<dynamic>> getSources() async {
    final devices = await _mediaDevices.enumerateDevices();
    final result = <dynamic>[];
    for (final input in devices) {
      // info
      result.add(<String, String>{
        'deviceId': input.deviceId,
        'groupId': input.groupId,
        'kind': input.kind,
        'label': input.label
      });
    }
    return result;
  }
}
