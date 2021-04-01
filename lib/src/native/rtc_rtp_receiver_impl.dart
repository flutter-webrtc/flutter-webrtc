import 'package:flutter/services.dart';

import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_stats_report.dart';

import 'media_stream_track_impl.dart';
import 'utils.dart';

class RTCRtpReceiverNative extends RTCRtpReceiver {
  RTCRtpReceiverNative(
      this._id, this._track, this._parameters, this._peerConnectionId);

  factory RTCRtpReceiverNative.fromMap(Map<dynamic, dynamic> map,
      {required String peerConnectionId}) {
    var track = MediaStreamTrackNative.fromMap(map['track']);
    var parameters = RTCRtpParameters.fromMap(map['rtpParameters']);
    return RTCRtpReceiverNative(
        map['receiverId'], track, parameters, peerConnectionId);
  }

  static List<RTCRtpReceiverNative> fromMaps(List<dynamic> map,
      {required String peerConnectionId}) {
    return map
        .map((e) =>
            RTCRtpReceiverNative.fromMap(e, peerConnectionId: peerConnectionId))
        .toList();
  }

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

  /// private:
  final _channel = WebRTC.methodChannel();
  String _id;
  String _peerConnectionId;
  MediaStreamTrack _track;
  RTCRtpParameters _parameters;

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  @override
  RTCRtpParameters get parameters => _parameters;

  @override
  MediaStreamTrack get track => _track;

  @override
  String get receiverId => _id;
}
