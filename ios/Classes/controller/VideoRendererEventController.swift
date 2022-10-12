/// Controller of `VideoRenderer` events.
class VideoRendererEventController: VideoRendererEvent {
  /// Controller of the `VideoRenderer` event channel.
  private var eventController: EventController

  /// Flutter messenger for creating another controllers.
  private var messenger: FlutterBinaryMessenger

  /// Initializes a new controller for sending all `FlutterRtcVideoRenderer`
  /// events to Flutter side.
  init(messenger: FlutterBinaryMessenger, eventController: EventController) {
    self.messenger = messenger
    self.eventController = eventController
  }

  /// Sends an `onFirstFrameRendered` event to Flutter side.
  func onFirstFrameRendered(id: Int64) {
    self.eventController.sendEvent(data: [
      "event": "onFirstFrameRendered",
      "id": id,
    ])
  }

  /// Sends an `onTextureChangeVideoSize` event to Flutter side.
  func onTextureChangeVideoSize(id: Int64, height: Int32, width: Int32) {
    self.eventController.sendEvent(data: [
      "event": "onTextureChangeVideoSize",
      "id": id,
      "width": width,
      "height": height,
    ])
  }

  /// Sends an `onTextureChangeRotation` event to Flutter side.
  func onTextureChangeRotation(id: Int64, rotation: Int) {
    self.eventController.sendEvent(data: [
      "event": "onTextureChangeRotation",
      "id": id,
      "rotation": rotation,
    ])
  }
}
