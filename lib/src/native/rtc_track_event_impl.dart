import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_transceiver.dart';
import '../interface/rtc_track_event.dart';
import 'media_stream_impl.dart';
import 'media_stream_track_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';

class RTCTrackEventNative extends RTCTrackEvent {
  RTCTrackEventNative(RTCRtpReceiver receiver, List<MediaStream> streams,
      MediaStreamTrack track, RTCRtpTransceiver transceiver)
      : super(
            receiver: receiver,
            streams: streams,
            track: track,
            transceiver: transceiver);

  factory RTCTrackEventNative.fromMap(
      Map<String, dynamic> map, String peerConnectionId) {
    var streamsParams = map['streams'] as List<Map<String, dynamic>>;
    var streams =
        streamsParams.map((e) => MediaStreamNative.fromMap(e)).toList();
    return RTCTrackEventNative(
        RTCRtpReceiverNative.fromMap(map['receiver'],
            peerConnectionId: peerConnectionId),
        streams,
        MediaStreamTrackNative.fromMap(map['track']),
        RTCRtpTransceiverNative.fromMap(map['transceiver'],
            peerConnectionId: peerConnectionId));
  }
}
