enum RTCIceTransportPolicy {
  /// All ICE candidates will be considered.
  all,

  /// Only ICE candidates whose IP addresses are being relayed,
  /// such as those being passed through a TURN server, will be considered.
  relay,
}
