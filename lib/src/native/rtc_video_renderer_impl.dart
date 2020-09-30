import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/media_stream.dart';
import '../interface/rtc_video_renderer.dart';
import 'utils.dart';

class RTCVideoRendererNative extends VideoRenderer {
  RTCVideoRendererNative();
  final _channel = WebRTC.methodChannel();
  int _textureId;
  MediaStream _srcObject;
  StreamSubscription<dynamic> _eventSubscription;

  @override
  Future<void> initialize() async {
    final response = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('createVideoRenderer', {});
    _textureId = response['textureId'];
    _eventSubscription = EventChannel('FlutterWebRTC/Texture$textureId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  int get textureId => _textureId;

  @override
  MediaStream get srcObject => _srcObject;

  @override
  set srcObject(MediaStream stream) {
    if (textureId == null) throw 'Call initialize before setting the stream';

    _srcObject = stream;
    _channel.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': textureId,
      'streamId': stream?.id ?? '',
      'ownerTag': stream?.ownerTag ?? ''
    }).then((_) {
      value = (stream == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    });
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod(
      'videoRendererDispose',
      <String, dynamic>{'textureId': _textureId},
    );

    return super.dispose();
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        break;
      case 'didTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        break;
      case 'didFirstFrameRendered':
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  @override
  bool get renderVideo => srcObject != null;

  @override
  bool get muted => throw UnimplementedError();

  @override
  set muted(bool mute) {
    throw UnimplementedError();
  }
}
