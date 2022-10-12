import WebRTC

/// Representation of an `RTCSessionDescription`.
class SessionDescription {
  /// Type of this [SessionDescription].
  private var type: SessionDescriptionType

  /// Description SDP of this [SessionDescription].
  private var description: String

  /// Initializes a new `SessionDescription` with the provided data.
  init(type: SessionDescriptionType, description: String) {
    self.type = type
    self.description = description
  }

  /// Initializes a new `SessionDescription` out of the provided
  /// `RTCSessionDescription`.
  init(sdp: RTCSessionDescription) {
    self.type = SessionDescriptionType(type: sdp.type)
    self.description = sdp.sdp
  }

  /// Initializes a new `SessionDescription` based on the method call received
  /// from Flutter side.
  init(map: [String: Any]) {
    let ty = map["type"] as? Int
    self.type = SessionDescriptionType(rawValue: ty!)!
    let description = map["description"] as? String
    self.description = description!
  }

  /// Converts this `SessionDescription` into an `RTCSessionDescription`.
  func intoWebRtc() -> RTCSessionDescription {
    RTCSessionDescription(type: self.type.intoWebRtc(), sdp: self.description)
  }

  /// Converts this `SessionDescription` into a `Dictionary` which can be
  /// returned to Flutter side.
  func asFlutterResult() -> [String: Any] {
    [
      "type": self.type.rawValue,
      "description": self.description,
    ]
  }
}
