import Flutter

/// Controller of an `RtpSender`.
class RtpSenderController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of the `RtpSender`'s proxy.
  private var rtpSender: RtpSenderProxy

  /// ID of the channel created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Initializes a new `RtpSenderController` for the provided `RtpSenderProxy`.
  init(messenger: FlutterBinaryMessenger, rtpSender: RtpSenderProxy) {
    let channelName = ChannelNameGenerator.name(
      name: "RtpSender",
      id: self.channelId
    )
    self.messenger = messenger
    self.rtpSender = rtpSender
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
  }

  /// Handles all the supported Flutter method calls for the controlled
  /// `RtpSenderProxy`.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "replaceTrack":
      let trackId = argsMap!["trackId"] as? String
      var track: MediaStreamTrackProxy?
      if trackId != nil {
        track = MediaStreamTrackStore.tracks[trackId!]
      } else {
        track = nil
      }

      self.rtpSender.replaceTrack(t: track)
      result(nil)
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
    ]
  }
}
