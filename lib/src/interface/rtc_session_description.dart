class RTCSessionDescription {
  RTCSessionDescription(this.sdp, this.type);
  String? sdp;
  String? type;
  dynamic toMap() {
    return {'sdp': sdp, 'type': type};
  }
}
