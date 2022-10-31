import Flutter
import WebRTC

/// Renderer of video from a track to a `FlutterTexture` which can be shown by
/// Flutter side.
class FlutterRtcVideoRenderer: NSObject, FlutterTexture, RTCVideoRenderer {
  /// Track which is rendered by this `FlutterRtcVideoRenderer`.
  private var track: MediaStreamTrackProxy?

  /// ID of the `FlutterTexture` on which this `FlutterRtcVideoRenderer` renders
  /// the track.
  private var textureId: Int64 = 0

  /// Pixel buffer into which video will be rendered from the track.
  private var pixelBuffer: CVPixelBuffer?

  /// Last known frame size based on the `setSize()` method call.
  private var frameSize: CGSize

  /// Registry for registering new `FlutterTexture`s.
  private var registry: FlutterTextureRegistry

  /// Observers of the `FlutterRtcVideoRenderer` events.
  private var observers: [VideoRendererEvent] = []

  /// Indicator whether a first frame was rendered by this
  /// `FlutterRtcVideoRenderer`.
  private var isFirstFrameRendered: Bool = false

  /// Last known width of the frame provided by `libwebrtc` to the
  /// `renderFrame()` method.
  private var frameWidth: Int32 = 0

  /// Last known height of the frame provided by `libwebrtc` to the
  /// `renderFrame()` method.
  private var frameHeight: Int32 = 0

  /// Last known rotation of the frame provided by libwebrtc to the
  /// `renderFrame()` method.
  private var frameRotation: Int = -1

  /// Indicator whether the `FlutterRtcVideoRenderer` is stopped.
  private var isRendererStopped: Bool = false

  /// Lock for the `renderFrame()` function.
  ///
  /// This lock is locked when some frame is currently rendering or the
  /// `FlutterRtcVideoRenderer` in process of stopping.
  private let rendererLock: NSLock = .init()

  /// Initializes a new `FlutterRtcVideoRenderer`.
  init(registry: FlutterTextureRegistry) {
    self.frameSize = CGSize()
    self.registry = registry
    super.init()
    let textureId = registry.register(self)
    self.textureId = textureId
  }

  /// Subscribes the provided `VideoRendererEvent` to this
  /// `FlutterRtcVideoRenderer` events.
  func subscribe(sub: VideoRendererEvent) {
    self.observers.append(sub)
  }

  /// Returns an observer which will send provided events to all the observers
  /// of this renderer.
  func broadcastEventObserver() -> VideoRendererEvent {
    class BroadcastEventObserver: VideoRendererEvent {
      private var observers: [VideoRendererEvent]

      init(observers: [VideoRendererEvent]) {
        self.observers = observers
      }

      func onFirstFrameRendered(id: Int64) {
        for observer in self.observers {
          observer.onFirstFrameRendered(id: id)
        }
      }

      func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32) {
        for observer in self.observers {
          observer.onTextureChangeVideoSize(
            id: id,
            height: height,
            width: width
          )
        }
      }

      func onTextureChangeRotation(id: Int64, rotation: Int) {
        for observer in self.observers {
          observer.onTextureChangeRotation(id: id, rotation: rotation)
        }
      }
    }

