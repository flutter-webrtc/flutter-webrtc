import Flutter

/// Controller of a `MediaStreamTrack`.
class MediaStreamTrackController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of a `MediaStreamTrack`'s' proxy.
  private var track: MediaStreamTrackProxy

  /// ID of the channel created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Event channel for communicating with Flutter side.
  private var eventChannel: FlutterEventChannel

  /// Controller of the `eventChannel` management.
  private var eventController: EventController

  /// Initializes a new `MediaStreamTrackController` for the provided
  /// `MediaStreamTrackProxy`.
  init(messenger: FlutterBinaryMessenger, track: MediaStreamTrackProxy) {
    let channelName = ChannelNameGenerator.name(
      name: "MediaStreamTrack",
      id: self.channelId
    )
    self.eventChannel = FlutterEventChannel(
      name: ChannelNameGenerator.name(
        name: "MediaStreamTrackEvent",
        id: self.channelId
      ),
      binaryMessenger: messenger
    )
    self.eventController = EventController()
    self.messenger = messenger
    self.track = track
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
    self.eventChannel.setStreamHandler(self.eventController)
    self.track.onEnded(cb: {
      self.eventController.sendEvent(data: [
        "event": "onEnded",
      ])
    })
  }

  /// Handles all the supported Flutter method calls for the controlled
  /// `MediaStreamTrackProxy`.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "setEnabled":
      let enabled = argsMap!["enabled"] as? Bool
      self.track.setEnabled(enabled: enabled!)
      result(nil)
    case "state":
      result(self.track.state().rawValue)
    case "stop":
      self.track.stop()
      result(nil)
    case "clone":
      do {
        result(
          MediaStreamTrackController(
            messenger: self.messenger,
            track: try self.track.fork()
          )
          .asFlutterResult()
        )
      } catch {
        result(error)
      }
    case "dispose":
      self.channel.setMethodCallHandler(nil)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Converts this controller into a Flutter method call response.
  func asFlutterResult() -> [String: Any] {
    [
      "channelId": self.channelId,
      "id": self.track.id(),
      "kind": self.track.kind().rawValue,
      "deviceId": self.track.getDeviceId(),
    ]
  }
}
