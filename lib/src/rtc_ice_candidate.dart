class RTCIceCandidate {
  RTCIceCandidate(this.candidate, this.sdpMid, this.sdpMlineIndex);
  factory RTCIceCandidate.fromMap(Map<String, dynamic> map) {
    return RTCIceCandidate(
        map['candidate'], map['sdpMid'], map['sdpMLineIndex']);
  }
  final String candidate;
  final String sdpMid;
  final int sdpMlineIndex;
  dynamic toMap() {
    return {
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMlineIndex
    };
  }
}
