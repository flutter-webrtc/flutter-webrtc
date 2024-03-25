import WebRTC

/// Wrapper around an `RTCRtpTransceiver`, powering it with additional API.
class RtpTransceiverProxy {
  /// Actual underlying `RTCRtpTransceiver`.
  private var transceiver: RTCRtpTransceiver

  /// `RtpSenderProxy` of this `RtpTransceiverProxy`.
  private var sender: RtpSenderProxy

  /// `RtpReceiverProxy` of this `RtpTransceiverProxy`.
  private var receiver: RtpReceiverProxy

  /// Initializes a new `RtpTransceiverProxy` for the provided
  /// `RTCRtpTransceiver`.
  init(transceiver: RTCRtpTransceiver) {
    self.sender = RtpSenderProxy(sender: transceiver.sender)
    self.receiver = RtpReceiverProxy(receiver: transceiver.receiver)
    self.transceiver = transceiver
  }

  /// Returns `RtpSenderProxy` of this `RtpTransceiverProxy`.
  func getSender() -> RtpSenderProxy {
    self.sender
  }

  /// Returns `RtpReceiverProxy` of this `RtpTransceiverProxy`.
  func getReceiver() -> RtpReceiverProxy {
    self.receiver
  }

  /// Sets the provided `TransceiverDirection` to the underlying
  /// `RTCRtpTransceiver`.
  func setDirection(direction: TransceiverDirection) {
    self.transceiver.setDirection(direction.intoWebRtc(), error: nil)
  }

  /// Changes the preferred `RTCRtpTransceiver` codecs to the provided list of
  /// `RTCRtpCodecCapability`s.
  func setCodecPreferences(capability: [RTCRtpCodecCapability]) {
    self.transceiver.setCodecPreferences(capability)
  }

  /// Sets `recv` direction of the underlying `RTCRtpTransceiver`.
  func setRecv(recv: Bool) {
    let direction = self.getDirection()
    var newDirection = TransceiverDirection.stopped
    if recv {
      switch direction {
      case .inactive:
        newDirection = TransceiverDirection.recvOnly
      case .recvOnly:
        newDirection = TransceiverDirection.recvOnly
      case .sendRecv:
        newDirection = TransceiverDirection.sendRecv
      case .sendOnly:
        newDirection = TransceiverDirection.sendRecv
      case .stopped:
        newDirection = TransceiverDirection.stopped
      }
    } else {
      switch direction {
      case .inactive:
        newDirection = TransceiverDirection.inactive
      case .recvOnly:
        newDirection = .inactive
      case .sendRecv:
        newDirection = .sendOnly
      case .sendOnly:
        newDirection = .sendOnly
      case .stopped:
        newDirection = .stopped
      }
    }

    if newDirection != .stopped {
      self.setDirection(direction: newDirection)
    }
  }

  /// Sets `send` direction of the underlying `RTCRtpTransceiver`.
  func setSend(send: Bool) {
    let direction = self.getDirection()
    var newDirection = TransceiverDirection.stopped
    if send {
      switch direction {
      case .inactive:
        newDirection = .sendOnly
      case .sendOnly:
        newDirection = .sendOnly
      case .sendRecv:
        newDirection = .sendRecv
      case .recvOnly:
        newDirection = .sendRecv
      case .stopped:
        newDirection = .stopped
      }
    } else {
      switch direction {
      case .inactive:
        newDirection = .inactive
      case .sendOnly:
        newDirection = .inactive
      case .sendRecv:
        newDirection = .recvOnly
      case .recvOnly:
        newDirection = .recvOnly
      case .stopped:
        newDirection = .stopped
      }
    }

    if newDirection != .stopped {
      self.setDirection(direction: newDirection)
    }
  }

  /// Returns mID of the underlying `RTCRtpTransceiver`.
  func getMid() -> String? {
    if self.transceiver.mid != nil, self.transceiver.mid.count == 0 {
      return nil
    }
    return self.transceiver.mid
  }

  /// Returns the preferred `RtpTransceiverDirection` of the underlying
  /// `RTCRtpTransceiver`.
  func getDirection() -> TransceiverDirection {
    if self.transceiver.isStopped {
      return TransceiverDirection.stopped
    } else {
      return TransceiverDirection
        .fromWebRtc(direction: self.transceiver.direction)
    }
  }

  /// Stops the underlying `RTCRtpTransceiver`.
  func stop() {
    self.transceiver.stopInternal()
    self.receiver.notifyRemoved()
  }
}
