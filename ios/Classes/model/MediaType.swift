import WebRTC

/// Representation of an `RTCRtpMediaType`.
enum MediaType: Int {
  /// Audio media.
  case audio

  /// Video media.
  case video

  static func fromWebRtc(kind: RTCRtpMediaType)
    -> MediaType
  {
    switch kind {
    case .audio:
      return MediaType.audio
    case .video:
      return MediaType.video
    case .data:
      return MediaType.video
    case .unsupported:
      return MediaType.video
    }
  }

  /// Converts this `MediaType` into an `RTCRTPMediaType`.
  func intoWebRtc() -> RTCRtpMediaType {
    switch self {
    case .audio:
      return RTCRtpMediaType.audio
    case .video:
      return RTCRtpMediaType.video
    }
  }
}
