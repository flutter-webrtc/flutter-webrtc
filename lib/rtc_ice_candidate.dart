class RTCIceCandidate {
  RTCIceCandidate(this.candidate, this.sdpMid, this.sdpMlineIndex);
  String candidate;
  String sdpMid;
  int sdpMlineIndex;
  dynamic toMap() {
    return {
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMlineIndex
    };
  }
}
