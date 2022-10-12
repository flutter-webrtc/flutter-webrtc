import WebRTC

/// Representation of an `RTCIceGatheringState`.
enum IceGatheringState: Int {
  /// Peer connection was just created and hasn't done any networking yet.
  case new

  /// ICE agent is in the process of gathering candidates for the connection.
  case gathering

  /// ICE agent has finished gathering candidates. If something happens that
  /// requires collecting new candidates, such as a new interface being added or
  /// the addition of a new ICE server, the state will revert to `GATHERING` to
  /// gather those candidates.
  case complete

  /// Converts the provided `RTCIceGatheringState` into an `IceGatheringState`.
  static func fromWebRtc(state: RTCIceGatheringState) -> IceGatheringState {
    switch state {
    case .new:
      return IceGatheringState.new
    case .gathering:
      return IceGatheringState.gathering
    case .complete:
      return IceGatheringState.complete
    }
  }
}
