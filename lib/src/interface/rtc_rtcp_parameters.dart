class RTCRTCPParameters {
  RTCRTCPParameters(this.cname, this.reducedSize);
  factory RTCRTCPParameters.fromMap(Map<dynamic, dynamic> map) {
    return RTCRTCPParameters(map['cname'], map['reducedSize']);
  }

  /// The Canonical Name used by RTCP
  String cname;

  /// Whether reduced size RTCP is configured or compound RTCP
  bool reducedSize;

  Map<String, dynamic> toMap() {
    return {
      'cname': cname,
      'reducedSize': reducedSize,
    };
  }
}
