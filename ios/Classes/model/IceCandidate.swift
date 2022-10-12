import WebRTC

/// Representation of an `RTCIceCandidate`.
class IceCandidate {
  /// mID of this `IceCandidate`.
  var sdpMid: String

  /// `sdpMLineIndex` of this `IceCandidate`.
  var sdpMLineIndex: Int

  /// `candidate` of this `IceCandidate`.
  var candidate: String

  /// Initializes a new `IceCandidate` based on the method call received from
  /// Flutter side.
  init(candidate: RTCIceCandidate) {
    self.sdpMid = candidate.sdpMid!
    self.candidate = candidate.sdp
    self.sdpMLineIndex = Int(candidate.sdpMLineIndex)
  }

  /// Initializes a new `IceCandidate` with the provided data.
  init(sdpMid: String, sdpMLineIndex: Int, candidate: String) {
    self.sdpMid = sdpMid
    self.sdpMLineIndex = sdpMLineIndex
    self.candidate = candidate
  }

  /// Converts this `IceCandidate` into an `RTCIceCandidate`.
  func intoWebRtc() -> RTCIceCandidate {
    RTCIceCandidate(
      sdp: self.candidate, sdpMLineIndex: Int32(self.sdpMLineIndex),
      sdpMid: self.sdpMid
    )
  }

  /// Converts this `IceCandidate` into a `Dictionary` which can be returned to
  /// Flutter side.
  func asFlutterResult() -> [String: Any] {
    [
      "sdpMid": self.sdpMid,
      "sdpMLineIndex": self.sdpMLineIndex,
      "candidate": self.candidate,
    ]
  }
}
