import 'dart:async';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

// Define custom exception classes
class MediaDeviceAcquireError extends Error {
  final String? message;
  MediaDeviceAcquireError([this.message]);
  @override
  String toString() => message ?? 'Failed to acquire media device';
}

class PermissionDeniedError extends MediaDeviceAcquireError {
  PermissionDeniedError([String? message]) : super(message ?? 'Permission denied by user');
}

class NotFoundError extends MediaDeviceAcquireError {
  NotFoundError([String? message]) : super(message ?? 'Requested device not found');
}

// TODO: Add other specific error types like OverconstrainedError, NotReadableError if needed.

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
      // Basic error code/message parsing. Native platforms might have more specific codes.
      // Common codes from web: 'NotFoundError', 'NotAllowedError', 'NotReadableError', 'OverconstrainedError', 'TypeError'
      // For native, codes might be like 'DOMException 1' for permission.
      // This is a simplified parsing.
      final message = e.message?.toLowerCase() ?? '';
      final code = e.code.toLowerCase();

      if (message.contains('permission denied') ||
          message.contains('not allowed') ||
          code == 'permissiondeniederror' ||
          code == 'notallowederror' ||
          // Android specific for permission denial often includes this
          message.contains('java.lang.securityexception') ||
          // iOS specific for permission denial
          message.contains('permission has been denied')) {
        throw PermissionDeniedError('Unable to getUserMedia: ${e.message}');
      } else if (code == 'notfounderror' || message.contains('not found')) {
        throw NotFoundError('Unable to getUserMedia: ${e.message}');
      }
      throw MediaDeviceAcquireError('Unable to getUserMedia: ${e.code} ${e.message}');
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
      final message = e.message?.toLowerCase() ?? '';
      final code = e.code.toLowerCase();

      if (message.contains('permission denied') ||
          message.contains('not allowed') ||
          code == 'permissiondeniederror' ||
          code == 'notallowederror') {
        throw PermissionDeniedError('Unable to getDisplayMedia: ${e.message}');
      } else if (code == 'notfounderror' || message.contains('not found')) {
        // This might not be typical for getDisplayMedia, but included for consistency
        throw NotFoundError('Unable to getDisplayMedia: ${e.message}');
      }
      throw MediaDeviceAcquireError('Unable to getDisplayMedia: ${e.code} ${e.message}');
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
