import WebRTC

/// Representation of an `RTCSignalingState`.
enum SignalingState: Int {
  /// There is no ongoing exchange of offer and answer underway.
  case stable

  /// Local peer has called `RTCPeerConnection.setLocalDescription()`.
  case haveLocalOffer

  /// Offer sent by the remote peer has been applied and an answer has been
  /// created.
  case haveLocalPrAnswer

  /// Remote peer has created an offer and used the signaling server to deliver
  /// it to the local peer, which has set the offer as the remote description by
  /// calling `PeerConnection.setRemoteDescription()`.
  case haveRemoteOffer

  /// Provisional answer has been received and successfully applied in response
  /// to the offer previously sent and established.
  case haveRemotePrAnswer

  /// Peer was closed.
  case closed

  /// Converts the provided `RTCSignalingState` into a `SignalingState`.
  static func fromWebRtc(state: RTCSignalingState) -> SignalingState {
    switch state {
    case .stable:
      return SignalingState.stable
    case .haveLocalOffer:
      return SignalingState.haveLocalOffer
    case .haveLocalPrAnswer:
      return SignalingState.haveLocalPrAnswer
    case .haveRemoteOffer:
      return SignalingState.haveRemoteOffer
    case .haveRemotePrAnswer:
      return SignalingState.haveRemotePrAnswer
    case .closed:
      return SignalingState.closed
    }
  }
}
