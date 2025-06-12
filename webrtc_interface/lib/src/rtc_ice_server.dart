class RTCIceServer {
  RTCIceServer({this.urls, this.username, this.credential});

  /// A list of URIs for the ICE server.
  /// For example: 'stun:stun.l.google.com:19302' or 'turn:user@example.com:3478'
  List<String>? urls;
  String? username;
  String? credential;

  Map<String, dynamic> toMap() {
    return {
      if (urls != null) 'urls': urls,
      if (username != null) 'username': username,
      if (credential != null) 'credential': credential,
    };
  }

  factory RTCIceServer.fromMap(Map<dynamic, dynamic> map) {
    return RTCIceServer(
      urls: List<String>.from(map['urls'] ?? []),
      username: map['username'],
      credential: map['credential'],
    );
  }
}
