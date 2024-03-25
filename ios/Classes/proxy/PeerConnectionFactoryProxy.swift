import WebRTC

/// Creator of new `PeerConnectionProxy`s.
class PeerConnectionFactoryProxy {
  /// Counter for generating new [PeerConnectionProxy] IDs.
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
    var capabilities = self.factory
      .rtpSenderCapabilities(for: kind)

    return RtpCapabilities(
      codecs: capabilities.codecs.map { codec -> CodecCapability in
        var preferredPayloadType: Int = (codec.preferredPayloadType != nil) ?
          Int(codec.preferredPayloadType!) : 0
        var kind = MediaType.fromWebRtc(kind: codec.kind)
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
      headerExtensions: capabilities.header_extensions
        .map { header -> HeaderExtensionCapability in
          var preferredId = Int(header.preferred_id)
          return HeaderExtensionCapability(
            uri: header.uri,
            preferredId: preferredId,
            preferredEncrypted: header.preferred_encrypt
          )
        }
    )
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

  /// Removes the specified [PeerObserver] from the [peerObservers].
  private func remotePeerObserver(id: Int) {
    self.peerObservers.removeValue(forKey: id)
  }

  /// Generates the next track ID.
  private func nextId() -> Int {
    self.lastPeerConnectionId += 1
    return self.lastPeerConnectionId
  }
}
