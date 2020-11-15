import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/enums.dart';
import '../interface/media_stream.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_sender.dart';
import '../interface/rtc_rtp_transceiver.dart';
import 'media_stream_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'utils.dart';

List<RTCRtpEncoding> listToRtpEncodings(List<Map<String, dynamic>> list) {
  return list.map((e) => RTCRtpEncoding.fromMap(e)).toList();
}

class RTCRtpTransceiverInitNative extends RTCRtpTransceiverInit {
  RTCRtpTransceiverInitNative(TransceiverDirection direction,
      List<MediaStream> streams, List<RTCRtpEncoding> sendEncodings)
      : super(
            direction: direction,
            streams: streams,
            sendEncodings: sendEncodings);

  factory RTCRtpTransceiverInitNative.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpTransceiverInitNative(
        typeStringToRtpTransceiverDirection[map['direction']],
        (map['streams'] as List<dynamic>)
            .map((e) => MediaStreamNative.fromMap(map))
            .toList(),
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

  static Map<String, dynamic> initToMap(RTCRtpTransceiverInit init) {
    return {
      'direction': typeRtpTransceiverDirectionToString[init.direction],
      if (init.streams != null)
        'streamIds': init.streams.map((e) => e.id).toList(),
      if (init.sendEncodings != null)
        'sendEncodings': init.sendEncodings.map((e) => e.toMap()).toList(),
    };
  }
}

class RTCRtpTransceiverNative extends RTCRtpTransceiver {
  RTCRtpTransceiverNative(this._id, this._direction, this._mid, this._sender,
      this._receiver, _peerConnectionId);

  factory RTCRtpTransceiverNative.fromMap(Map<dynamic, dynamic> map,
      {String peerConnectionId}) {
    var transceiver = RTCRtpTransceiverNative(
        map['transceiverId'],
        typeStringToRtpTransceiverDirection[map['direction']],
        map['mid'],
        RTCRtpSenderNative.fromMap(map['sender'],
            peerConnectionId: peerConnectionId),
        RTCRtpReceiverNative.fromMap(map['receiver']),
        peerConnectionId);
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

  @override
  TransceiverDirection get currentDirection => _direction;

  @override
  String get mid => _mid;

  @override
  RTCRtpSender get sender => _sender;

  @override
  RTCRtpReceiver get receiver => _receiver;

  @override
  bool get stoped => _stop;

  @override
  String get transceiverId => _id;

  @override
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

  @override
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

  @override
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
