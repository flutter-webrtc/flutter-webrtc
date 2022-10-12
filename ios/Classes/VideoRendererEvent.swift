/// Listener of all events emitted by a `FlutterRtcVideoRenderer`.
protocol VideoRendererEvent {
  /// Notifies about a first frame rendering.
  ///
  /// - Parameters:
  ///   - `id`: Unique ID of the texture which produced this event.
  func onFirstFrameRendered(id: Int64)

  /// Notifies about video size change.
  ///
  /// - Parameters:
  ///   - `id`: Unique ID of the texture which produced this event.
  ///   - `height`: New height of the video.
  ///   - `width`: New width of the video.
  func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32)

  /// Notifies about video rotation change.
  ///
  /// - Parameters:
  ///   - `id`: Unique ID of the texture producing this event.
  ///   - `rotation`: New rotation of the video.
  func onTextureChangeRotation(id: Int64, rotation: Int)
}
