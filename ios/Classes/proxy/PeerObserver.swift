import Dispatch
import WebRTC

/// Observer for a native `RTCPeerConnectionDelegate`.
class PeerObserver: NSObject, RTCPeerConnectionDelegate {
  /// `PeerConnectionProxy` into which callbacks will be provided.
  var peer: PeerConnectionProxy?

  override init() {}

  /// Sets the underlying `PeerConnectionProxy` for this `PeerObserver`.
  func setPeer(peer: PeerConnectionProxy) {
    self.peer = peer
  }

  /// Fires an `onSignalingStateChange` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _: RTCPeerConnection, didChange stateChanged: RTCSignalingState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onSignalingStateChange(
        state: SignalingState.fromWebRtc(state: stateChanged)
      )
    }
  }

  /// Fires an `onIceConnectionStateChange` callback in the
  /// `PeerConnectionProxy`.
  func peerConnection(
    _: RTCPeerConnection, didChange newState: RTCIceConnectionState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceConnectionStateChange(
        state: IceConnectionState.fromWebRtc(state: newState)
      )
    }
  }

  /// Fires an `onConnectionStateChange` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _: RTCPeerConnection, didChange newState: RTCPeerConnectionState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onConnectionStateChange(
        state: PeerConnectionState.fromWebRtc(state: newState)
      )
    }
  }

  /// Fires an `onIceGatheringStateChange` callback in the
  /// `PeerConnectionProxy`.
  func peerConnection(
    _: RTCPeerConnection, didChange newState: RTCIceGatheringState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceGatheringStateChange(
        state: IceGatheringState.fromWebRtc(state: newState)
      )
    }
  }

  /// Fires an `onIceCandidate` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _: RTCPeerConnection, didGenerate candidate: RTCIceCandidate
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceCandidate(
        candidate: IceCandidate(candidate: candidate)
      )
    }
  }

  /// Fires an `onTrack` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver
  ) {
    DispatchQueue.main.async {
      let receiver = transceiver.receiver
      let track = receiver.track
      if track != nil {
        let transceivers = self.peer!.getTransceivers()
        for trans in transceivers {
          if trans.getReceiver().id() == receiver.receiverId {
            self.peer!.broadcastEventObserver().onTrack(
              track: trans.getReceiver().getTrack(),
              transceiver: trans
            )
          }
        }
      }
    }
  }

  /// Does nothing.
  func peerConnection(
    _: RTCPeerConnection, didAdd _: RTCRtpReceiver,
    streams _: [RTCMediaStream]
  ) {}

  /// Does nothing.
  func peerConnection(
    _: RTCPeerConnection, didRemove receiver: RTCRtpReceiver
  ) {
    DispatchQueue.main.async {
      self.peer!.receiverRemoved(endedReceiver: receiver)
    }
  }

  /// Does nothing.
  func peerConnection(_: RTCPeerConnection, didAdd _: RTCMediaStream) {}

  /// Does nothing.
  func peerConnection(_: RTCPeerConnection, didRemove _: RTCMediaStream) {}

  /// Does nothing.
  func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {}

  /// Does nothing.
  func peerConnectionShouldNegotiate(_: RTCPeerConnection) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onNegotiationNeeded()
    }
  }

  /// Does nothing.
  func peerConnection(
    _: RTCPeerConnection, didRemove _: [RTCIceCandidate]
  ) {}
}
