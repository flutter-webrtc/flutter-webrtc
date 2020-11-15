abstract class RTCOfferOptions {
  RTCOfferOptions({
    bool iceRestart,
    bool offerToReceiveAudio,
    bool offerToReceiveVideo,
    bool voiceActivityDetection,
  });
  bool get iceRestart;
  bool get offerToReceiveAudio;
  bool get offerToReceiveVideo;
  bool get voiceActivityDetection;
}

abstract class RTCAnswerOptions {
  RTCAnswerOptions({bool voiceActivityDetection});
  bool get voiceActivityDetection;
}

abstract class RTCConfiguration {
  RTCConfiguration({
    List<RTCIceServer> iceServers,
    String rtcpMuxPolicy,
    String iceTransportPolicy,
    String bundlePolicy,
    String peerIdentity,
    int iceCandidatePoolSize,
  });
  List<RTCIceServer> get iceServers;

  ///Optional: 'negotiate' or 'require'
  String get rtcpMuxPolicy;

  ///Optional: 'relay' or 'all'
  String get iceTransportPolicy;

  /// A DOMString which specifies the target peer identity for the
  /// RTCPeerConnection. If this value is set (it defaults to null),
  /// the RTCPeerConnection will not connect to a remote peer unless
  ///  it can successfully authenticate with the given name.
  String get peerIdentity;

  int get iceCandidatePoolSize;

  ///Optional: 'balanced' | 'max-compat' | 'max-bundle'
  String get bundlePolicy;
}

abstract class RTCIceServer {
  RTCIceServer({String urls, String username, String credential});
  // String or List<String>
  dynamic get urls;
  String get username;
  String get credential;
}
