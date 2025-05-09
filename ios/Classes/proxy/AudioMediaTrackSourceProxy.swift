import WebRTC

/// Object representing a source of an input audio of the user.
///
/// This source can create new `MediaStreamTrackProxy`s with the same audio
/// source.
///
/// Also, this object will track all child `MediaStreamTrackProxy`s and once
/// they're all disposed, it disposes the underlying `AudioSource`.
class AudioMediaTrackSourceProxy: MediaTrackSource {
  /// Source `RTCMediaStreamTrack` to be used for new tracks creation.
  private var track: RTCMediaStreamTrack

  /// Initializes a new `AudioMediaTrackSourceProxy` based on the provided
  /// `RTCMediaStreamTrack`.
  init(track: RTCMediaStreamTrack) {
    self.track = track
  }

  /// Creates a new `MediaStreamTrackProxy`.
  func newTrack() -> MediaStreamTrackProxy {
    MediaStreamTrackProxy(track: self.track, deviceId: "audio", source: self)
  }
}
