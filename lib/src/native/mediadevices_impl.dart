import 'dart:async';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import '../helper.dart';
import 'event_channel.dart';
import 'media_stream_impl.dart';
import 'utils.dart';

class MediaDeviceNative extends MediaDevices {
  MediaDeviceNative._internal() {
    FlutterWebRTCEventChannel.instance.handleEvents.stream.listen((data) {
      var event = data.keys.first;
      Map<dynamic, dynamic> map = data.values.first;
      handleEvent(event, map);
    });
  }

  static final MediaDeviceNative instance = MediaDeviceNative._internal();

  void handleEvent(String event, final Map<dynamic, dynamic> map) async {
    switch (map['event']) {
      case 'onDeviceChange':
        ondevicechange?.call(null);
        break;
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
    // Forward Helper.screenCaptureShowCursor to the native capturer as the
    // getDisplayMedia "cursor" video constraint. Only added when the caller has
    // not set one itself, so an explicit constraint always wins. Copy-on-write
    // so the caller's constraints map is never mutated.
    if (WebRTC.platformIsDesktop) {
      final cursor = Helper.screenCaptureShowCursor ? 'always' : 'never';
      final video = mediaConstraints['video'];
      if (video is Map) {
        mediaConstraints = <String, dynamic>{
          ...mediaConstraints,
          'video': <String, dynamic>{
            ...Map<String, dynamic>.from(video),
            if (!video.containsKey('cursor')) 'cursor': cursor,
          },
        };
      } else if (video == true) {
        // `video: true` carries no source/fps info; the native handler treats
        // an empty video map identically (same defaults), so it is safe to
        // upgrade it to a map that only carries the cursor preference.
        mediaConstraints = <String, dynamic>{
          ...mediaConstraints,
          'video': <String, dynamic>{'cursor': cursor},
        };
      }
    }
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
    var source = await getSources();
    return source
        .map(
          (e) => MediaDeviceInfo(
              deviceId: e['deviceId'],
              groupId: e['groupId'],
              kind: e['kind'],
              label: e['label']),
        )
        .toList();
  }

  @override
  Future<MediaDeviceInfo> selectAudioOutput(
      [AudioOutputOptions? options]) async {
    await WebRTC.invokeMethod('selectAudioOutput', {
      'deviceId': options?.deviceId,
    });
    // TODO(cloudwebrtc): return the selected device
    return MediaDeviceInfo(label: 'label', deviceId: options!.deviceId);
  }
}
