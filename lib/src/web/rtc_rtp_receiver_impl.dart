import 'dart:js_util' as jsutil;

import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import 'media_stream_track_impl.dart';

class RTCRtpReceiverWeb extends RTCRtpReceiver {
  RTCRtpReceiverWeb(this._jsRtpReceiver);

  /// private:
  final Object _jsRtpReceiver;

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  @override
  RTCRtpParameters get parameters => RTCRtpParameters.fromMap(
      jsutil.callMethod(_jsRtpReceiver, 'getParameters', []));

  @override
  MediaStreamTrack get track =>
      MediaStreamTrackWeb(jsutil.getProperty(_jsRtpReceiver, 'track'));

  @override
  String get receiverId => jsutil.getProperty(_jsRtpReceiver, 'receiverId');
}
