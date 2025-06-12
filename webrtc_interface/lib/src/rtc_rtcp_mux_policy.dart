enum RTCRtcpMuxPolicy {
  /// Gather ICE candidates for both RTP and RTCP candidates. If the remote
  /// endpoint is not compatible with RTCP muxing, then it will connect using
  /// both RTP and RTCP candidates.
  negotiate,

  /// Gather ICE candidates only for RTP and tell the remote endpoint that we
  /// require RTCP muxing. If the remote endpoint is not compatible with RTCP
  /// muxing, then session negotiation will fail.
  require,
}
