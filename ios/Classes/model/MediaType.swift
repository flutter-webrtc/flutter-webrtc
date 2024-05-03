import WebRTC

/// Representation of an `RTCRtpMediaType`.
enum MediaType: Int {
  /// Audio media.
  case audio

  /// Video media.
  case video

  /// Converts the provided `RTCRtpMediaType` into a `MediaType`.
  static func fromWebRtc(kind: RTCRtpMediaType) -> MediaType? {
    switch kind {
    case .audio:
      return MediaType.audio
    case .video:
      return MediaType.video
    default:
      return nil
    }
  }

  /// Creates this `RTCRTPMediaType` from `String`.
  static func fromString(kind: String) -> MediaType? {
    switch kind {
    case "audio":
      return MediaType.audio
    case "video":
      return MediaType.video
    default:
      return nil
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

  /// Converts this `MediaType` into a `String`.
  func toString() -> String {
    switch self {
    case .audio:
      return "audio"
    case .video:
      return "video"
    }
  }
}
