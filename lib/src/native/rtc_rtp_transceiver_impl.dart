import 'dart:async';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

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
        typeStringToRtpTransceiverDirection[map['direction']]!,
        (map['streams'] as List<dynamic>)
            .map((e) => MediaStreamNative.fromMap(map))
            .toList(),
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
      if (init.streams != null)
        'streamIds': init.streams!.map((e) => e.id).toList(),
      if (init.sendEncodings != null)
        'sendEncodings': init.sendEncodings!.map((e) => e.toMap()).toList(),
    };
  }
}

class RTCRtpTransceiverNative extends RTCRtpTransceiver {
  RTCRtpTransceiverNative(
    this._id,
    this._direction,
    this._mid,
    this._sender,
    this._receiver,
    this._peerConnectionId,
  );

  factory RTCRtpTransceiverNative.fromMap(Map<dynamic, dynamic> map,
      {required String peerConnectionId}) {
    var transceiver = RTCRtpTransceiverNative(
        map['transceiverId'] ?? '',
        typeStringToRtpTransceiverDirection[map['direction']]!,
        map['mid'] ?? '',
        RTCRtpSenderNative.fromMap(map['sender'],
            peerConnectionId: peerConnectionId),
        RTCRtpReceiverNative.fromMap(map['receiver'],
            peerConnectionId: peerConnectionId),
        peerConnectionId);
    return transceiver;
  }

  static List<RTCRtpTransceiverNative> fromMaps(List<dynamic> map,
      {required String peerConnectionId}) {
    return map
        .map((e) => RTCRtpTransceiverNative.fromMap(e,
            peerConnectionId: peerConnectionId))
        .toList();
  }

  String _peerConnectionId;
  String _id;
  bool _stop = false;
  TransceiverDirection _direction;
  String _mid;
  RTCRtpSender _sender;
  RTCRtpReceiver _receiver;

  set peerConnectionId(String id) {
    _peerConnectionId = id;
  }

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
      await WebRTC.invokeMethod('rtpTransceiverSetDirection', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id,
        'direction': typeRtpTransceiverDirectionToString[direction]
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::setDirection: ${e.message}';
    }
  }

  @override
  Future<TransceiverDirection?> getCurrentDirection() async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpTransceiverGetCurrentDirection', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id
      });
      return response != null
          ? typeStringToRtpTransceiverDirection[response['result']]
          : null;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::getCurrentDirection: ${e.message}';
    }
  }

  @override
  Future<TransceiverDirection> getDirection() async {
    try {
      final response = await WebRTC.invokeMethod(
          'rtpTransceiverGetDirection', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id
      });

      _direction = typeStringToRtpTransceiverDirection[response['result']]!;
      return _direction;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::getDirection: ${e.message}';
    }
  }

  @override
  Future<void> stop() async {
    try {
      await WebRTC.invokeMethod('rtpTransceiverStop', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id
      });

      _stop = true;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::stop: ${e.message}';
    }
  }

  @override
  Future<void> setCodecPreferences(List<RTCRtpCodecCapability> codecs) async {
    try {
      await WebRTC.invokeMethod('setCodecPreferences', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'transceiverId': _id,
        'codecs': codecs.map((e) => e.toMap()).toList()
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpTransceiver::setCodecPreferences: ${e.message}';
    }
  }
}
