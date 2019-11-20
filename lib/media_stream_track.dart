import 'dart:async';

import 'package:flutter/services.dart';
import 'utils.dart';

class MediaStreamTrack {
  /// private:
  MethodChannel _methodChannel = WebRTC.methodChannel();
  String _trackId;
  String _label;
  String _kind;
  bool _enabled;

  /// public:
  factory MediaStreamTrack.fromMap(Map<dynamic, dynamic> map) {
    return new MediaStreamTrack(
        map['trackId'], map['label'], map['kind'], map['enabled']);
  }

  MediaStreamTrack(this._trackId, this._label, this._kind, this._enabled);

  /// Mute/unmute the track.
  set enabled(bool enabled) {
    _methodChannel.invokeMethod('mediaStreamTrackSetEnable',
        <String, dynamic>{'trackId': _trackId, 'enabled': enabled});
    _enabled = enabled;
  }

  bool get enabled => _enabled;

  String get label => _label;

  String get kind => _kind;

  String get id => _trackId;

  Future<void> setVolume(double volume) async {
    await _methodChannel.invokeMethod(
      'setVolume',
      <String, dynamic>{'trackId': _trackId, 'volume': volume},
    );
  }

  /// TODO: Split the following method into a RTCAudioTrack and RTCVideoTrack.
  ///
  /// AudioTrack methods.
  /// Mute/unmute the microphone.
  Future<void> setMicrophoneMute(bool mute) async {
    await _methodChannel.invokeMethod(
      'setMicrophoneMute',
      <String, dynamic>{'trackId': _trackId, 'mute': mute},
    );
  }

  Future<void> enableSpeakerphone(bool enable) async {
    await _methodChannel.invokeMethod(
      'enableSpeakerphone',
      <String, dynamic>{'trackId': _trackId, 'enable': enable},
    );
  }

  /// VideoTrack methods
  /// Future contains isFrontCamera
  /// Throws error if switching camera failed.
  Future<bool> switchCamera() => _methodChannel.invokeMethod(
        'mediaStreamTrackSwitchCamera',
        <String, dynamic>{'trackId': _trackId},
      );

  Future<void> captureFrame(String filePath) => _methodChannel.invokeMethod(
        'captureFrame',
        <String, dynamic>{'trackId': _trackId, 'path': filePath},
      );

  Future<void> dispose() async {
    await _methodChannel.invokeMethod(
      'trackDispose',
      <String, dynamic>{'trackId': _trackId},
    );
  }
}
