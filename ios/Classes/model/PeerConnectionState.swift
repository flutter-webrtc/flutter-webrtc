import WebRTC

/// Representation of an `RTCPeerConnectionState`.
enum PeerConnectionState: Int {
  /// Any of the ICE transports or DTLS transports are in the `new` state and
  /// none of the transports are in the `connecting`, `checking`, `failed` or
  /// `disconnected` state, or all transports are in the `closed` state, or
  /// there are no transports.
  case new

  /// Any of the ICE transports or DTLS transports are in the `connecting` or
  /// `checking` state and none of them is in the `failed` state.
  case connecting

  /// All the ICE transports and DTLS transports are in the `connected`,
  /// `completed` or `closed` state, and at least one of them is in the
  /// `connected` or `completed` state.
  case connected

  /// Any of the ICE transports or DTLS transports are in the `disconnected`
  /// state, and none of them are in the `failed`, `connecting` or `checking`
  /// state.
  case disconnected

  /// Any of the ICE transports or DTLS transports are in the `failed` state.
  case failed

  /// Peer connection is closed.
  case closed

  /// Converts the provided `RTCPeerConnectionState` into a
  /// `PeerConnectionState`.
  static func fromWebRtc(state: RTCPeerConnectionState) -> PeerConnectionState {
    switch state {
    case .new:
      return PeerConnectionState.new
    case .connecting:
      return PeerConnectionState.connecting
    case .connected:
      return PeerConnectionState.connected
    case .disconnected:
      return PeerConnectionState.disconnected
    case .failed:
      return PeerConnectionState.failed
    case .closed:
      return PeerConnectionState.closed
    }
  }
}
