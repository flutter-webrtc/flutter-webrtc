import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum RTCVideoViewObjectFit {
  RTCVideoViewObjectFitContain,
  RTCVideoViewObjectFitCover,
}

typedef void VideoRotationChangeCallback(int textureId, int rotation);
typedef void VideoSizeChangeCallback(
    int textureId, double width, double height);

class RTCVideoRenderer {
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  int _rotation = 0;
  double _width, _height;
  bool _mirror = false;
  bool _muted = false;
  RTCVideoViewObjectFit _objectFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  StreamSubscription<dynamic> _eventSubscription;
  VideoSizeChangeCallback onVideoSizeChange;
  VideoRotationChangeCallback onVideoRotationChange;

  initialize() async {
    final Map<dynamic, dynamic> response =
        await _channel.invokeMethod('createVideoRenderer', {});
    _textureId = response['textureId'];
    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  int get renderId => _textureId;

  int get rotation => _rotation;

  double get width => _width;

  double get height => _height;

  bool get isInitialized => _textureId != null;

  set muted(bool muted) {
    _muted = muted;
  }

  set mirror(bool mirror) {
    _mirror = mirror;
  }

  set objectFit(RTCVideoViewObjectFit objectFit) {
    _objectFit = objectFit;
  }

  set srcObject(MediaStream stream) {
    _channel.invokeMethod('videoRendererSetSrcObject',
        <String, dynamic>{'textureId': _textureId, 'streamId': stream.id});
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod(
      'videoRendererDispose',
      <String, dynamic>{'textureId': _textureId},
    );
  }

  EventChannel _eventChannelFor(int textureId) {
    return new EventChannel('cloudwebrtc.com/WebRTC/Texture$textureId');
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        _rotation = map['rotation'];
        if (this.onVideoRotationChange != null)
          this.onVideoRotationChange(_textureId, _rotation);
        break;
      case 'didTextureChangeVideoSize':
        _width = map['width'];
        _height = map['height'];
        if (this.onVideoSizeChange != null)
          this.onVideoSizeChange(_textureId, _width, _height);
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
  }
}
