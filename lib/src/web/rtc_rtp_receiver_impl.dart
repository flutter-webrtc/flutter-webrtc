import 'dart:async';
import 'dart:js_util' as jsutil;

import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import 'media_stream_track_impl.dart';
import 'utils.dart';

class RTCRtpReceiverWeb extends RTCRtpReceiver {
  RTCRtpReceiverWeb(this._id, this._track, this._parameters);

  factory RTCRtpReceiverWeb.fromJsObject(Object jsObject) {
    var params = jsutil.callMethod(jsObject, 'getParameters', []);
    Map rtpParameters = convertToDart(params);
    var track =
        MediaStreamTrackWeb.fromJsObject(jsutil.getProperty(jsObject, 'track'));
    var parameters = RTCRtpParameters.fromMap(rtpParameters);
    return RTCRtpReceiverWeb(
        jsutil.getProperty(jsObject, 'receiverId'), track, parameters);
  }

  /// private:
  String _id;
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

  @override
  Future<void> dispose() async {}
}
