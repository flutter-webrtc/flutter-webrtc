import 'dart:async';
import 'package:flutter/services.dart';

import 'media_stream_track.dart';
import 'rtc_rtp_parameters.dart';

import 'utils.dart';

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

typedef void OnFirstPacketReceivedCallback(
    RTCRtpReceiver rtpReceiver, RTCRtpMediaType mediaType);

class RTCRtpReceiver {
  /// private:
  MethodChannel _methodChannel = WebRTC.methodChannel();
  String _id;
  MediaStreamTrack _track;
  RTCRtpParameters _parameters;

  /// public:
  OnFirstPacketReceivedCallback onFirstPacketReceived;

  factory RTCRtpReceiver.fromMap(Map<String, dynamic> map) {
    MediaStreamTrack track = MediaStreamTrack.fromMap(map['trackInfo']);
    RTCRtpParameters parameters =
        RTCRtpParameters.fromMap(map['rtpParameters']);
    return RTCRtpReceiver(map['receiverId'], track, parameters);
  }

  RTCRtpReceiver(this._id, this._track, this._parameters);

  /// Currently, doesn't support changing any parameters, but may in the future.
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    _parameters = parameters;
    try {
      final Map<dynamic, dynamic> response = await _methodChannel.invokeMethod(
          'rtpReceiverSetParameters', <String, dynamic>{
        'rtpReceiverId': _id,
        'parameters': parameters.toMap()
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpReceiver::setParameters: ${e.message}';
    }
  }

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  RTCRtpParameters get parameters => _parameters;

  MediaStreamTrack get track => _track;

  String get receiverId => _id;

  Future<void> dispose() async {}
}
