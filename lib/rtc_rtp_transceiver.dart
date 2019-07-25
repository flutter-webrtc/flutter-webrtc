import 'dart:async';
import 'package:flutter/services.dart';

import 'rtc_rtp_parameters.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_rtp_receiver.dart';

import 'utils.dart';

enum RTCRtpTransceiverDirection {
  RTCRtpTransceiverDirectionSendRecv,
  RTCRtpTransceiverDirectionSendOnly,
  RTCRtpTransceiverDirectionRecvOnly,
  RTCRtpTransceiverDirectionInactive,
}

final typeStringToRtpTransceiverDirection =
    <String, RTCRtpTransceiverDirection>{
  'sendrecv': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionSendRecv,
  'sendonly': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionSendOnly,
  'recvonly': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionRecvOnly,
  'inactive': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionInactive,
};

final typeRtpTransceiverDirectionToString =
    <RTCRtpTransceiverDirection, String>{
  RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionSendRecv: 'sendrecv',
  RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionSendOnly: 'sendonly',
  RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionRecvOnly: 'recvonly',
  RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionInactive: 'inactive',
};

class RTCRtpTransceiverInit {
  RTCRtpTransceiverDirection direction;
  List<String> streamIds;
  List<RTCRtpEncoding> sendEncodings;

  Map<String, dynamic> toMap() {
    List<dynamic> encodings = [];
    sendEncodings.forEach((encoding) {
      encodings.add(encoding.toMap());
    });
    return {
      'direction': typeRtpTransceiverDirectionToString[this.direction],
      'streamIds': streamIds,
      'sendEncodings': encodings,
    };
  }

  factory RTCRtpTransceiverInit.fromMap(Map<String, dynamic> map) {
    List<RTCRtpEncoding> encodings = [];
    dynamic encodingsMap = map['encodings'];
    encodingsMap.forEach((params) {
      encodings.add(RTCRtpEncoding.fromMap(params));
    });
    return RTCRtpTransceiverInit(
        typeStringToRtpTransceiverDirection[map['direction']],
        map['streamIds'],
        encodings);
  }
  RTCRtpTransceiverInit(this.direction, this.streamIds, this.sendEncodings);
}

class RTCRtpTransceiver {
  MethodChannel _methodChannel = WebRTC.methodChannel();
  String _id;
  bool _stop;
  RTCRtpTransceiverDirection _direction;
  String _mid;
  RTCRtpSender _sender;
  RTCRtpReceiver _receiver;

  factory RTCRtpTransceiver.fromMap(Map<String, dynamic> map) {
    RTCRtpTransceiver transceiver = RTCRtpTransceiver(
        map['transceiverId'],
        typeStringToRtpTransceiverDirection[map['direction']],
        map['mid'],
        RTCRtpSender.fromMap(map["senderInfo"]),
        RTCRtpReceiver.fromMap(map['receiverInfo']));
    return transceiver;
  }

  RTCRtpTransceiver(
      this._id, this._direction, this._mid, this._sender, this._receiver);

  RTCRtpTransceiverDirection get currentDirection => _direction;

  String get mid => _mid;

  RTCRtpSender get sender => _sender;

  RTCRtpReceiver get receiver => _receiver;

  bool get stoped => _stop;

  String get transceiverId => _id;

  Future<void> setDirection(RTCRtpTransceiverDirection direction) async {
    try {
      await _methodChannel
          .invokeMethod('rtpTransceiverSetDirection', <String, dynamic>{
        'transceiverId': _id,
        'direction': typeRtpTransceiverDirectionToString[direction]
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::setDirection: ${e.message}';
    }
  }

  Future<RTCRtpTransceiverDirection> getCurrentDirection() async {
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'rtpTransceiverGetCurrentDirection',
          <String, dynamic>{'transceiverId': _id});
      _direction = typeStringToRtpTransceiverDirection[response['result']];
      return _direction;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::getCurrentDirection: ${e.message}';
    }
  }

  Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod(
          'rtpTransceiverStop', <String, dynamic>{'transceiverId': _id});
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::stop: ${e.message}';
    }
  }
}
