import WebRTC

/// Wrapper around an `RTCRtpSender`, powering it with additional API.
class RtpSenderProxy {
  /// Actual underlying `RTCRtpSender`.
  private var sender: RTCRtpSender

  /// `MediaStreamTrackProxy` of this `RtpSenderProxy`.
  private var track: MediaStreamTrackProxy?

  /// Initializes a new `RtpSenderProxy` for the provided `RTCRtpSender`.
  init(sender: RTCRtpSender) {
    self.sender = sender
    self.syncMediaStreamTrack()
  }

  /// Returns ID of this `RtpSenderProxy`.
  func id() -> String {
    self.sender.senderId
  }

  /// Replaces the `MediaStreamTrackProxy` of the underlying `RTCRtpSender` with
  /// the provided one.
  func replaceTrack(t: MediaStreamTrackProxy?) {
    self.track = t
    self.sender.track = t?.obj()
  }

  /// Returns `RTCRtpParameters` of the underlying `RTCRtpSender`.
  func getParameters() -> RTCRtpParameters {
    return self.sender.parameters
  }

  /// Sets `RTCRtpParameters` of the underlying `RTCRtpSender` with the provided
  /// one.
  func setParameters(params: RTCRtpParameters) {
    self.sender.parameters = params
  }

  /// Synchronizes the `MediaStreamTrackProxy` of this `RtpSenderProxy` with the
  /// underlying `RTCRtpSender`.
  func syncMediaStreamTrack() {
    let newTrack = self.sender.track
    if newTrack == nil {
      self.track = nil
    } else {
      if self.track == nil {
        self.track = MediaStreamTrackProxy(
          track: newTrack!,
          deviceId: nil,
          source: nil
        )
      }
    }
  }
}
