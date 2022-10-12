import WebRTC

/// Representation of an `RTCIceConnectionState`.
enum IceConnectionState: Int {
  /// ICE agent is gathering addresses or is waiting to be given remote
  /// candidates through calls to `PeerConnection.addIceCandidate()` (or both).
  case new

  /// ICE agent has been given one or more remote candidates and is checking
  /// pairs of local and remote candidates against one another to try to find a
  /// compatible match, but hasn't yet found a pair which will allow the peer
  /// connection to be made. It's possible that gathering of candidates is also
  /// still underway.
  case checking

  /// Usable pairing of local and remote candidates has been found for all
  /// components of the connection, and the connection has been established.
  /// It's possible that gathering is still underway, and it's also possible
  /// that the ICE agent is still checking candidates against one another
  /// looking for a better connection to use.
  case connected

  /// ICE agent has finished gathering candidates, has checked all pairs against
  /// one another, and has found a connection for all components.
  case completed

  /// ICE candidate has checked all candidates pairs against one another and has
  /// failed to find compatible matches for all components of the connection.
  /// It's, however, possible that the ICE agent did find compatible connections
  /// for some components.
  case failed

  /// Checks to ensure that components are still connected failed for at least
  /// one component of the `PeerConnection`. This is a less stringent test than
  /// `FAILED` and may trigger intermittently and resolve just as spontaneously
  /// on less reliable networks, or during temporary disconnections. When the
  /// problem resolves, the connection may return to the `CONNECTED` state.
  case disconnected

  /// ICE agent has shut down and is no longer handling requests.
  case closed

  /// Converts the provided `RTCIceConnectionState` into an
  /// `IceConnectionState`.
  static func fromWebRtc(state: RTCIceConnectionState) -> IceConnectionState {
    switch state {
    case .new:
      return IceConnectionState.new
    case .checking:
      return IceConnectionState.checking
    case .connected:
      return IceConnectionState.connected
    case .completed:
      return IceConnectionState.completed
    case .failed:
      return IceConnectionState.failed
    case .disconnected:
      return IceConnectionState.disconnected
    case .closed:
      return IceConnectionState.closed
    case .count:
      // https://tinyurl.com/kIceConnectionMax-unreachable
      abort()
    }
  }
}
