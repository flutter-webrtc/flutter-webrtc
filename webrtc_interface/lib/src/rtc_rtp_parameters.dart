// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:webrtc_interface/webrtc_interface.dart'; // For RTCMediaType (if defined there)

// Assuming RTCMediaType might be defined in a central place, or define locally if not.
// For now, let's assume it's available via the import.
// enum RTCMediaType { audio, video } // Placeholder if not imported

class RTCRtpCodecCapability {
  String? mimeType;
  int? clockRate;
  int? channels;
  String? sdpFmtpLine; // Common field for SDP format parameters
  String? profile; // New field for specific profile information

  RTCRtpCodecCapability({
    this.mimeType,
    this.clockRate,
    this.channels,
    this.sdpFmtpLine,
    this.profile,
  });

  factory RTCRtpCodecCapability.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpCodecCapability(
      mimeType: map['mimeType'] as String?,
      clockRate: map['clockRate'] as int?,
      channels: map['channels'] as int?,
      sdpFmtpLine: map['sdpFmtpLine'] as String?,
      profile: map['profile'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mimeType': mimeType,
      if (clockRate != null) 'clockRate': clockRate,
      if (channels != null) 'channels': channels,
      if (sdpFmtpLine != null) 'sdpFmtpLine': sdpFmtpLine,
      if (profile != null) 'profile': profile,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RTCRtpCodecCapability &&
        other.mimeType == mimeType &&
        other.clockRate == clockRate &&
        other.channels == channels &&
        other.sdpFmtpLine == sdpFmtpLine &&
        other.profile == profile;
  }

  @override
  int get hashCode =>
      mimeType.hashCode ^
      clockRate.hashCode ^
      channels.hashCode ^
      sdpFmtpLine.hashCode ^
      profile.hashCode;
}

class RTCRtpCodecParameters {
  String? name; // Corresponds to encoding name like "VP8"
  String? mimeType; // e.g., "video/VP8"
  RTCMediaType? kind; // audio or video - needs RTCMediaType enum
  int? payloadType;
  int? clockRate;
  int? numChannels;
  Map<String, String>? parameters; // For other codec-specific params like fmtp
  String? profile; // New field

  RTCRtpCodecParameters({
    this.name,
    this.mimeType,
    this.kind,
    this.payloadType,
    this.clockRate,
    this.numChannels,
    this.parameters,
    this.profile,
  });

  factory RTCRtpCodecParameters.fromMap(Map<dynamic, dynamic> map) {
    return RTCRtpCodecParameters(
      name: map['name'] as String?,
      mimeType: map['mimeType'] as String?,
      kind: map['kind'] != null ? RTCMediaTypeExtension.fromString(map['kind'] as String) : null,
      payloadType: map['payloadType'] as int?,
      clockRate: map['clockRate'] as int?,
      numChannels: map['numChannels'] as int?,
      parameters: (map['parameters'] as Map<dynamic, dynamic>?)
          ?.map((k, v) => MapEntry(k.toString(), v.toString())),
      profile: map['profile'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      'mimeType': mimeType,
      if (kind != null) 'kind': kind.toString().split('.').last, // Assuming RTCMediaType enum
      if (payloadType != null) 'payloadType': payloadType,
      if (clockRate != null) 'clockRate': clockRate,
      if (numChannels != null) 'numChannels': numChannels,
      if (parameters != null) 'parameters': parameters,
      if (profile != null) 'profile': profile,
    };
  }

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RTCRtpCodecParameters &&
        other.name == name &&
        other.mimeType == mimeType &&
        other.kind == kind &&
        other.payloadType == payloadType &&
        other.clockRate == clockRate &&
        other.numChannels == numChannels &&
        other.profile == profile &&
        other.parameters == parameters; // Note: map equality can be tricky
  }

  @override
  int get hashCode =>
      name.hashCode ^
      mimeType.hashCode ^
      kind.hashCode ^
      payloadType.hashCode ^
      clockRate.hashCode ^
      numChannels.hashCode ^
      profile.hashCode ^
      parameters.hashCode; // Note: map hashcode can be tricky
}

// Helper extension for RTCMediaType if not already globally available with fromString
// This is often part of webrtc_interface's type definitions.
// If it's defined elsewhere in webrtc_interface, this might be redundant or conflict.
/*
enum RTCMediaType {
  audio,
  video,
}
*/

extension RTCMediaTypeExtension on RTCMediaType {
  static RTCMediaType? fromString(String? value) {
    if (value == 'audio') {
      return RTCMediaType.audio;
    } else if (value == 'video') {
      return RTCMediaType.video;
    }
    return null;
  }
}
