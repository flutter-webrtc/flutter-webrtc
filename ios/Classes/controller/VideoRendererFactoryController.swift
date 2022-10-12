import Flutter

/// Controller creating new `FlutterRtcVideoRenderer`s.
class VideoRendererFactoryController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Flutter texture registry for creating new Flutter textures.
  private var registry: FlutterTextureRegistry

  /// Initializes a new `VideoRendererFactoryController`.
  init(messenger: FlutterBinaryMessenger, registry: FlutterTextureRegistry) {
    let channelName = ChannelNameGenerator.name(
      name: "VideoRendererFactory",
      id: 0
    )
    self.messenger = messenger
    self.registry = registry
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
  }

  /// Handles all the supported Flutter method calls.
  ///
  /// Creates new `FlutterRtcVideoRenderer`s.
  func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "create":
      let renderer = FlutterRtcVideoRenderer(registry: self.registry)
      result(
        VideoRendererController(messenger: self.messenger, renderer: renderer)
          .asFlutterResult()
      )
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
