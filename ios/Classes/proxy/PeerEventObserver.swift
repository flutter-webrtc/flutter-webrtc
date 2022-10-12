/// Observer of `PeerConnectionProxy` events.
protocol PeerEventObserver {
  /// Notifies this observer about a new `MediaStreamTrackProxy`.
  ///
  /// - Parameters:
  ///   - `track`: Newly added `MediaStreamTrackProxy`.
  ///   - `transceiver`: `RtpTransceiverProxy` of this `MediaStreamTrackProxy`.
  func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy)

  /// Notifies this observer about an `IceConnectionState` update.
  ///
  /// - Parameters:
  ///   - `iceConnectionState`: New `IceConnectionState` of the
  ///                           `PeerConnectionProxy`.
  func onIceConnectionStateChange(state: IceConnectionState)

  /// Notifies this observer about a `SignalingState` update.
  ///
  /// - Parameters:
  ///   - `signalingState`: New `SignalingState` of the `PeerConnectionProxy`.
  func onSignalingStateChange(state: SignalingState)

  /// Notifies this observer about a `PeerConnectionState` update.
  ///
  /// - Parameters:
  ///   - `peerConnectionState`: New `PeerConnectionState` of the
  ///                            `PeerConnectionProxy`.
  func onConnectionStateChange(state: PeerConnectionState)

  /// Notifies this observer about an `IceGatheringState` update.
  ///
  /// - Parameters:
  ///   - `iceGatheringState`: New `IceGatheringState` of the
  ///                          `PeerConnectionProxy`.
  func onIceGatheringStateChange(state: IceGatheringState)

  /// Notifies this observer about a new `IceCandidate`.
  ///
  /// - Parameters:
  ///   - `candidate`: Newly added `IceCandidate`.
  func onIceCandidate(candidate: IceCandidate)

  /// Notifies this observer about the necessity to perform a new renegotiation
  /// process.
  func onNegotiationNeeded()
}
