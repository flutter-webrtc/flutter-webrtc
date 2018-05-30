class RTCIceCandidate {
  String candidate;
  String sdpMid;
  int sdpMlineIndex;

  RTCIceCandidate(this.candidate, this.sdpMid, this.sdpMlineIndex);

  dynamic toMap() {
    return {
      "candidate": candidate,
      "sdpMid": sdpMid,
      "sdpMLineIndex": sdpMlineIndex
    };
  }
}
