import 'dart:js_util' as jsutil;

import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_transceiver.dart';
import '../interface/rtc_track_event.dart';

import 'media_stream_track_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';

class RTCTrackEventWeb extends RTCTrackEvent {
  RTCTrackEventWeb(RTCRtpReceiver receiver, List<MediaStream> streams,
      MediaStreamTrack track, RTCRtpTransceiver transceiver)
      : super(
            receiver: receiver,
            streams: streams,
            track: track,
            transceiver: transceiver);

  factory RTCTrackEventWeb.fromJsObject(
      Object jsObject, String peerConnectionId) {
    return RTCTrackEventWeb(
        RTCRtpReceiverWeb.fromJsObject(
            jsutil.getProperty(jsObject, 'receiver')),
        jsutil.getProperty(jsObject, 'streams'),
        MediaStreamTrackWeb.fromJsObject(jsutil.getProperty(jsObject, 'track')),
        RTCRtpTransceiverWeb.fromJsObject(
            jsutil.getProperty(jsObject, 'transceiver'),
            peerConnectionId: peerConnectionId));
  }
}
