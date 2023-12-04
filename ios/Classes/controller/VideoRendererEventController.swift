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
    DispatchQueue.main.async {
      self.eventController.sendEvent(data: [
        "event": "onFirstFrameRendered",
        "id": id,
      ])
    }
  }

  /// Sends an `onTextureChange` event to Flutter side.
  func onTextureChange(id: Int64, height: Int32, width: Int32, rotation: Int) {
    DispatchQueue.main.async {
      self.eventController.sendEvent(data: [
        "event": "onTextureChange",
        "id": id,
        "width": width,
        "height": height,
        "rotation": rotation,
      ])
    }
  }
}
