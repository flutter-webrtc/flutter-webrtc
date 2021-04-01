import 'dart:html';
import 'dart:js_util' as jsutil;

import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_stats_report.dart';
import 'media_stream_track_impl.dart';
import 'rtc_rtp_parameters_impl.dart';

class RTCRtpReceiverWeb extends RTCRtpReceiver {
  RTCRtpReceiverWeb(this._jsRtpReceiver);

  /// private:
  final RtcRtpReceiver _jsRtpReceiver;

  @override
  Future<List<StatsReport>> getStats() async {
    var stats = await jsutil.promiseToFuture<dynamic>(
        jsutil.callMethod(_jsRtpReceiver, 'getStats', []));
    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  @override
  RTCRtpParameters get parameters {
    var parameters = jsutil.callMethod(_jsRtpReceiver, 'getParameters', []);
    return RTCRtpParametersWeb.fromJsObject(parameters);
  }

  @override
  MediaStreamTrack get track => MediaStreamTrackWeb(_jsRtpReceiver.track!);

  @override
  String get receiverId => jsutil.getProperty(_jsRtpReceiver, 'receiverId');
}
