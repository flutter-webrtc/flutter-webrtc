import WebRTC

/// Global context of the `medea_flutter_webrtc` plugin.
///
/// Used for creating tracks/peers.
class State {
  /// Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
  private var factory: RTCPeerConnectionFactory

  /// Initializes a new `State`.
  init() {
    let decoderFactory = RTCDefaultVideoDecoderFactory()
    let encoderFactory = RTCDefaultVideoEncoderFactory()
    self.factory = RTCPeerConnectionFactory(
      encoderFactory: encoderFactory, decoderFactory: decoderFactory
    )
  }

  /// Returns the `RTCPeerConnectionFactory` of this `State`.
  func getPeerFactory() -> RTCPeerConnectionFactory {
    self.factory
  }
}
