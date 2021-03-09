import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_transceiver.dart';

class RTCTrackEvent {
  RTCTrackEvent({
    this.receiver,
    required this.streams,
    required this.track,
    this.transceiver,
  });
  final RTCRtpReceiver? receiver;
  final List<MediaStream> streams;
  final MediaStreamTrack track;
  final RTCRtpTransceiver? transceiver;
}
