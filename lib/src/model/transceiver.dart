/// Direction of an `RtpTransceiver`.
enum TransceiverDirection {
  /// Indicates that the transceiver is both sending to and receiving from the
  /// remote peer connection.
  sendRecv,

  /// Indicates that the transceiver is sending to the remote peer, but is not
  /// receiving any media from the remote peer.
  sendOnly,

  /// Indicates that the transceiver is receiving from the remote peer, but is
  /// not sending any media to the remote peer.
  recvOnly,

  /// Indicates that the transceiver is inactive, neither sending nor receiving
  /// any media data.
  inactive,

  /// The transceiver will neither send, nor receive RTP. It will generate a
  /// zero port in the offer.
  stopped,
}

/// Init config for an `RtpTransceiver` creation.
class RtpTransceiverInit {
  /// Creates a new [RtpTransceiverInit] config with the provided
  /// [TransceiverDirection].
  RtpTransceiverInit(this.direction);

  /// Direction of an `RtpTransceiver` which will be created from this config.
  late TransceiverDirection direction;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {'direction': direction.index};
  }
}
