import 'dart:async';

import 'model/media_stream_track.dart';
import 'utils.dart';

class MediaStreamTrackNative extends MediaStreamTrack {
  MediaStreamTrackNative(this._trackId, this._label, this._kind, this._enabled);
  final _channel = WebRTC.methodChannel();
  final String _trackId;
  final String _label;
  final String _kind;
  bool _enabled;

  set enabled(bool enabled) {
    _channel.invokeMethod('mediaStreamTrackSetEnable',
        <String, dynamic>{'trackId': _trackId, 'enabled': enabled});
    _enabled = enabled;
  }

  @override
  bool get enabled => _enabled;

  @override
  String get label => _label;

  @override
  String get kind => _kind;

  @override
  String get id => _trackId;

  @override
  Future<bool> hasTorch() => _channel.invokeMethod(
        'mediaStreamTrackHasTorch',
        <String, dynamic>{'trackId': _trackId},
      );

  @override
  Future<void> setTorch(bool torch) => _channel.invokeMethod(
        'mediaStreamTrackSetTorch',
        <String, dynamic>{'trackId': _trackId, 'torch': torch},
      );

  @override
  Future<bool> switchCamera() => _channel.invokeMethod(
        'mediaStreamTrackSwitchCamera',
        <String, dynamic>{'trackId': _trackId},
      );

  @override
  void setVolume(double volume) async {
    await _channel.invokeMethod(
      'setVolume',
      <String, dynamic>{'trackId': _trackId, 'volume': volume},
    );
  }

  @override
  void setMicrophoneMute(bool mute) async {
    print('MediaStreamTrack:setMicrophoneMute $mute');
    await _channel.invokeMethod(
      'setMicrophoneMute',
      <String, dynamic>{'trackId': _trackId, 'mute': mute},
    );
  }

  @override
  void enableSpeakerphone(bool enable) async {
    print('MediaStreamTrack:enableSpeakerphone $enable');
    await _channel.invokeMethod(
      'enableSpeakerphone',
      <String, dynamic>{'trackId': _trackId, 'enable': enable},
    );
  }

  @override
  Future<dynamic> captureFrame([String filePath]) {
    return _channel.invokeMethod<void>(
      'captureFrame',
      <String, dynamic>{'trackId': _trackId, 'path': filePath},
    );
  }

  @override
  Future<void> dispose() async {
    await _channel.invokeMethod(
      'trackDispose',
      <String, dynamic>{'trackId': _trackId},
    );
  }

  @override
  Future<void> adaptRes(int width, int height) {
    throw UnimplementedError();
  }
}
