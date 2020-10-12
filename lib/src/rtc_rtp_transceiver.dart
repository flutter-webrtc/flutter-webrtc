import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'rtc_rtp_parameters.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';
import 'utils.dart';

enum TransceiverDirection {
  SendRecv,
  SendOnly,
  RecvOnly,
  Inactive,
}

final typeStringToRtpTransceiverDirection = <String, TransceiverDirection>{
  'sendrecv': TransceiverDirection.SendRecv,
  'sendonly': TransceiverDirection.SendOnly,
  'recvonly': TransceiverDirection.RecvOnly,
  'inactive': TransceiverDirection.Inactive,
};

final typeRtpTransceiverDirectionToString = <TransceiverDirection, String>{
  TransceiverDirection.SendRecv: 'sendrecv',
  TransceiverDirection.SendOnly: 'sendonly',
  TransceiverDirection.RecvOnly: 'recvonly',
  TransceiverDirection.Inactive: 'inactive',
};

List<RTCRtpEncoding> listToRtpEncodings(List<Map<String, dynamic>> list) {
  return list.map((e) => RTCRtpEncoding.fromMap(e)).toList();
}

class RTCRtpTransceiverInit {
  RTCRtpTransceiverInit({this.direction, this.sendEncodings, this.streams});

  factory RTCRtpTransceiverInit.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpTransceiverInit(
        direction: typeStringToRtpTransceiverDirection[map['direction']],
        sendEncodings: listToRtpEncodings(map['sendEncodings']),
        streams: (map['streams'] as List<dynamic>)
            .map((e) => MediaStream.fromMap(map))
            .toList());
  }
  TransceiverDirection direction;
  List<MediaStream> streams;
  List<RTCRtpEncoding> sendEncodings;

  Map<String, dynamic> toMap() {
    return {
      'direction': typeRtpTransceiverDirectionToString[direction],
      if (streams != null) 'streamIds': streams.map((e) => e.id).toList(),
      if (sendEncodings != null)
        'sendEncodings': sendEncodings.map((e) => e.toMap()).toList(),
    };
  }
}

class RTCRtpTransceiver {
  RTCRtpTransceiver(
      this._id, this._direction, this._mid, this._sender, this._receiver);

  factory RTCRtpTransceiver.fromMap(Map<dynamic, dynamic> map) {
    var transceiver = RTCRtpTransceiver(
        map['transceiverId'],
        typeStringToRtpTransceiverDirection[map['direction']],
        map['mid'],
        RTCRtpSender.fromMap(map['sender']),
        RTCRtpReceiver.fromMap(map['receiver']));
    return transceiver;
  }

  final MethodChannel _channel = WebRTC.methodChannel();
  String _peerConnectionId;
  String _id;
  bool _stop;
  TransceiverDirection _direction;
  String _mid;
  RTCRtpSender _sender;
  RTCRtpReceiver _receiver;

  set peerConnectionId(String id) {
    _peerConnectionId = id;
  }

  TransceiverDirection get currentDirection => _direction;

  String get mid => _mid;

  RTCRtpSender get sender => _sender;

  RTCRtpReceiver get receiver => _receiver;

  bool get stoped => _stop;

  String get transceiverId => _id;

  Future<void> setDirection(TransceiverDirection direction) async {
    try {
      await _channel
          .invokeMethod('rtpTransceiverSetDirection', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id,
        'direction': typeRtpTransceiverDirectionToString[direction]
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::setDirection: ${e.message}';
    }
  }

  Future<TransceiverDirection> getCurrentDirection() async {
    try {
      final response = await _channel.invokeMethod(
          'rtpTransceiverGetCurrentDirection', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id
      });
      _direction = typeStringToRtpTransceiverDirection[response['result']];
      return _direction;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::getCurrentDirection: ${e.message}';
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod('rtpTransceiverStop', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::stop: ${e.message}';
    }
  }
}
