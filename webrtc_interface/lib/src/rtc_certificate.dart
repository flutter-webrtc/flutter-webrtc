class RTCCertificate {
  RTCCertificate({
    this.expires,
    this.certificate, // Usually a PEM string
  });

  int? expires; // Unix timestamp in milliseconds
  String? certificate;

  Map<String, dynamic> toMap() {
    return {
      if (expires != null) 'expires': expires,
      if (certificate != null) 'certificate': certificate,
    };
  }

  factory RTCCertificate.fromMap(Map<dynamic, dynamic> map) {
    return RTCCertificate(
      expires: map['expires'],
      certificate: map['certificate'],
    );
  }
}
