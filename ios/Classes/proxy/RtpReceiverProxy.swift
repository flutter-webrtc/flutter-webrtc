import WebRTC

/// Wrapper around an `RTCRtpReceiver`, powering it with additional API.
class RtpReceiverProxy {
  /// Actual underlying [RtpReceiver].
  private var receiver: RTCRtpReceiver

  /// `MediaStreamTrackProxy` of this `RtpReceiverProxy`.
  private var track: MediaStreamTrackProxy

  /// Initializes a new `RtpReceiverProxy` with the provided `RTCRtpReceiver`.
  init(receiver: RTCRtpReceiver) {
    self.receiver = receiver
    self.track = MediaStreamTrackProxy(
      track: self.receiver.track!,
      deviceId: nil,
      source: nil
    )
  }

  /// Returns ID of this `RtpReceiverProxy`.
  func id() -> String {
    self.receiver.receiverId
  }

  /// Returns `MediaStreamTrackProxy` of this `RtpReceiverProxy`.
  func getTrack() -> MediaStreamTrackProxy {
    self.track
  }

  /// Notifies `RtpReceiverProxy` about its `MediaStreamTrackProxy` being
  /// removed from the receiver.
  func notifyRemoved() {
    self.track.notifyEnded()
  }
}
