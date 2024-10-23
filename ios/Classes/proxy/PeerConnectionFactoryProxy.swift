import WebRTC

/// Returns `RtpCapabilities` based on the provided `RTCRtpCapabilities`.
private func rtpCapabilities(capabilities: RTCRtpCapabilities)
  -> RtpCapabilities
{
  return RtpCapabilities(
    codecs: capabilities.codecs.map { codec -> CodecCapability in
      var preferredPayloadType: Int = (codec.preferredPayloadType != nil) ?
        Int(codec.preferredPayloadType!) : 0
      var kind = MediaType.fromString(kind: codec.kind)!
      var clockRate = (codec.clockRate != nil) ? Int(codec.clockRate!) : 0
      var numChannels: Int? = (codec.numChannels != nil) ?
        Int(codec.numChannels!) : nil
      return CodecCapability(
        preferredPayloadType: preferredPayloadType,
        name: codec.name,
        kind: kind,
        clockRate: clockRate,
        numChannels: numChannels,
        parameters: codec.parameters,
        mimeType: codec.mimeType
      )
    },
    headerExtensions: capabilities.headerExtensions
      .map { header -> HeaderExtensionCapability in
        var preferredId =
          (header.preferredId != nil) ? Int(header.preferredId!) : nil
        return HeaderExtensionCapability(
          uri: header.uri,
          preferredId: preferredId,
          preferredEncrypted: header.isPreferredEncrypted
        )
      }
  )
}

/// Creator of new `PeerConnectionProxy`s.
class PeerConnectionFactoryProxy {
  /// Counter for generating new `PeerConnectionProxy` IDs.
  private var lastPeerConnectionId: Int = 0

  /// All the `PeerObserver`s created by this `PeerConnectionFactoryProxy`.
  ///
  /// `PeerObserver`s will be removed on a `PeerConnectionProxy` disposal.
  private var peerObservers: [Int: PeerObserver] = [:]

  /// Underlying native factory object of this factory.
  private var factory: RTCPeerConnectionFactory

  /// Initializes a new `PeerConnectionFactoryProxy` based on the provided
  /// `State`.
  init(state: State) {
    self.factory = state.getPeerFactory()
  }

  /// Returns sender capabilities of this factory.
  func rtpSenderCapabilities(kind: RTCRtpMediaType) -> RtpCapabilities {
    return rtpCapabilities(capabilities: self.factory
      .rtpSenderCapabilities(
        forKind: MediaType.fromWebRtc(kind: kind)!.toString()
      ))
  }

  /// Returns receiver capabilities of this factory.
  func rtpReceiverCapabilities(kind: RTCRtpMediaType) -> RtpCapabilities {
    return rtpCapabilities(capabilities: self.factory
      .rtpReceiverCapabilities(
        forKind: MediaType.fromWebRtc(kind: kind)!.toString()
      ))
  }

  /// Creates a new `PeerConnectionProxy` based on the provided
  /// `PeerConnectionConfiguration`.
  func create(conf: PeerConnectionConfiguration) -> PeerConnectionProxy {
    let id = self.nextId()

    let config = conf.intoWebRtc()
    let peerObserver = PeerObserver()
    let peer = self.factory.peerConnection(
      with: config,
      constraints: RTCMediaConstraints(
        mandatoryConstraints: [:],
        optionalConstraints: [:]
      ),
      delegate: peerObserver
    )
    let peerProxy = PeerConnectionProxy(id: id, peer: peer!)
    peerObserver.setPeer(peer: peerProxy)

    self.peerObservers[id] = peerObserver

    return peerProxy
  }

  /// Removes the specified `PeerObserver` from the `peerObservers`.
  private func remotePeerObserver(id: Int) {
    self.peerObservers.removeValue(forKey: id)
  }

  /// Generates the next track ID.
  private func nextId() -> Int {
    self.lastPeerConnectionId += 1
    return self.lastPeerConnectionId
  }
}
