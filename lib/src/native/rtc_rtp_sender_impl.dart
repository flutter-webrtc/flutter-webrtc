import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../interface/media_stream_track.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_sender.dart';
import '../interface/rtc_stats_report.dart';
import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'utils.dart';

class RTCRtpSenderNative extends RTCRtpSender {
  RTCRtpSenderNative(this._id, this._track, this._dtmf, this._parameters,
      this._ownsTrack, this._peerConnectionId);

  factory RTCRtpSenderNative.fromMap(Map<dynamic, dynamic> map,
      {String peerConnectionId}) {
    return RTCRtpSenderNative(
        map['senderId'],
        MediaStreamTrackNative.fromMap(map['track']),
        RTCDTMFSenderNative(peerConnectionId, map['senderId']),
        RTCRtpParameters.fromMap(map['rtpParameters']),
        map['ownsTrack'],
        peerConnectionId);
  }

  static List<RTCRtpSenderNative> fromMaps(List<dynamic> map,
      {String peerConnectionId}) {
    return map
        .map((e) =>
            RTCRtpSenderNative.fromMap(e, peerConnectionId: peerConnectionId))
        .toList();
  }

  final MethodChannel _channel = WebRTC.methodChannel();
  String _peerConnectionId;
  String _id;
  MediaStreamTrack _track;
  RTCDTMFSender _dtmf;
  RTCRtpParameters _parameters;
  bool _ownsTrack = false;

  @override
  Future<List<StatsReport>> getStats() async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getStats', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'track': track.id
      });
      var stats = <StatsReport>[];
      if (response != null) {
        List<dynamic> reports = response['stats'];
        reports.forEach((report) {
          stats.add(StatsReport(report['id'], report['type'],
              report['timestamp'], report['values']));
        });
      }
      return stats;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getStats: ${e.message}';
    }
  }

  @override
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

  @override
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

  @override
  Future<void> setTrack(MediaStreamTrack track,
      {bool takeOwnership = true}) async {
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

  @override
  RTCRtpParameters get parameters => _parameters;

  @override
  MediaStreamTrack get track => _track;

  @override
  String get senderId => _id;

  @override
  bool get ownsTrack => _ownsTrack;

  @override
  RTCDTMFSender get dtmfSender => _dtmf;

  @override
  @mustCallSuper
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
