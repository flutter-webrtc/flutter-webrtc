class RTCIceCandidate {
  String candidate;
  String sdpMid;
  int sdpMlineIndex;

  factory RTCIceCandidate.fromMap(Map<dynamic, dynamic> map) {
    return new RTCIceCandidate(
        map['candidate'], map['sdpMid'], map['sdpMLineIndex']);
  }

  RTCIceCandidate(this.candidate, this.sdpMid, this.sdpMlineIndex);

  Map<String, dynamic> toMap() {
    return {
      "candidate": candidate,
      "sdpMid": sdpMid,
      "sdpMLineIndex": sdpMlineIndex
    };
  }
}
