import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_transceiver.dart';
import '../interface/rtc_track_event.dart';

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
