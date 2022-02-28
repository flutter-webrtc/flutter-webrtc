/// Representation of a `MediaStreamTrack` readiness.
enum MediaStreamTrackState {
  /// Indicates that an input is connected and does its best-effort in the
  /// providing real-time data.
  live,

  /// Indicates that the input is not giving any more data and will never
  /// provide a new data.
  ended,
}

/// Kind of a media.
enum MediaKind {
  /// Audio data.
  audio,

  /// Video data.
  video
}
