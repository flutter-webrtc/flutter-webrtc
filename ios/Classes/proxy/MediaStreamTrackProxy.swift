import WebRTC

/// Wrapper around a `MediaStreamTrack`, powering it with additional API.
class MediaStreamTrackProxy: Equatable {
  /// Indicator whether the `stop()` was called on this `MediaStreamTrackProxy`.
  private var isStopped = false

  /// Device ID of this `MediaStreamTrackProxy`.
  private var deviceId = "remote"

  /// Source of this `MediaStreamTrackProxy`.
  private var source: MediaTrackSource?

  /// Underlying `RTCMediaStreamTrack`.
  private var track: RTCMediaStreamTrack

  /// Subscribers for `onStop` callback of this `MediaStreamTrackProxy`.
  private var onStopSubscribers: [() -> Void] = []

  /// Subscribers for `onEnded` callback of this `MediaStreamTrackProxy`.
  private var onEndedSubscribers: [() -> Void] = []

  /// `RTCVideoRenderer` that tracks video track height and width changes.
  private var dimensionsSink: VideoTrackDimensionsSink?

  /// `RTCVideoRenderer` that tracks video track height and width changes.
  class VideoTrackDimensionsSink: NSObject, RTCVideoRenderer {
    /// Lock that protects width and height.
    let cond = NSCondition()

    /// Latest video frame width.
    var width: Int?

    /// Latest video frame height.
    var height: Int?

    /// Blocks current thread until width and height values are set, should
    /// be called before accessing these values to ensure correct
    /// synchronization.
    func waitForVideoDimensions() {
      self.cond.lock()
      while self.width == nil || self.height == nil {
        self.cond.wait()
      }
      self.cond.unlock()
    }

    /// Fetches width and height values
    func renderFrame(_ renderFrame: RTCVideoFrame?) {
      let width = Int(renderFrame!.buffer.width)
      let height = Int(renderFrame!.buffer.height)

      if height == 0 || width == 0 {
        return
      }

      self.cond.lock()

      self.width = width
      self.height = height

      self.cond.broadcast()
      self.cond.unlock()
    }

    func setSize(_: CGSize) {}
  }

  /// Initializes a new `MediaStreamTrackProxy` based on the provided data.
  init(
    track: RTCMediaStreamTrack,
    deviceId: String?,
    source: MediaTrackSource?
  ) {
    self.source = source
    if deviceId != nil {
      self.deviceId = deviceId!
    }
    self.track = track
    MediaStreamTrackStore.tracks[track.trackId] = self

    if track.kind == "video" {
      self.dimensionsSink = VideoTrackDimensionsSink()
      let videoTrack = self.track as! RTCVideoTrack
      videoTrack.add(self.dimensionsSink!)
    }
  }

  /// Compares two `MediaStreamTrackProxy`s based on underlying
  /// `RTCMediaStreamTrack`s.
  static func == (lhs: MediaStreamTrackProxy,
                  rhs: MediaStreamTrackProxy) -> Bool
  {
    lhs.track == rhs.track
  }

  /// Adds the specified `RTCVideoRenderer` to the underlying
  /// `RTCMediaStreamTrack`.
  func addRenderer(renderer: RTCVideoRenderer) {
    let videoTrack = self.track as! RTCVideoTrack
    videoTrack.add(renderer)
  }

  /// Removes the specified `RTCVideoRenderer` from the underlying
  /// `RTCMediaStreamTrack`.
  func removeRenderer(renderer: RTCVideoRenderer) {
    let videoTrack = self.track as! RTCVideoTrack
    videoTrack.remove(renderer)
  }

  /// Returns ID of this track.
  func id() -> String {
    self.track.trackId
  }

  /// Returns `MediaType` of this track.
  func kind() -> MediaType {
    let kind = self.track.kind
    switch kind {
    case "audio":
      return MediaType.audio
    case "video":
      return MediaType.video
    default:
      abort()
    }
  }

  /// Returns latest frame width if this is a video track or nil otherwise.
  func getWidth() async -> Int? {
    if self.dimensionsSink == nil {
      return nil
    } else {
      let task = Task.detached {
        self.dimensionsSink!.waitForVideoDimensions()
        return self.dimensionsSink!.width!
      }
      return await task.get()
    }
  }

  /// Returns latest frame height if this is a video track or nil otherwise.
  func getHeight() async -> Int? {
    if self.dimensionsSink == nil {
      return nil
    } else {
      let task = Task.detached {
        self.dimensionsSink!.waitForVideoDimensions()
        return self.dimensionsSink!.height!
      }
      return await task.get()
    }
  }

  /// Returns `FacingMode` of this `MediaStreamTrackProxy`.
  ///
  /// Returns `nil` if it's an audio track.
  func getFacingMode() -> FacingMode? {
    let source = self.source as? VideoMediaTrackSourceProxy
    if source != nil {
      return source!.getFacingMode()
    } else {
      return nil
    }
  }

  /// Returns device ID of this track.
  func getDeviceId() -> String {
    self.deviceId
  }

  /// Returns a forked `MediaStreamTrackProxy` based on the same source as this
  /// track has.
  func fork() throws -> MediaStreamTrackProxy {
    if self.source == nil {
      throw MediaStreamTrackException.remoteTrackCantBeCloned
    } else {
      return self.source!.newTrack()
    }
  }

  /// Stops this track.
  ///
  /// Source will be stopped and disposed once all its tracks are stopped.
  func stop() {
    self.isStopped = true
    for cb in self.onStopSubscribers {
      cb()
    }
  }

  /// Returns the current `readyState` of this track.
  func state() -> MediaStreamTrackState {
    let state = self.track.readyState
    switch state {
    case .live:
      return MediaStreamTrackState.live
    case .ended:
      return MediaStreamTrackState.ended
    default:
      abort()
    }
  }

  /// Sets `enabled` state of this track.
  func setEnabled(enabled: Bool) {
    self.track.isEnabled = enabled
  }

  /// Subscribes to `onStopped` callback of this track.
  func onStopped(cb: @escaping () -> Void) {
    self.onStopSubscribers.append(cb)
  }

  /// Notifies `RtpReceiverProxy` about its `MediaStreamTrackProxy` being
  /// removed from the receiver.
  func notifyEnded() {
    if self.track.readyState == .ended {
      for cb in self.onEndedSubscribers {
        cb()
      }
    }
  }

  /// Subscribes to `onEnded` callback of this track.
  func onEnded(cb: @escaping () -> Void) {
    self.onEndedSubscribers.append(cb)
  }

  /// Returns the underlying `RTCMediaStreamTrack` of this proxy.
  func obj() -> RTCMediaStreamTrack {
    self.track
  }
}