    return BroadcastEventObserver(observers: self.observers)
  }

  /// Returns `FlutterTexture` ID of this renderer.
  func getTextureId() -> Int64 {
    self.textureId
  }

  /// Returns `CVPixelBuffer` with frame video data in it.
  ///
  /// Returns `nil` if no frames are available.
  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    if self.pixelBuffer == nil {
      return nil
    }
    return Unmanaged<CVPixelBuffer>.passRetained(self.pixelBuffer!)
  }

  /// Creates a new `CVPixelBuffer` based on the provided `CGSize`.
  func setSize(_ size: CGSize) {
    if self.pixelBuffer == nil
      ||
      (size.width != self.frameSize.width || size.height != self.frameSize
        .height)
    {
      let attrs =
        [
          kCVPixelBufferOpenGLCompatibilityKey: kCFBooleanTrue,
          kCVPixelBufferOpenGLESCompatibilityKey: kCFBooleanTrue,
          kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue,
        ] as CFDictionary
      let res = CVPixelBufferCreate(
        kCFAllocatorDefault,
        Int(size.width), Int(size.height),
        kCVPixelFormatType_32BGRA,
        attrs,
        &self.pixelBuffer
      )
      self.frameSize = size
    }
  }

  /// Resets the `CVPixelBuffer` of this renderer.
  func onTextureUnregistered(_: FlutterRtcVideoRenderer) {
    self.pixelBuffer = nil
  }

  /// Resets this renderer and stops frames rendering.
  ///
  /// Renderer can be reused after reset.
  func reset() {
    self.rendererLock.lock()
    self.frameWidth = 0
    self.frameHeight = 0
    self.frameRotation = -1
    self.pixelBuffer = nil
    self.isFirstFrameRendered = false
    self.frameSize = CGSize()
    self.rendererLock.unlock()
  }

  /// Corrects rotation of the provided `RTCVideoFrame` and converts it into
  /// I420 format.
  func correctRotation(frame: RTCVideoFrame) -> RTCI420Buffer {
    let src = frame.buffer.toI420()
    let rotation = frame.rotation
    var rotatedWidth = src.width
    var rotatedHeight = src.height

    if rotation == ._90 || rotation == ._270 {
      rotatedWidth = src.height
      rotatedHeight = src.width
    }

    let buffer = RTCI420Buffer(width: rotatedWidth, height: rotatedHeight)
    libyuv_I420Rotate(
      src.dataY,
      src.strideY,
      src.dataU,
      src.strideU,
      src.dataV,
      src.strideV,
      UnsafeMutablePointer(mutating: buffer.dataY),
      buffer.strideY,
      UnsafeMutablePointer(mutating: buffer.dataU),
      buffer.strideU,
      UnsafeMutablePointer(mutating: buffer.dataV),
      buffer.strideV,
      src.width,
      src.height,
      rotation
    )
    return buffer
  }

  /// Sets the `MediaStreamTrackProxy` which will be rendered by this renderer.
  func setVideoTrack(newTrack: MediaStreamTrackProxy?) {
    if newTrack == nil {
      self.reset()
      self.rendererLock.lock()
      self.track?.removeRenderer(renderer: self)
      self.rendererLock.unlock()
    }
    if self.track != newTrack, newTrack != nil {
      self.rendererLock.lock()
      self.track?.removeRenderer(renderer: self)
      self.rendererLock.unlock()

      if self.track == nil {
        newTrack!.addRenderer(renderer: self)
      }
    }

    self.track = newTrack
  }

  /// Removes this renderer from the list of renderers used by the rendering
  /// track.
  func dispose() {
    self.rendererLock.lock()
    if self.track != nil {
      self.track!.removeRenderer(renderer: self)
    }
    self.rendererLock.unlock()
  }

  /// Renders the provided `RTCVideoFrame` to the `CVPixelBuffer`.
  ///
  /// Video frame will be just rendered on the `CVPixelBuffer`, but Flutter
  /// should get it by calling the `copyPixelBuffer()` method. So, video will be
  /// seen on Flutter side only after the `copyPixelBuffer()` call by Flutter.
  ///
  /// Also this method fires renderer events (if any) and notifies Flutter about
  /// the necessity to call the `copyPixelBuffer()` method to get the rendered
  /// frame.
  func renderFrame(_ renderFrame: RTCVideoFrame?) {
    self.rendererLock.lock()
    if renderFrame == nil {
      self.rendererLock.unlock()
      return
    }
    let buffer = self.correctRotation(frame: renderFrame!)
    let isFrameWidthChanged = self.frameWidth != renderFrame!.buffer.width
    let isFrameHeightChanged = self.frameHeight != renderFrame!.buffer.height
    if isFrameWidthChanged || isFrameHeightChanged {
      self.frameWidth = renderFrame!.buffer.width
      self.frameHeight = renderFrame!.buffer.height
      self.broadcastEventObserver().onTextureChangeVideoSize(
        id: self.textureId, height: self.frameHeight, width: self.frameWidth
      )
    }
    if self.pixelBuffer == nil {
      self.rendererLock.unlock()
      return
    }
    CVPixelBufferLockBaseAddress(
      self.pixelBuffer!,
      CVPixelBufferLockFlags(rawValue: 0)
    )
    let dst = CVPixelBufferGetBaseAddress(self.pixelBuffer!)!
    let bytesPerRow = CVPixelBufferGetBytesPerRow(self.pixelBuffer!)
    libyuv_I420ToARGB(
      buffer.dataY,
      buffer.strideY,
      buffer.dataU,
      buffer.strideU,
      buffer.dataV,
      buffer.strideV,
      UnsafeMutablePointer<UInt8>(OpaquePointer(dst)),
      Int32(bytesPerRow),
      buffer.width,
      buffer.height
    )
    CVPixelBufferUnlockBaseAddress(
      self.pixelBuffer!,
      CVPixelBufferLockFlags(rawValue: 0)
    )

    var rotation = 0
    switch renderFrame!.rotation {
    case RTCVideoRotation._0:
      rotation = 0
    case RTCVideoRotation._90:
      rotation = 90
    case RTCVideoRotation._180:
      rotation = 180
    case RTCVideoRotation._270:
      rotation = 270
    }
    if self.frameRotation != rotation {
      self.frameRotation = rotation
      self.broadcastEventObserver().onTextureChangeRotation(
        id: self.textureId, rotation: self.frameRotation
      )
    }

    if !self.isFirstFrameRendered {
      self.broadcastEventObserver().onFirstFrameRendered(id: self.textureId)
      self.isFirstFrameRendered = true
    }
    self.rendererLock.unlock()

    DispatchQueue.main.async {
      self.registry.textureFrameAvailable(self.textureId)
    }
  }
}
