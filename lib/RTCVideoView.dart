import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum RTCVideoViewObjectFit {
  RTCVideoViewObjectFitContain,
  RTCVideoViewObjectFitCover,
}

class RTCVideoViewController {
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  RTCVideoViewController();

  initialize(double width, double height) async {
    final Map<dynamic, dynamic> response =
        await _channel.invokeMethod('createVideoView', {
      'width': width,
      'height': height,
    });
    _textureId = response['textureId'];
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod(
      'videoViewDispose',
      <String, dynamic>{'textureId': _textureId},
    );
  }

  int get renderId => _textureId;

  bool get isInitialized => _textureId != null;

  set muted(bool muted) => _channel.invokeMethod('videoViewMuted',
      <String, dynamic>{'textureId': _textureId, 'mute': muted});

  set mirror(bool mirror) => _channel.invokeMethod('videoViewSetMirror',
      <String, dynamic>{'textureId': _textureId, 'mirror': mirror});

  set srcObject(MediaStream stream) {
    _channel.invokeMethod('videoViewSetSrcObject',
        <String, dynamic>{'textureId': _textureId, 'streamId': stream.id});
  }

  set objectFit(RTCVideoViewObjectFit objectFit) {
    _channel.invokeMethod('videoViewSetObjectFit',
        <String, dynamic>{'textureId': _textureId, 'objectFit': objectFit});
  }
}
