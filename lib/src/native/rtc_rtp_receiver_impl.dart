import '../interface/media_stream_track.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_receiver.dart';
import 'media_stream_track_impl.dart';

class RTCRtpReceiverNative extends RTCRtpReceiver {
  RTCRtpReceiverNative(this._id, this._track, this._parameters);

  factory RTCRtpReceiverNative.fromMap(Map<dynamic, dynamic> map) {
    var track = MediaStreamTrackNative.fromMap(map['track']);
    var parameters = RTCRtpParameters.fromMap(map['rtpParameters']);
    return RTCRtpReceiverNative(map['receiverId'], track, parameters);
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
}
