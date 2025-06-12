class RTCPeerIdentity {
  RTCPeerIdentity({
    this.idp,
    this.name,
    this.algorithm,
  });

  String? idp; // Identity Provider
  String? name; // Identity name
  String? algorithm; // Algorithm, e.g., 'RSASSA-PKCS1-v1_5'

  Map<String, dynamic> toMap() {
    return {
      if (idp != null) 'idp': idp,
      if (name != null) 'name': name,
      if (algorithm != null) 'algorithm': algorithm,
    };
  }

  factory RTCPeerIdentity.fromMap(Map<dynamic, dynamic> map) {
    return RTCPeerIdentity(
      idp: map['idp'],
      name: map['name'],
      algorithm: map['algorithm'],
    );
  }
}
