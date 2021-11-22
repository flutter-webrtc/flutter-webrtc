import 'package:webrtc_interface/webrtc_interface.dart';

class RTCTrackEventWeb extends RTCTrackEvent {
  RTCTrackEventWeb(
      {RTCRtpReceiver? receiver,
      required List<MediaStream> streams,
      required MediaStreamTrack track,
      RTCRtpTransceiver? transceiver})
      : super(
            receiver: receiver,
            streams: streams,
            track: track,
            transceiver: transceiver);
}
