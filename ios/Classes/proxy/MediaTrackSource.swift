/// Creator of new `MediaStreamTrackProxy`s from some media device.
protocol MediaTrackSource {
  /// Creates a new `MediaStreamTrackProxy` based on its `MediaTrackSource`.
  func newTrack() -> MediaStreamTrackProxy
}
