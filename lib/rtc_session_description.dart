class RTCSessionDescription {
  String sdp;
  String type;

  factory RTCSessionDescription.fromMap(Map<String, dynamic> map) {
    return new RTCSessionDescription(map['sdp'], map['type']);
  }

  RTCSessionDescription(this.sdp, this.type);

  Map<String, dynamic> toMap() {
    return {"sdp": this.sdp, "type": this.type};
  }
}
