/// Represents a candidate Interactive Connectivity Establishment (ICE)
/// configuration which may be used to establish a peer connection.
class IceCandidate {
  /// Creates a new [IceCandidate] with the provided parameters.
  IceCandidate(this.sdpMid, this.sdpMLineIndex, this.candidate);

  /// Creates an [IceCandidate] basing on the [Map] received from the native
  /// side.
  IceCandidate.fromMap(dynamic map) {
    sdpMid = map['sdpMid'];
    sdpMLineIndex = map['sdpMLineIndex'];
    candidate = map['candidate'];
  }

  /// mID of this [IceCandidate].
  late String sdpMid;

  /// SDP m line index of this [IceCandidate].
  late int sdpMLineIndex;

  /// SDP of this [IceCandidate].
  late String candidate;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'candidate': candidate,
    };
  }
}

/// Description of the error occurred with ICE candidate from a PeerConnection.
class IceCandidateErrorEvent {
  /// Creates an [IceCandidateErrorEvent] based on the [Map] received from the
  /// native side.
  IceCandidateErrorEvent.fromMap(dynamic map) {
    address = map['address'];
    port = map['port'];
    url = map['url'];
    errorCode = map['errorCode'];
    errorText = map['errorText'];
  }

  /// Local IP address used to communicate with a STUN or TURN server.
  late String address;

  /// Port used to communicate with a STUN or TURN server.
  late int port;

  /// STUN or TURN URL identifying the STUN or TURN server for which the failure
  /// occurred.
  late String url;

  /// Numeric STUN error code returned by the STUN or TURN server. If no host
  /// candidate can reach the server, `errorCode` will be set to the value 701
  /// which is outside the STUN error code range. This error is only fired once
  /// per server URL while in the `RTCIceGatheringState` of "gathering".
  late int errorCode;

  /// STUN reason text returned by the STUN or TURN server. If the server could
  /// not be reached, `errorText` will be set to an implementation-specific
  /// value providing details about the error.
  late String errorText;
}
