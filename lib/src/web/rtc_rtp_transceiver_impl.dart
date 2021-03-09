import 'dart:async';
import 'dart:js_util' as jsutil;

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/web/media_stream_impl.dart';

import '../interface/enums.dart';
import '../interface/media_stream.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_sender.dart';
import '../interface/rtc_rtp_transceiver.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';

List<RTCRtpEncoding> listToRtpEncodings(List<Map<String, dynamic>> list) {
  return list.map((e) => RTCRtpEncoding.fromMap(e)).toList();
}

class RTCRtpTransceiverInitWeb extends RTCRtpTransceiverInit {
  RTCRtpTransceiverInitWeb(TransceiverDirection direction,
      List<MediaStream> streams, List<RTCRtpEncoding> sendEncodings)
      : super(
            direction: direction,
            streams: streams,
            sendEncodings: sendEncodings);

  factory RTCRtpTransceiverInitWeb.fromMap(Map<dynamic, dynamic> map) {
    if (map['direction'] == null) {
      throw Exception('You must provide a direction');
    }
    if (map['streams'] == null) {
      throw Exception('You must provide the streams');
    }

    return RTCRtpTransceiverInitWeb(
        typeStringToRtpTransceiverDirection[map['direction']]!,
        (map['streams'] as List<MediaStream>).map((e) => e).toList(),
        listToRtpEncodings(map['sendEncodings']));
  }

  Map<String, dynamic> toMap() {
    return {
      'direction': typeRtpTransceiverDirectionToString[direction],
      if (streams != null) 'streamIds': streams!.map((e) => e.id).toList(),
      if (sendEncodings != null)
        'sendEncodings': sendEncodings!.map((e) => e.toMap()).toList(),
    };
  }

  static Map<String, dynamic> initToMap(RTCRtpTransceiverInit init) {
    return {
      'direction': typeRtpTransceiverDirectionToString[init.direction],
      'streams': init.streams != null
          ? init.streams!.map((e) => (e as MediaStreamWeb).jsStream).toList()
          : [],
      'sendEncodings': init.sendEncodings != null
          ? init.sendEncodings!.map((e) => e.toMap()).toList()
          : [],
    };
  }
}

class RTCRtpTransceiverWeb extends RTCRtpTransceiver {
  RTCRtpTransceiverWeb(this._jsTransceiver, _peerConnectionId);

  factory RTCRtpTransceiverWeb.fromJsObject(Object jsTransceiver,
      {String? peerConnectionId}) {
    var transceiver = RTCRtpTransceiverWeb(jsTransceiver, peerConnectionId);
    return transceiver;
  }

  Object _jsTransceiver;

  @override
  TransceiverDirection? get currentDirection =>
      typeStringToRtpTransceiverDirection[
          jsutil.getProperty(_jsTransceiver, 'direction')];

  @override
  String get mid => jsutil.getProperty(_jsTransceiver, 'mid');

  @override
  RTCRtpSender get sender => RTCRtpSenderWeb.fromJsSender(
      jsutil.getProperty(_jsTransceiver, 'sender'));

  @override
  RTCRtpReceiver get receiver =>
      RTCRtpReceiverWeb(jsutil.getProperty(_jsTransceiver, 'receiver'));

  @override
  bool get stoped => jsutil.getProperty(_jsTransceiver, 'stopped');

  @override
  String get transceiverId => mid;

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    try {
      jsutil.setProperty(_jsTransceiver, 'direction',
          typeRtpTransceiverDirectionToString[direction]);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::setDirection: ${e.message}';
    }
  }

  @override
  Future<TransceiverDirection> getCurrentDirection() async {
    try {
      var direction = jsutil.getProperty(_jsTransceiver, 'direction');
      return Future.value(typeStringToRtpTransceiverDirection[direction]);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::getCurrentDirection: ${e.message}';
    }
  }

  @override
  Future<void> stop() async {
    try {
      jsutil.callMethod(_jsTransceiver, 'stop', []);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::stop: ${e.message}';
    }
  }
}
