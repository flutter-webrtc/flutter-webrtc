import 'dart:async';
import 'package:flutter/services.dart';

import 'utils.dart';

class RTCDTMFSender {
  /// private:
  String _id;
  int _interToneGap;
  int _duration;
  MethodChannel _methodChannel = WebRTC.methodChannel();

  /// public:
  factory RTCDTMFSender.fromMap(Map<String, dynamic> map){
    return new RTCDTMFSender(map['dtmfSenderId'], map['interToneGap'], map['duration']);
  }

  RTCDTMFSender(this._id, this._interToneGap, this._duration);

  Future<bool> canInsertDtmf() async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'dtmfSenderCanInsertDtmf', <String, dynamic>{'dtmfSenderId': _id});
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::canInsertDtmf: ${e.message}';
    }
  }

  Future<bool> insertDtmf(String tones, int duration, int interToneGap) async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel
          .invokeMethod('dtmfSenderCanInsertDtmf', <String, dynamic>{
        'dtmfSenderId': _id,
        'tones': tones,
        'duration': duration,
        'interToneGap': interToneGap
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::insertDtmf: ${e.message}';
    }
  }

  Future<String> tones() async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'dtmfSenderGetTones', <String, dynamic>{'dtmfSenderId': _id});
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::tones: ${e.message}';
    }
  }

  Future<int> duration() async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'dtmfSenderGetDuration', <String, dynamic>{'dtmfSenderId': _id});
      _duration = response['result'];
      return _duration;
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::duration: ${e.message}';
    }
  }

  Future<int> interToneGap() async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'dtmfSenderGetInterToneGap', <String, dynamic>{'dtmfSenderId': _id});
      _interToneGap = response['result'];
      return _interToneGap;
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::interToneGap: ${e.message}';
    }
  }
}
