import WebRTC

/// Representation of an `RTCRtpTransceiverInit` configuration.
class TransceiverInit {
  /// Direction of the transceiver, created from this configuration.
  private var direction: TransceiverDirection

  /// Initializes a new `TransceiverInit` configuration with the provided data.
  init(direction: TransceiverDirection) {
    self.direction = direction
  }

  /// Converts this `RtpTransceiverInit` into an `RTCRtpTransceiverInit`.
  func intoWebRtc() -> RTCRtpTransceiverInit {
    let conf = RTCRtpTransceiverInit()
    conf.direction = self.direction.intoWebRtc()
    return conf
  }
}

/// Representation of an [RTCIceTransportPolicy].
enum IceTransportType: Int {
  /// Offer all types of ICE candidates.
  case all

  /// Only advertise relay-type candidates, like TURN servers, to avoid leaking
  /// IP addresses of the client.
  case relay

  /// Gather all ICE candidate types except host candidates.
  case noHost

  /// No ICE candidate offered.
  case none

  /// Converts this `IceTransportType` into an `RTCIceTransportsType`.
  func intoWebRtc() -> RTCIceTransportPolicy {
    switch self {
    case .all:
      return RTCIceTransportPolicy.all
    case .relay:
      return RTCIceTransportPolicy.relay
    case .noHost:
      return RTCIceTransportPolicy.noHost
    case .none:
      return RTCIceTransportPolicy.none
    }
  }
}

/// Representation of an [RTCIceServer].
class IceServer {
  /// List of URLs of this [IceServer].
  private var urls: [String]

  /// Username for authentication on this [IceServer].
  private var username: String?

  /// Password for authentication on this [IceServer].
  private var password: String?

  /// Initializes a new `IceServer` with the provided data.
  init(urls: [String], username: String?, password: String?) {
    self.urls = urls
    self.username = username
    self.password = password
  }

  /// Converts this `IceServer` into an `RTCIceServer`.
  func intoWebRtc() -> RTCIceServer {
    RTCIceServer(
      urlStrings: self.urls,
      username: self.username,
      credential: self.password
    )
  }
}

/// Representation of an [RTCConfiguration].
class PeerConnectionConfiguration {
  /// List of `IceServer`s, used by the `PeerConnection` created with this
  /// `PeerConnectionConfiguration`.
  var iceServers: [IceServer]

  /// Type of the ICE transport, used by the `PeerConnection` created with this
  /// `PeerConnectionConfiguration`.
  var iceTransportType: IceTransportType

  /// Initializes a new `PeerConnectionConfiguration` based on the provided
  /// data.
  init(iceServers: [IceServer], iceTransportType: IceTransportType) {
    self.iceServers = iceServers
    self.iceTransportType = iceTransportType
  }

  /// Converts this `PeerConnectionConfiguration` into an `RTCConfiguration`.
  func intoWebRtc() -> RTCConfiguration {
    let conf = RTCConfiguration()
    conf.iceServers = self.iceServers.map { serv -> RTCIceServer in
      serv.intoWebRtc()
    }
    conf.iceTransportPolicy = self.iceTransportType.intoWebRtc()
    conf.sdpSemantics = RTCSdpSemantics.unifiedPlan
    return conf
  }
}
