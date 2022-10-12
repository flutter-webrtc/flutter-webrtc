import Flutter

/// Controller for all Flutter event channels of this plugin.
class EventController: NSObject, FlutterStreamHandler {
  /// Flutter event sink for sending messages to Flutter side.
  private var eventSink: FlutterEventSink?

  /// Sets `eventSink` into which all events will be sent.
  func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = eventSink
    return nil
  }

  /// Resets the current `eventSink`.
  func onCancel(withArguments _: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  /// Sends the provided `data` to Flutter side via Flutter `eventSink`.
  ///
  /// If `eventSink` is `nil`, then doesn't send anything.
  func sendEvent(data: [String: Any]) {
    if self.eventSink != nil {
      self.eventSink!(data)
    }
  }
}
