import 'media_stream_track.dart';
import 'rtc_rtp_parameters.dart';

enum RTCRtpMediaType {
  RTCRtpMediaTypeAudio,
  RTCRtpMediaTypeVideo,
  RTCRtpMediaTypeData,
}

typedef void OnFirstPacketReceivedCallback(
    RTCRtpReceiver rtpReceiver, RTCRtpMediaType mediaType);

class RTCRtpReceiver {
  String _id;
  MediaStreamTrack _track;
  RTCRtpParameters _parameters;
  OnFirstPacketReceivedCallback onFirstPacketReceived;

  factory RTCRtpReceiver.fromMap(Map<String,dynamic> map){
    MediaStreamTrack track = MediaStreamTrack.fromMap(map['trackInfo']);
    RTCRtpParameters parameters = RTCRtpParameters.fromMap(map['rtpParameters']);
    return RTCRtpReceiver(map['receiverId'], track, parameters);
  }

  RTCRtpReceiver(this._id, this._track, this._parameters);

  Future<bool> setParameters(RTCRtpParameters parameters) async {
    _parameters = parameters;
    return false;
  }

  RTCRtpParameters getParameters() {
    return _parameters;
  }

  RTCRtpParameters get parameters => _parameters;

  MediaStreamTrack get track => _track;

  String get receiverId => _id;

  Future<void> dispose() async {}
}
