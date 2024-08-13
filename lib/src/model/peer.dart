import '/src/api/bridge/api.dart' as ffi;

/// ICE transport which should be used by some peer connection.
enum IceTransportType {
  /// Offer all types of ICE candidates.
  all,

  /// Only advertise relay-type candidates, like TURN servers, to avoid leaking
  /// IP addresses of the client.
  relay,

  /// Gather all ICE candidate types except for host candidates.
  nohost,

  /// No ICE candidate offered.
  none,
}

/// ICE server which should be used by some peer connection.
class IceServer {
  /// Creates a new [IceServer] with the provided parameters.
  IceServer(this.urls, [this.username, this.password]);

  /// List of URLs of this [IceServer].
  late List<String> urls;

  /// Username for authentication on this [IceServer].
  String? username;

  /// Password for authentication on this [IceServer].
  String? password;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {
      'urls': urls,
      'username': username,
      'password': password,
    };
  }
}

/// Current state of an ICE agent and its connection.
enum IceConnectionState {
  /// ICE agent is gathering addresses or is waiting to be given remote
  /// candidates through calls to `PeerConnection.addIceCandidate()` (or both).
  new_,

  /// ICE agent has been given one or more remote candidates and is checking
  /// pairs of local and remote candidates against one another to try to find a
  /// compatible match, but hasn't yet found a pair which will allow the peer
  /// connection to be made. It's possible that gathering of candidates is also
  /// still underway.
  checking,

  /// Usable pairing of local and remote candidates has been found for all
  /// components of the connection, and the connection has been established.
  /// It's possible that gathering is still underway, and it's also possible
  /// that the ICE agent is still checking candidates against one another
  /// looking for a better connection to use.
  connected,

  /// ICE agent has finished gathering candidates, has checked all pairs against
  /// one another, and has found a connection for all components.
  completed,

  /// ICE candidate has checked all candidates pairs against one another and has
  /// failed to find compatible matches for all components of the connection.
  /// It's, however, possible that the ICE agent did find compatible connections
  /// for some components.
  failed,

  /// Checks to ensure that components are still connected failed for at least
  /// one component of the peer connection. This is a less stringent test than
  /// failed and may trigger intermittently and resolve just as spontaneously on
  /// less reliable networks, or during temporary disconnections. When the
  /// problem resolves, the connection may return to the connected state.
  disconnected,

  /// ICE agent for this peer connection has shut down and is no longer handling
  /// requests.
  closed,
}

/// Connection's ICE gathering state.
enum IceGatheringState {
  /// Peer connection was just created and hasn't done any networking yet.
  new_,

  /// ICE agent is in the process of gathering candidates for the connection.
  gathering,

  /// ICE agent has finished gathering candidates. If something happens that
  /// requires collecting new candidates, such as a new interface being added or
  /// the addition of a new ICE server, the state will revert to `gathering` to
  /// gather those candidates.
  complete,
}

/// State of a signaling process on a local end of a connection while connecting
/// or reconnecting to another peer.
enum SignalingState {
  /// There is no ongoing exchange of offer and answer underway.
  stable,

  /// Local peer has called `PeerConnection.setLocalDescription()`, passing in
  /// SDP representing an offer (usually created by calling
  /// `PeerConnection.createOffer()`), and the offer has been applied
  /// successfully.
  haveLocalOffer,

  /// Offer sent by the remote peer has been applied and an answer has been
  /// created (usually by calling `PeerConnection.createAnswer()`) and applied
  /// by calling `PeerConnection.setLocalDescription()`).
  haveLocalPranswer,

  /// Remote peer has created an offer and used the signaling server to deliver
  /// it to the local peer, which has set the offer as the remote description by
  /// calling `PeerConnection.setRemoteDescription()`.
  haveRemoteOffer,

  /// Offer sent by the remote peer has been applied and an answer has been
  /// created (usually by calling `PeerConnection.createAnswer()`) and applied
  /// by calling `PeerConnection.setLocalDescription()`. This provisional answer
  /// describes the supported media formats and so forth, but may not have a
  /// complete set of ICE candidates included. Further candidates will be
  /// delivered separately later.
  haveRemotePranswer,

  /// Peer connection has been closed.
  closed,
}

/// Current state of a peer connection.
enum PeerConnectionState {
  /// At least one of the connection's ICE transports is in the new state, and
  /// none of them are in one of the following states: `connecting`, `checking`,
  /// `failed`, `disconnected`, or all of the connection's transports are in the
  /// `closed` state.
  new_,

  /// One or more of the ICE transports are currently in the process of
  /// establishing a connection. That is, their `iceConnectionState` is either
  /// `checking` or `connected`, and no transports are in the `failed` state.
  connecting,

  /// Every ICE transport used by the connection is either in use (state
  /// `connected` or `completed`) or is closed (state `closed`). In addition,
  /// at least one transport is either `connected` or `completed`.
  connected,

  /// At least one of the ICE transports for the connection is in the
  /// `disconnected` state and none of the other transports are in the state
  /// `failed`, `connecting` or `checking`.
  disconnected,

  /// One or more of the ICE transports on the connection is in the `failed`
  /// state.
  failed,

  /// Peer connection is closed.
  closed,
}

/// Supported video codecs.
enum VideoCodec {
  /// [AV1] AOMedia Video 1.
  ///
  /// [AV1]: https://en.wikipedia.org/wiki/AV1
  // ignore: constant_identifier_names
  AV1,

  /// [H.264] Advanced Video Coding (AVC).
  ///
  /// [H.264]: https://en.wikipedia.org/wiki/Advanced_Video_Coding
  // ignore: constant_identifier_names
  H264,

  /// [H.265] High Efficiency Video Coding (HEVC).
  ///
  /// [H.265]: https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding
  // ignore: constant_identifier_names
  H265,

  /// [VP8] codec.
  ///
  /// [VP8]: https://en.wikipedia.org/wiki/VP8
  // ignore: constant_identifier_names
  VP8,

  /// [VP9] codec.
  ///
  /// [VP9]: https://en.wikipedia.org/wiki/VP9
  // ignore: constant_identifier_names
  VP9,
}

/// [VideoCodec] info for encoding/decoding in a peer connection.
class VideoCodecInfo {
  /// Indicator whether hardware acceleration should be used.
  bool isHardwareAccelerated = false;

  /// [VideoCodec] to be used for encoding/decoding.
  VideoCodec codec;

  VideoCodecInfo(this.isHardwareAccelerated, this.codec);

  static VideoCodecInfo fromFFI(ffi.VideoCodecInfo vc) {
    VideoCodec mediaCodec = VideoCodec.values
        .firstWhere((el) => el.name.toLowerCase() == vc.codec.name);
    return VideoCodecInfo(vc.isHardwareAccelerated, mediaCodec);
  }

  static VideoCodecInfo fromMap(dynamic info) {
    VideoCodec mediaCodec = VideoCodec.values[info['codec']];
    return VideoCodecInfo(info['isHardwareAccelerated'], mediaCodec);
  }
}
