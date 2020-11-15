import 'dart:async';

import 'package:dart_webrtc/dart_webrtc.dart' as dart_webrtc;
import 'package:flutter/services.dart';

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
    return RTCRtpTransceiverInitWeb(
        typeStringToRtpTransceiverDirection[map['direction']],
        (map['streams'] as List<dynamic>).map((e) => e).toList(),
        listToRtpEncodings(map['sendEncodings']));
  }

  Map<String, dynamic> toMap() {
    return {
      'direction': typeRtpTransceiverDirectionToString[direction],
      if (streams != null) 'streamIds': streams.map((e) => e.id).toList(),
      if (sendEncodings != null)
        'sendEncodings': sendEncodings.map((e) => e.toMap()).toList(),
    };
  }
}

class RTCRtpTransceiverWeb extends RTCRtpTransceiver {
  RTCRtpTransceiverWeb(this._jsTransceiver, _peerConnectionId);

  factory RTCRtpTransceiverWeb.fromJsObject(Object jsTransceiver,
      {String peerConnectionId}) {
    var transceiver = RTCRtpTransceiverWeb(jsTransceiver, peerConnectionId);
    return transceiver;
  }

  dart_webrtc.RTCRtpTransceiver _jsTransceiver;

  @override
  TransceiverDirection get currentDirection =>
      typeStringToRtpTransceiverDirection[_jsTransceiver.direction];

  @override
  String get mid => _jsTransceiver.mid;

  @override
  RTCRtpSender get sender =>
      RTCRtpSenderWeb.fromJsSender(_jsTransceiver.sender);

  @override
  RTCRtpReceiver get receiver => RTCRtpReceiverWeb(_jsTransceiver.receiver);

  @override
  bool get stoped => _jsTransceiver.stopped;

  @override
  String get transceiverId => _jsTransceiver.mid;

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    try {
      _jsTransceiver.direction = typeRtpTransceiverDirectionToString[direction];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::setDirection: ${e.message}';
    }
  }

  @override
  Future<TransceiverDirection> getCurrentDirection() async {
    try {
      return typeStringToRtpTransceiverDirection[_jsTransceiver.direction];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::getCurrentDirection: ${e.message}';
    }
  }

  @override
  Future<void> stop() async {
    try {
      _jsTransceiver.stop();
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::stop: ${e.message}';
    }
  }
}
