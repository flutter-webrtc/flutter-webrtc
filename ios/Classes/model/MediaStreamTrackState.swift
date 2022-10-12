/// Representation of a `MediaStreamTrack` readiness.
enum MediaStreamTrackState: Int {
  /// Input is connected and does its best-effort in providing real-time data.
  case live

  /// Input is not giving any more data and will never provide new data.
  case ended
}
