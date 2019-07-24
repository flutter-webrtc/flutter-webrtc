class RTCRTCPParameters {
  /// The Canonical Name used by RTCP
  String cname;

  /// Whether reduced size RTCP is configured or compound RTCP
  bool reducedSize;

  factory RTCRTCPParameters.fromMap(Map<String, dynamic> map) {
    return new RTCRTCPParameters(map['cname'], map['reducedSize']);
  }

  RTCRTCPParameters(this.cname, this.reducedSize);
}
