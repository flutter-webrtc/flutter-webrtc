import 'dart:async';

import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import 'package:dart_webrtc/dart_webrtc.dart' as js;
import 'media_stream_track_impl.dart';

class RTCRtpReceiverWeb extends RTCRtpReceiver {
  RTCRtpReceiverWeb(this._jsRtpReceiver);

  /// private:
  final js.RTCRtpReceiver _jsRtpReceiver;

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  @override
  RTCRtpParameters get parameters => RTCRtpParameters.fromMap(
      js.rtpEncodingParametersToMap(_jsRtpReceiver.getParameters()));

  @override
  MediaStreamTrack get track => MediaStreamTrackWeb(_jsRtpReceiver.track);

  @override
  String get receiverId => _jsRtpReceiver?.track?.id ?? '';

  @override
  Future<void> dispose() async {}
}
