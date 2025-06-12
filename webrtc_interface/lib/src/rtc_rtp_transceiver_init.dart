import 'package:webrtc_interface/webrtc_interface.dart'; // For RTCRtpEncodingParameters, RTCRtpTransceiverDirection
// RTCRtpCodecCapability is in rtc_rtp_parameters.dart
import 'rtc_rtp_parameters.dart';

class RTCRtpTransceiverInit {
  RTCRtpTransceiverDirection? direction;
  List<MediaStream>? streams; // MediaStream needs to be defined or imported
  List<RTCRtpEncodingParameters>? sendEncodings; // RTCRtpEncodingParameters needs to be defined or imported
  List<RTCRtpCodecCapability>? preferredCodecs; // New field

  RTCRtpTransceiverInit({
    this.direction,
    this.streams,
    this.sendEncodings,
    this.preferredCodecs,
  });

  factory RTCRtpTransceiverInit.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpTransceiverInit(
      direction: map['direction'] != null
          ? RTCRtpTransceiverDirectionExtension.fromString(map['direction'])
          : null,
      streams: (map['streams'] as List<dynamic>?)
          ?.map((e) => MediaStream.fromMap(e as Map<dynamic,dynamic>)) // Assuming MediaStream.fromMap
          .toList(),
      sendEncodings: (map['sendEncodings'] as List<dynamic>?)
          ?.map((e) => RTCRtpEncodingParameters.fromMap(e as Map<dynamic,dynamic>)) // Assuming RTCRtpEncodingParameters.fromMap
          .toList(),
      preferredCodecs: (map['preferredCodecs'] as List<dynamic>?)
          ?.map((e) => RTCRtpCodecCapability.fromMap(e as Map<dynamic,dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (direction != null) 'direction': direction.toString().split('.').last,
      if (streams != null)
        'streamIds': streams!.map((stream) => stream.id).toList(), // Native side often expects streamIds
      if (sendEncodings != null)
        'sendEncodings': sendEncodings!.map((e) => e.toMap()).toList(),
      if (preferredCodecs != null)
        'preferredCodecs': preferredCodecs!.map((e) => e.toMap()).toList(),
    };
  }
}

// Assuming RTCRtpTransceiverDirection, MediaStream, RTCRtpEncodingParameters are defined elsewhere
// in webrtc_interface package and provide necessary fromMap/toMap and string conversions.
// For RTCRtpTransceiverDirection.fromString:
/*
enum RTCRtpTransceiverDirection {
  sendRecv,
  sendOnly,
  recvOnly,
  inactive,
  stopped // Note: 'stopped' might not be settable in init, usually a state.
}
*/
extension RTCRtpTransceiverDirectionExtension on RTCRtpTransceiverDirection {
  static RTCRtpTransceiverDirection fromString(String? direction) {
    switch (direction) {
      case 'sendrecv':
        return RTCRtpTransceiverDirection.SendRecv;
      case 'sendonly':
        return RTCRtpTransceiverDirection.SendOnly;
      case 'recvonly':
        return RTCRtpTransceiverDirection.RecvOnly;
      case 'inactive':
        return RTCRtpTransceiverDirection.Inactive;
      // 'stopped' is typically a state, not a direction to set in Init.
      // Defaulting to inactive if string is unknown or 'stopped'.
      default:
        return RTCRtpTransceiverDirection.Inactive;
    }
  }
}
