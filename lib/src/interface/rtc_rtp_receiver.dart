import 'enums.dart';
import 'media_stream_track.dart';
import 'rtc_rtp_parameters.dart';

typedef OnFirstPacketReceivedCallback = void Function(
    RTCRtpReceiver rtpReceiver, RTCRtpMediaType mediaType);

abstract class RTCRtpReceiver {
  RTCRtpReceiver();

  /// public:
  OnFirstPacketReceivedCallback onFirstPacketReceived;

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  RTCRtpParameters get parameters;

  MediaStreamTrack get track;

  String get receiverId;
}
