import 'dart:async';
import 'package:flutter/services.dart';

import 'utils.dart';

class RTCDTMFSender {
  /// private:
  String _id;
  MethodChannel _methodChannel = WebRTC.methodChannel();

  /// public::
  RTCDTMFSender(this._id);

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
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::duration: ${e.message}';
    }
  }

  Future<int> interToneGap() async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'dtmfSenderGetInterToneGap', <String, dynamic>{'dtmfSenderId': _id});
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCDTMFSender::interToneGap: ${e.message}';
    }
  }
}
