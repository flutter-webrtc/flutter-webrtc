import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';

class RTCVideoView {
  MethodChannel _channel = WebRTC.methodChannel();
  int _videoViewId;

  RTCVideoView() {
    initilize();
  }

  initilize() async {
    final Map<dynamic, dynamic> response =
        await _channel.invokeMethod('createVideoView', <String, dynamic>{});
    _videoViewId = response['videoViewId'];
  }

  set muted(bool muted) => _channel.invokeMethod(
      'mute', <String, dynamic>{'_videoViewId': _videoViewId, 'muted': muted});

  set mirror(bool mirror) => _channel.invokeMethod('mirror',
      <String, dynamic>{'videoViewId': _videoViewId, 'mirror': mirror});

  set srcObject(MediaStream stream) {
    _channel.invokeMethod('setSrcObject',
        <String, dynamic>{'videoViewId': _videoViewId, 'streamId': stream.id});
  }
}
