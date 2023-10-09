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
  ///   - `rotation`: New rotation of the video.
  func onTextureChange(id: Int64, height: Int32, width: Int32, rotation: Int)
}
