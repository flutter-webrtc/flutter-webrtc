import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/media_stream.dart';
import '../interface/mediadevices.dart';
import 'media_stream_impl.dart';
import 'utils.dart';

class MediaDeviceNative extends MediaDevices {
  MediaDeviceNative() {
    _onDeviceChangeSub = EventChannel('FlutterWebRTC/OnDeviceChange')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  /// Subscription on events from a [Stream].
  late StreamSubscription<dynamic> _onDeviceChangeSub;

  /// Event receiving a success handler.
  void eventListener(dynamic event) {
    if (onDeviceChange != null) {
      onDeviceChange!();
    }
  }

  /// Event receiving an error handler.
  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final response = await WebRTC.invokeMethod(
        'getUserMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      if (response == null) {
        throw Exception('getUserMedia return null, something wrong');
      }

      String streamId = response['streamId'];
      var stream = MediaStreamNative(streamId, 'local');
      stream.setMediaTracks(
          response['audioTracks'] ?? [], response['videoTracks'] ?? []);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getUserMedia: ${e.message}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final response = await WebRTC.invokeMethod(
        'getDisplayMedia',
        <String, dynamic>{'constraints': mediaConstraints},
      );
      if (response == null) {
        throw Exception('getDisplayMedia return null, something wrong');
      }
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
    try {
      final response = await WebRTC.invokeMethod(
        'getSources',
        <String, dynamic>{},
      );

      List<dynamic> sources = response['sources'];

      return sources;
    } on PlatformException catch (e) {
      throw 'Unable to getSources: ${e.message}';
    }
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    var _source = await getSources();
    return _source
        .map(
          (e) => MediaDeviceInfo(
              deviceId: e['deviceId'],
              groupId: e['groupId'],
              kind: e['kind'],
              label: e['label']),
        )
        .toList();
  }
}
