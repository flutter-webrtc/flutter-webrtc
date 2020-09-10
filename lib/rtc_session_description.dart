class RTCSessionDescription {
  String sdp;
  String type;
  RTCSessionDescription(this.sdp, this.type);

  dynamic toMap() {
    return {'sdp': sdp, 'type': type};
  }
}
