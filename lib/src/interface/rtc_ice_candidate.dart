class RTCIceCandidate {
  RTCIceCandidate(this.candidate, this.sdpMid, this.sdpMlineIndex);
  final String? candidate;
  final String? sdpMid;
  final int? sdpMlineIndex;
  dynamic toMap() {
    return {
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMlineIndex
    };
  }
}
