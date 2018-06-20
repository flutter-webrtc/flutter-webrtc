import 'package:flutter/services.dart';
import 'package:webrtc/utils.dart';

class MediaStreamTrack {
  MethodChannel _channel = WebRTC.methodChannel();
  String _trackId;
  String _label;
  String _kind;
  bool _enabled;

  MediaStreamTrack(this._trackId, this._label, this._kind, this._enabled);

  set enabled(bool enabled) {
    _channel.invokeMethod('mediaStreamTrackEnabled',
        <String, dynamic>{'trackId': _trackId, 'enabled': enabled});
    _enabled = enabled;
  }

  bool get enabled => _enabled;
  String get label => _label;
  String get kind => _kind;
  String get id => _trackId;

  void dispose() async {
    await _channel.invokeMethod(
      'trackDispose',
      <String, dynamic>{'trackId': _trackId},
    );
  }
}
