import WebRTC

/// Representation of capabilities/preferences of an implementation for a header
/// extension of `RtpCapabilities`.
class HeaderExtensionCapability {
  /// URI of this extension, as defined in RFC 8285.
  var uri: String

  /// Preferred value of ID that goes in the packet.
  var preferredId: Int?

  /// If `true`, it's preferred that the value in the header is encrypted.
  var preferredEncrypted: Bool

  init(uri: String, preferredId: Int?, preferredEncrypted: Bool) {
    self.uri = uri
    self.preferredId = preferredId
    self.preferredEncrypted = preferredEncrypted
  }

  func asFlutterResult() -> [String: Any] {
    [
      "uri": self.uri,
      "preferredId": self.preferredId,
      "preferredEncrypted": self.preferredEncrypted,
    ]
  }
}

/// Representation of the static capabilities of an endpoint's implementation of
/// a codec.
class CodecCapability {
  /// Default payload type for the codec.
  ///
  /// Mainly needed for codecs that have statically assigned payload types.
  var preferredPayloadType: Int

  /// Used to identify the codec. Equivalent to MIME subtype.
  var name: String

  /// `MediaType` of this codec. Equivalent to MIME top-level type.
  var kind: MediaType

  /// If unset, the implementation default is used.
  var clockRate: Int

  /// Number of audio channels used.
  ///
  /// Unset for video codecs.
  ///
  /// If unset for audio, the implementation default is used.
  var numChannels: Int?

  /// Codec-specific parameters that must be signaled to the remote party.
  ///
  /// Corresponds to `a=fmtp` parameters in SDP.
  ///
  /// Contrary to ORTC, these parameters are named using all lowercase strings.
  /// This helps make the mapping to SDP simpler, if an application is using
  /// SDP.
  ///
  /// Boolean values are represented by the string "1".
  var parameters: [String: String]

  /// Built MIME "type/subtype" string from `name` and `kind`.
  var mimeType: String

  init(
    preferredPayloadType: Int,
    name: String,
    kind: MediaType,
    clockRate: Int,
    numChannels: Int?,
    parameters: [String: String],
    mimeType: String
  ) {
    self.preferredPayloadType = preferredPayloadType
    self.name = name
    self.kind = kind
    self.clockRate = clockRate
    self.numChannels = numChannels
    self.parameters = parameters
    self.mimeType = mimeType
  }

  func asFlutterResult() -> [String: Any] {
    [
      "preferredPayloadType": self.preferredPayloadType,
      "name": self.name,
      "kind": self.kind.rawValue,
      "clockRate": self.clockRate,
      "numChannels": self.numChannels,
      "parameters": self.parameters,
      "mimeType": self.mimeType,
    ]
  }
}

/// Representation of static capabilities of an endpoint.
///
/// Applications can use these capabilities to construct `RtpParameters`.
class RtpCapabilities {
  /// Supported codecs.
  var codecs: [CodecCapability]

  /// Supported RTP header extensions.
  var headerExtensions: [HeaderExtensionCapability]

  init(
    codecs: [CodecCapability],
    headerExtensions: [HeaderExtensionCapability]
  ) {
    self.codecs = codecs
    self.headerExtensions = headerExtensions
  }

  func asFlutterResult() -> [String: Any] {
    [
      "codecs": self.codecs.map { $0.asFlutterResult() },
      "headerExtensions": self.headerExtensions.map { $0.asFlutterResult() },
    ]
  }
}
