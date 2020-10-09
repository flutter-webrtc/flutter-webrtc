import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_transceiver.dart';

class RTCTrackEvent {
  RTCTrackEvent({this.receiver, this.streams, this.track, this.transceiver});
  factory RTCTrackEvent.fromMap(Map<String, dynamic> map) {
    var streamsParams = map['streams'] as List<Map<String, dynamic>>;
    var streams = streamsParams.map((e) => MediaStream.fromMap(e)).toList();
    return RTCTrackEvent(
        receiver: RTCRtpReceiver.fromMap(map['receiver']),
        streams: streams,
        track: MediaStreamTrack.fromMap(map['track']),
        transceiver: RTCRtpTransceiver.fromMap(map['transceiver']));
  }
  final RTCRtpReceiver receiver;
  final List<MediaStream> streams;
  final MediaStreamTrack track;
  final RTCRtpTransceiver transceiver;
}
