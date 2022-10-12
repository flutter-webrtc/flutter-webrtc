/// Possible errors regarding a `MediaStreamTrack`.
enum MediaStreamTrackException: Error {
  /// `MediaStreamTrack` cannot be cloned.
  case remoteTrackCantBeCloned
}
