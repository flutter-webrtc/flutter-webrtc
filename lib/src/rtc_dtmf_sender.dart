import 'dart:io';
import 'webrtc.dart';
import 'package:flutter/services.dart';

class RTCDTMFSender {
  // peer connection Id must be defined as a variable where this function will be called.
  final String _peerConnectionId;

  RTCDTMFSender(this._peerConnectionId);

  Future<void> sendDtmf(String tone, {var duration, var gap}) async {
    final MethodChannel _channel = WebRTC.methodChannel();

    var _duration = Platform.isIOS ? 0.5 : 500;
    var _gap = Platform.isIOS ? 0.05 : 50;
    // IOS accepts gap and duration in seconds so conversion to be needed
    if (duration != null) {
      if (Platform.isIOS) {
        _duration = duration / 1000;
      } else {
        _duration = duration;
      }
    }

    if (gap != null) {
      if (Platform.isIOS) {
        _gap = gap / 1000;
      } else {
        _gap = gap;
      }
    }

    await _channel.invokeMethod('sendDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'tone': tone,
      'duration': _duration,
      'gap': _gap,
    });
  }
}
