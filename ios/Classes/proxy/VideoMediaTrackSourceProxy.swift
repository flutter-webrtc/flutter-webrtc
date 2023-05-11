import WebRTC

/// Source of an input video of a user.
///
/// This source can create new `MediaStreamTrackProxy`s with the same video
/// source.
///
/// Also, this object will track all the child `MediaStreamTrackProxy`s and once
/// they're all disposed, it disposes the underlying `VideoSource`.
class VideoMediaTrackSourceProxy: MediaTrackSource {
  /// `PeerConnectionFactoryProxy` to create new `MediaStreamTrackProxy`s with.
  private var peerConnectionFactory: RTCPeerConnectionFactory

  /// Actual underlying `RTCVideoSource`.
  private var source: RTCVideoSource

  /// `VideoCapturer` used in the `RTCVideoSource`.
  private var capturer: RTCCameraVideoCapturer

  /// Unique device ID of the provided `VideoMediaTrackSourceProxy`.
  private var deviceId: String

  /// Count of all alive `MediaStreamTrackProxy`s created from this source.
  private var tracksCount: Int = 0

  /// `FacingMode` of the track.
  private var facingMode: FacingMode

  /// Initializes a new `VideoMediaTrackSourceProxy`.
  init(
    peerConnectionFactory: RTCPeerConnectionFactory,
    source: RTCVideoSource,
    position: AVCaptureDevice.Position,
    deviceId: String,
    capturer: RTCCameraVideoCapturer
  ) {
    self.peerConnectionFactory = peerConnectionFactory
    self.source = source
    switch position {
    case AVCaptureDevice.Position.front:
      self.facingMode = FacingMode.user
    case AVCaptureDevice.Position.back:
      self.facingMode = FacingMode.environment
    case AVCaptureDevice.Position.unspecified:
      self.facingMode = FacingMode.environment
    }
    self.deviceId = deviceId
    self.capturer = capturer
  }

  /// Returns `FacingMode` of this `VideoMediaTrackSourceProxy`.
  func getFacingMode() -> FacingMode {
    return self.facingMode
  }

  /// Creates a new `MediaStreamTrackProxy` with the underlying
  /// `VideoMediaTrackSourceProxy`.
  func newTrack() -> MediaStreamTrackProxy {
    let track = self.peerConnectionFactory.videoTrack(
      with: self.source, trackId: LocalTrackIdGenerator.shared.nextId()
    )
    let trackProxy = MediaStreamTrackProxy(
      track: track,
      deviceId: self.deviceId,
      source: self
    )
    self.tracksCount += 1
    trackProxy.onStopped(cb: {
      self.tracksCount -= 1
      if self.tracksCount == 0 {
        self.capturer.stopCapture()
      }
    })
    return trackProxy
  }
}
