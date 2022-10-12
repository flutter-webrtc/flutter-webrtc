/// Controller of `PeerConnection` events.
class PeerEventController: PeerEventObserver {
  /// Controller of the `PeerConnection` event channel.
  private var eventController: EventController

  /// Flutter messenger for creating another controllers.
  private var messenger: FlutterBinaryMessenger

  /// Initializes a new controller for sending all `PeerConnectionProxy` events
  /// to Flutter side.
  init(messenger: FlutterBinaryMessenger, eventController: EventController) {
    self.messenger = messenger
    self.eventController = eventController
  }

  /// Sends an `onTrack` event to Flutter side.
  func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
    self.eventController.sendEvent(data: [
      "event": "onTrack",
      "track": MediaStreamTrackController(messenger: self.messenger,
                                          track: track)
        .asFlutterResult(),
      "transceiver": RtpTransceiverController(messenger: self.messenger,
                                              transceiver: transceiver)
        .asFlutterResult(),
    ])
  }

  /// Sends an `onIceConnectionStateChange` event to Flutter side.
  func onIceConnectionStateChange(state: IceConnectionState) {
    self.eventController.sendEvent(data: [
      "event": "onIceConnectionStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends an `onSignalingStateChange` event to Flutter side.
  func onSignalingStateChange(state: SignalingState) {
    self.eventController.sendEvent(data: [
      "event": "onSignalingStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends an `onConnectionStateChange` event to Flutter side.
  func onConnectionStateChange(state: PeerConnectionState) {
    self.eventController.sendEvent(data: [
      "event": "onConnectionStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends an `onIceGatheringStateChange` event to Flutter side.
  func onIceGatheringStateChange(state: IceGatheringState) {
    self.eventController.sendEvent(data: [
      "event": "onIceGatheringStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends an `onIceCandidate` event to Flutter side.
  func onIceCandidate(candidate: IceCandidate) {
    self.eventController.sendEvent(data: [
      "event": "onIceCandidate",
      "candidate": candidate.asFlutterResult(),
    ])
  }

  /// Sends an `onNegotiationNeeded` event to Flutter side.
  func onNegotiationNeeded() {
    self.eventController.sendEvent(data: [
      "event": "onNegotiationNeeded",
    ])
  }
}
