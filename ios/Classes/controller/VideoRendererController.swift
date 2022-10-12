import Flutter

/// Controller of a `VideoRenderer`.
class VideoRendererController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of the `FlutterRtcVideoRenderer`.
  private var renderer: FlutterRtcVideoRenderer

  /// ID of the channel created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Event channel for communicating with Flutter side.
  private var eventChannel: FlutterEventChannel

  /// Controller of the `eventChannel` management.
  private var eventController: EventController

  /// Initializes a new `VideoRendererController` for the provided
  /// `FlutterRtcVideoRenderer`.
  init(messenger: FlutterBinaryMessenger, renderer: FlutterRtcVideoRenderer) {
    let channelName = ChannelNameGenerator.name(
      name: "VideoRenderer",
      id: self.channelId
    )
    let eventChannelName = ChannelNameGenerator.name(
      name: "VideoRendererEvent", id: self.channelId
    )
    self.messenger = messenger
    self.renderer = renderer
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: messenger
    )
    self.eventController = EventController()
    self.renderer.subscribe(
      sub: VideoRendererEventController(
        messenger: self.messenger, eventController: self.eventController
      )
    )
    self.eventChannel.setStreamHandler(self.eventController)
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
  }

  /// Handles all the supported Flutter method calls for the controlled
  /// `FlutterRtcVideoRenderer`.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "setSrcObject":
      let trackId = argsMap!["trackId"] as? String
      var track: MediaStreamTrackProxy?
      if trackId != nil {
        track = MediaStreamTrackStore.tracks[trackId!]
      } else {
        track = nil
      }
      self.renderer.setVideoTrack(newTrack: track)
      result(nil)
    case "dispose":
      self.renderer.dispose()
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
      "textureId": self.renderer.getTextureId(),
    ]
  }
}
