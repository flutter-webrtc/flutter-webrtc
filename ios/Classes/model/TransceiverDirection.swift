import WebRTC

/// Representation of an `RTCRtpTransceiverDirection`.
enum TransceiverDirection: Int {
  /// Transceiver is both sending to and receiving from the remote peer
  /// connection.
  case sendRecv

  /// Transceiver is sending to the remote peer, but is not receiving any media
  /// from the remote peer.
  case sendOnly

  /// Transceiver is receiving from the remote peer, but is not sending any
  /// media to the remote peer.
  case recvOnly

  /// Transceiver is inactive, neither sending nor receiving any media data.
  case inactive

  /// Transceiver is stopped.
  case stopped

  /// Converts the provided `RTCRtpTransceiverDirection` into an
  /// `RtpTransceiverDirection`.
  static func fromWebRtc(direction: RTCRtpTransceiverDirection)
    -> TransceiverDirection
  {
    switch direction {
    case .sendRecv:
      return TransceiverDirection.sendRecv
    case .sendOnly:
      return TransceiverDirection.sendOnly
    case .recvOnly:
      return TransceiverDirection.recvOnly
    case .inactive:
      return TransceiverDirection.inactive
    case .stopped:
      return TransceiverDirection.stopped
    }
  }

  /// Converts this `RtpTransceiverDirection` into an
  /// `RTCRtpTransceiverDirection`.
  func intoWebRtc() -> RTCRtpTransceiverDirection {
    switch self {
    case .sendRecv:
      return RTCRtpTransceiverDirection.sendRecv
    case .sendOnly:
      return RTCRtpTransceiverDirection.sendOnly
    case .recvOnly:
      return RTCRtpTransceiverDirection.recvOnly
    case .inactive:
      return RTCRtpTransceiverDirection.inactive
    case .stopped:
      return RTCRtpTransceiverDirection.stopped
    }
  }
}
