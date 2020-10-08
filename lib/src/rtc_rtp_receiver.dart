import 'dart:async';

import 'media_stream_track.dart';
import 'rtc_rtp_parameters.dart';

enum RTCRtpMediaType {
  RTCRtpMediaTypeAudio,
  RTCRtpMediaTypeVideo,
  RTCRtpMediaTypeData,
}

final typeRTCRtpMediaTypetoString = <RTCRtpMediaType, String>{
  RTCRtpMediaType.RTCRtpMediaTypeAudio: 'audio',
  RTCRtpMediaType.RTCRtpMediaTypeVideo: 'video',
  RTCRtpMediaType.RTCRtpMediaTypeData: 'data',
};

final typeStringToRTCRtpMediaType = <String, RTCRtpMediaType>{
  'audio': RTCRtpMediaType.RTCRtpMediaTypeAudio,
  'video': RTCRtpMediaType.RTCRtpMediaTypeVideo,
  'data': RTCRtpMediaType.RTCRtpMediaTypeData,
};

typedef OnFirstPacketReceivedCallback = void Function(
    RTCRtpReceiver rtpReceiver, RTCRtpMediaType mediaType);

class RTCRtpReceiver {
  RTCRtpReceiver(this._id, this._track, this._parameters);

  factory RTCRtpReceiver.fromMap(Map<dynamic, dynamic> map) {
    var track = MediaStreamTrack.fromMap(map['track']);
    var parameters = RTCRtpParameters.fromMap(map['rtpParameters']);
    return RTCRtpReceiver(map['receiverId'], track, parameters);
  }

  /// private:
  String _id;
  MediaStreamTrack _track;
  RTCRtpParameters _parameters;

  /// public:
  OnFirstPacketReceivedCallback onFirstPacketReceived;

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  RTCRtpParameters get parameters => _parameters;

  MediaStreamTrack get track => _track;

  String get receiverId => _id;

  Future<void> dispose() async {}
}
