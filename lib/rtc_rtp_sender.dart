import 'media_stream_track.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_rtp_parameters.dart';

class RTCRtpSender {
  String _id;
  MediaStreamTrack _track;
  RTCDTMFSender _dtmf;
  RTCRtpParameters _parameters;
  bool _ownsTrack = false;

  factory RTCRtpSender.fromMap(Map<String, dynamic> map) {
    MediaStreamTrack track = MediaStreamTrack.fromMap(map['trackInfo']);
    RTCDTMFSender dtmfSender = RTCDTMFSender(map['dtmfSenderId']);
    RTCRtpParameters rtpParameters = RTCRtpParameters.fromMap(map['rtpParameters']);
    return new RTCRtpSender(
        map['senderId'], track, dtmfSender, rtpParameters, map['ownsTrack']);
  }

  RTCRtpSender(
      this._id, this._track, this._dtmf, this._parameters, this._ownsTrack);

  Future<bool> setParameters(RTCRtpParameters parameters) async {
    _parameters = parameters;
    return false;
  }

  RTCRtpParameters getParameters() {
    return _parameters;
  }

  Future<void> replaceTrack(MediaStreamTrack track) async {}

  Future<void> setTrack(MediaStreamTrack track, bool takeOwnership) async {}

  RTCRtpParameters get parameters => _parameters;

  MediaStreamTrack get track => _track;

  String get senderId => _id;

  bool get ownsTrack => _ownsTrack;

  RTCDTMFSender get dtmfSender => _dtmf;

  Future<void> dispose() async {}
}
