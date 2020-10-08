import 'dart:async';
import 'package:flutter/services.dart';

import 'media_stream_track.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_rtp_parameters.dart';
import 'utils.dart';

class RTCRtpSender {
  RTCRtpSender(
      this._id, this._track, this._dtmf, this._parameters, this._ownsTrack);

  factory RTCRtpSender.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpSender(
        map['senderId'],
        MediaStreamTrack.fromMap(map['track']),
        RTCDTMFSender(map['peerConnectionId']),
        RTCRtpParameters.fromMap(map['rtpParameters']),
        map['ownsTrack']);
  }

  final MethodChannel _channel = WebRTC.methodChannel();
  String _peerConnectionId;
  String _id;
  MediaStreamTrack _track;
  RTCDTMFSender _dtmf;
  RTCRtpParameters _parameters;
  bool _ownsTrack = false;

  set peerConnectionId(String id) {
    _peerConnectionId = id;
  }

  Future<bool> setParameters(RTCRtpParameters parameters) async {
    _parameters = parameters;
    try {
      final response = await _channel
          .invokeMethod('rtpSenderSetParameters', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'parameters': parameters.toMap()
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.message}';
    }
  }

  Future<void> replaceTrack(MediaStreamTrack track) async {
    try {
      await _channel.invokeMethod('rtpSenderReplaceTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'trackId': track.id
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::replaceTrack: ${e.message}';
    }
  }

  Future<void> setTrack(MediaStreamTrack track, bool takeOwnership) async {
    try {
      await _channel.invokeMethod('rtpSenderSetTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'trackId': track.id,
        'takeOwnership': takeOwnership,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }

  RTCRtpParameters get parameters => _parameters;

  MediaStreamTrack get track => _track;

  String get senderId => _id;

  bool get ownsTrack => _ownsTrack;

  RTCDTMFSender get dtmfSender => _dtmf;

  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('rtpSenderDispose', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }
}
