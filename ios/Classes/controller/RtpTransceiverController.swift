import Flutter

/// Controller of an `RtpTransceiver`.
class RtpTransceiverController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of the `RtpTransceiver`'s proxy.
  private var transceiver: RtpTransceiverProxy

  /// ID of the channel created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Initializes a new `RtpTransceiverController` for the provided
  /// `RtpTransceiverProxy`.
  init(messenger: FlutterBinaryMessenger, transceiver: RtpTransceiverProxy) {
    let channelName = ChannelNameGenerator.name(
      name: "RtpTransceiver",
      id: self.channelId
    )
    self.messenger = messenger
    self.transceiver = transceiver
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
  }

  /// Handles all the supported Flutter method calls for the controlled
  /// `RtpTransceiverProxy`.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "setDirection":
      let direction = argsMap!["direction"] as? Int
      self.transceiver
        .setDirection(direction: TransceiverDirection(rawValue: direction!)!)
      result(nil)
    case "setRecv":
      let enabled = argsMap!["recv"] as? Bool
      self.transceiver.setRecv(recv: enabled!)
      result(nil)
    case "setSend":
      let enabled = argsMap!["send"] as? Bool
      self.transceiver.setSend(send: enabled!)
      result(nil)
    case "getMid":
      let mid = self.transceiver.getMid()
      result(mid)
    case "getDirection":
      let direction = self.transceiver.getDirection()
      result(direction.rawValue)
    case "stop":
      self.transceiver.stop()
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
      "sender": RtpSenderController(messenger: self.messenger,
                                    rtpSender: self.transceiver.getSender())
        .asFlutterResult(),
      "mid": self.transceiver.getMid(),
    ]
  }
}
