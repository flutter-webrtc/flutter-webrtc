import Flutter

/// Controller of a `PeerConnection`.
class PeerConnectionController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of the `PeerConnection`'s proxy'.
  private var peer: PeerConnectionProxy

  /// ID of the channel created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Controller of the `eventChannel` management.
  private var eventController: EventController

  /// Event channel for communicating with Flutter side.
  private var eventChannel: FlutterEventChannel

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Indicator whether this controller is disposed.
  private var isDisposed: Bool = false

  /// Initializes a new `PeerConnectionController` for the provided
  /// `PeerConnectionProxy`.
  init(messenger: FlutterBinaryMessenger, peer: PeerConnectionProxy) {
    let channelName = ChannelNameGenerator.name(
      name: "PeerConnection",
      id: self.channelId
    )
    self.eventController = EventController()
    self.messenger = messenger
    self.peer = peer
    self.peer.addEventObserver(
      eventObserver: PeerEventController(
        messenger: self.messenger, eventController: self.eventController
      )
    )
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.eventChannel = FlutterEventChannel(
      name: ChannelNameGenerator.name(
        name: "PeerConnectionEvent",
        id: self.channelId
      ),
      binaryMessenger: messenger
    )
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
    self.eventChannel.setStreamHandler(self.eventController)
  }

  /// Sends the provided response to the provided result.
  ///
  /// Checks whether `FlutterMethodChannel` is not disposed before sending data.
  /// If it's disposed, then does nothing.
  func sendResultFromTask(_ result: @escaping FlutterResult, _ response: Any?) {
    if !self.isDisposed {
      result(response)
    }
  }

  /// Handles all the supported Flutter method calls for the controlled
  /// `PeerConnectionProxy`.
  func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "createOffer":
      Task {
        do {
          let sdp = try await self.peer.createOffer()
          self.sendResultFromTask(result, sdp.asFlutterResult())
        } catch {
          self.sendResultFromTask(result, getFlutterError(error))
        }
      }
    case "createAnswer":
      Task {
        let sdp = try! await self.peer.createAnswer()
        self.sendResultFromTask(result, sdp.asFlutterResult())
      }
    case "setLocalDescription":
      let description = argsMap!["description"] as? [String: Any]
      let type = description!["type"] as? Int
      let sdp = description!["description"] as? String
      Task {
        do {
          var desc: SessionDescription?
          if sdp == nil {
            desc = nil
          } else {
            desc = SessionDescription(
              type: SessionDescriptionType(rawValue: type!)!, description: sdp!
            )
          }
          try await self.peer.setLocalDescription(description: desc)
          self.sendResultFromTask(result, nil)
        } catch {
          self.sendResultFromTask(result, getFlutterError(error))
        }
      }
    case "setRemoteDescription":
      let descriptionMap = argsMap!["description"] as? [String: Any]
      let type = descriptionMap!["type"] as? Int
      let sdp = descriptionMap!["description"] as? String
      Task {
        do {
          try await self.peer.setRemoteDescription(
            description: SessionDescription(
              type: SessionDescriptionType(rawValue: type!)!,
              description: sdp!
            )
          )
          self.sendResultFromTask(result, nil)
        } catch {
          self.sendResultFromTask(result, getFlutterError(error))
        }
      }
    case "addIceCandidate":
      let candidateMap = argsMap!["candidate"] as? [String: Any]
      let sdpMid = candidateMap!["sdpMid"] as? String
      let sdpMLineIndex = candidateMap!["sdpMLineIndex"] as? Int
      let candidate = candidateMap!["candidate"] as? String
      Task {
        do {
          try await self.peer.addIceCandidate(
            candidate: IceCandidate(
              sdpMid: sdpMid!, sdpMLineIndex: sdpMLineIndex!,
              candidate: candidate!
            )
          )
          self.sendResultFromTask(result, nil)
        } catch {
          self.sendResultFromTask(result, getFlutterError(error))
        }
      }
    case "addTransceiver":
      let mediaType = argsMap!["mediaType"] as? Int
      let initArgs = argsMap!["init"] as? [String: Any]
      let direction = initArgs!["direction"] as? Int
      let argEncodings = initArgs!["sendEncodings"] as? [[String: Any]]
      var sendEncodings: [Encoding] = []

      for e in argEncodings! {
        let rid = e["rid"] as? String
        let active = e["active"] as? Bool
        let maxBitrate = e["maxBitrate"] as? Int
        let maxFramerate = e["maxFramerate"] as? Double
        let scaleResolutionDownBy = e["scaleResolutionDownBy"] as? Double
        let scalabilityMode = e["scalabilityMode"] as? String

        sendEncodings.append(Encoding(
          rid: rid!,
          active: active!,
          maxBitrate: maxBitrate,
          maxFramerate: maxFramerate,
          scaleResolutionDownBy: scaleResolutionDownBy,
          scalabilityMode: scalabilityMode
        ))
      }

      let transceiverInit =
        TransceiverInit(
          direction: TransceiverDirection(rawValue: direction!)!,
          encodings: sendEncodings
        )

      do {
        let transceiver = try RtpTransceiverController(
          messenger: self.messenger,
          transceiver: self.peer.addTransceiver(
            mediaType: MediaType(rawValue: mediaType!)!,
            transceiverInit: transceiverInit
          )
        )
        result(transceiver.asFlutterResult())
      } catch {
        result(getFlutterError(error))
      }
    case "getTransceivers":
      result(
        self.peer.getTransceivers().map {
          RtpTransceiverController(messenger: self.messenger, transceiver: $0)
            .asFlutterResult()
        }
      )
    case "restartIce":
      self.peer.restartIce()
      result(nil)
    case "dispose":
      self.isDisposed = true
      self.channel.setMethodCallHandler(nil)
      self.peer.dispose()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Converts this controller into a Flutter method call response.
  func asFlutterResult() -> [String: Any] {
    [
      "channelId": self.channelId,
      "id": self.peer.getId(),
    ]
  }
}
