class RTCIceCandidate {
  String candidate;
  String sdpMid;
  int sdpMlineIndex;

  RTCIceCandidate(String candidate, String sdpMid, int sdpMlineIndex);

  dynamic toMap() {
    return {
      "candidate": candidate,
      "sdpMid": sdpMid,
      "sdpMlineIndex": sdpMlineIndex
    };
  }
}
