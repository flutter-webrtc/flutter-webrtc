enum RTCBundlePolicy {
  /// Gather ICE candidates for each media type in use (audio, video, and data).
  /// If the remote endpoint is not bundle-aware, it will offer to bundle RTCP
  /// with data and video with audio.
  balanced,

  /// Gather ICE candidates for each media type. If the remote endpoint is not
  /// bundle-aware, it will offer to bundle RTCP with data and video with audio.
  maxCompat,

  /// Gather ICE candidates for only one track. If the remote endpoint is not
  /// bundle-aware, this will cause a session failure.
  maxBundle,
}
