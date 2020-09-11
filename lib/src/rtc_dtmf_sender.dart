import 'dart:io';
import 'webrtc.dart';
import 'package:flutter/services.dart';

class RTCDTMFSender {
  // peer connection Id must be defined as a variable where this function will be called.

  static Future<void> sendDtmf(String peerConnectionId, String tone,
      {double duration, double gap}) async {
    final MethodChannel _channel = WebRTC.methodChannel();

    double _duration = 0.0;
    double _gap = 0.0;
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
      'peerConnectionId': peerConnectionId,
      'tone': tone,
      'duration': _duration,
      'gap': _gap,
    });
  }
}
