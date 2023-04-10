import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'utils.dart';

class RTCRtpSenderNative extends RTCRtpSender {
  RTCRtpSenderNative(this._id, this._track, this._dtmf, this._parameters,
      this._ownsTrack, this._peerConnectionId);

  factory RTCRtpSenderNative.fromMap(Map<dynamic, dynamic> map,
      {required String peerConnectionId}) {
    Map<dynamic, dynamic> trackMap = map['track'];
    return RTCRtpSenderNative(
        map['senderId'],
        (trackMap.isNotEmpty)
            ? MediaStreamTrackNative.fromMap(map['track'], peerConnectionId)
            : null,
        RTCDTMFSenderNative(peerConnectionId, map['senderId']),
        RTCRtpParameters.fromMap(map['rtpParameters']),
        map['ownsTrack'],
        peerConnectionId);
  }

  static List<RTCRtpSenderNative> fromMaps(List<dynamic> map,
      {required String peerConnectionId}) {
    return map
        .map((e) =>
            RTCRtpSenderNative.fromMap(e, peerConnectionId: peerConnectionId))
        .toList();
  }

  String _peerConnectionId;
  String _id;
  MediaStreamTrack? _track;
  final Set<MediaStream> _streams = {};
  RTCDTMFSender _dtmf;
  RTCRtpParameters _parameters;
  bool _ownsTrack = false;

  @override
  Future<List<StatsReport>> getStats() async {
    try {
      final response = await WebRTC.invokeMethod('getStats', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        if (track != null) 'trackId': track!.id,
      });
      var stats = <StatsReport>[];
      if (response != null) {
        List<dynamic> reports = response['stats'];
        for (var report in reports) {
          stats.add(StatsReport(report['id'], report['type'],
              report['timestamp'], report['values']));
        }
      }
      return stats;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::getStats: ${e.message}';
    }
  }

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    _parameters = parameters;
    try {
      final response =
          await WebRTC.invokeMethod('rtpSenderSetParameters', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'parameters': parameters.toMap()
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::setParameters: ${e.message}';
    }
  }

  @override
  Future<void> replaceTrack(MediaStreamTrack? track) async {
    try {
      await WebRTC.invokeMethod('rtpSenderReplaceTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'trackId': track != null ? track.id : ''
      });

      // change reference of associated MediaTrack
      _track = track;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::replaceTrack: ${e.message}';
    }
  }

  @override
  Future<void> setTrack(MediaStreamTrack? track,
      {bool takeOwnership = true}) async {
    try {
      await WebRTC.invokeMethod('rtpSenderSetTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'trackId': track != null ? track.id : '',
        'takeOwnership': takeOwnership,
      });

      // change reference of associated MediaTrack
      _track = track;
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSenderNative::setTrack: ${e.message}';
    }
  }

  @override
  Future<void> setStreams(List<MediaStream> streams) async {
    try {
      await WebRTC.invokeMethod('rtpSenderSetStreams', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'streamIds': streams.map<String>((e) => e.id).toList(),
      });

      // change reference of associated MediaTrack
      _streams.addAll(streams);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }

  void removeTrackReference() {
    _track = null;
  }

  @override
  RTCRtpParameters get parameters => _parameters;

  @override
  MediaStreamTrack? get track => _track;

  @override
  String get senderId => _id;

  @override
  bool get ownsTrack => _ownsTrack;

  @override
  RTCDTMFSender get dtmfSender => _dtmf;

  String get peerConnectionId => _peerConnectionId;

  @Deprecated(
      'No need to dispose rtpSender as it is handled by peerConnection.')
  @override
  @mustCallSuper
  Future<void> dispose() async {}
}
