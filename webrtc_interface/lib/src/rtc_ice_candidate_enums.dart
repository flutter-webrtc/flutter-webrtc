enum RTCIceCandidateType {
  host,
  srflx, // Server Reflexive
  prflx, // Peer Reflexive
  relay, // TURN Relay
}

String rtcIceCandidateTypeToString(RTCIceCandidateType type) {
  return type.toString().split('.').last;
}

RTCIceCandidateType? rtcIceCandidateTypeFromString(String? s) {
  if (s == null) return null;
  for (var type in RTCIceCandidateType.values) {
    if (rtcIceCandidateTypeToString(type) == s) {
      return type;
    }
  }
  return null;
}

enum RTCIceProtocol {
  udp,
  tcp,
}

String rtcIceProtocolToString(RTCIceProtocol protocol) {
  return protocol.toString().split('.').last;
}

RTCIceProtocol? rtcIceProtocolFromString(String? s) {
  if (s == null) return null;
  for (var protocol in RTCIceProtocol.values) {
    if (rtcIceProtocolToString(protocol) == s) {
      return protocol;
    }
  }
  return null;
}
