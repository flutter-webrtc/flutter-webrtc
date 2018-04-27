import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';

class RTCVideoView {
    int _textureId;
    MediaStream _stream;
    MethodChannel _channel;

    RTCVideoView() {
       _channel = WebRTC.methodChannel();
       initilize();
    }

    initilize () async {
      final Map<dynamic, dynamic> response = await _channel.invokeMethod(
        'createVideoView',
        <String, dynamic>{}
        );
      _textureId = response['textureId'];
    }

    set muted(bool muted) =>
      _channel.invokeMethod(
        'mute',
        <String, dynamic>{
          'textureId': _textureId,
          'streamId': _stream.textureId() ,
          'muted' : muted
          }
        );

    set mirror(bool mirror) =>
     _channel.invokeMethod(
        'mirror',
        <String, dynamic>{
          'textureId': _textureId,
          'streamId': _stream.textureId() ,
          'mirror' : mirror}
        );

    set srcObject(MediaStream stream) {
      _stream = stream;
      //*添加stream 到VideoView 渲染通道*/
      _channel.invokeMethod(
        'setSrcObject',
        <String, dynamic>{
          'textureId': _textureId,
          'streamId': _stream.textureId()
          }
        );
    }
}
