enum RecorderAudioChannel { INPUT, OUTPUT }

/// RTCDataChannelMessage type
enum MessageType { text, binary }

enum RTCDataChannelState {
  RTCDataChannelConnecting,
  RTCDataChannelOpen,
  RTCDataChannelClosing,
  RTCDataChannelClosed,
}

enum RTCSignalingState {
  RTCSignalingStateStable,
  RTCSignalingStateHaveLocalOffer,
  RTCSignalingStateHaveRemoteOffer,
  RTCSignalingStateHaveLocalPrAnswer,
  RTCSignalingStateHaveRemotePrAnswer,
  RTCSignalingStateClosed
}

enum RTCIceGatheringState {
  RTCIceGatheringStateNew,
  RTCIceGatheringStateGathering,
  RTCIceGatheringStateComplete
}

enum RTCPeerConnectionState {
  RTCPeerConnectionStateClosed,
  RTCPeerConnectionStateFailed,
  RTCPeerConnectionStateDisconnected,
  RTCPeerConnectionStateNew,
  RTCPeerConnectionStateConnecting,
  RTCPeerConnectionStateConnected
}

enum RTCIceConnectionState {
  RTCIceConnectionStateNew,
  RTCIceConnectionStateChecking,
  RTCIceConnectionStateCompleted,
  RTCIceConnectionStateConnected,
  RTCIceConnectionStateCount,
  RTCIceConnectionStateFailed,
  RTCIceConnectionStateDisconnected,
  RTCIceConnectionStateClosed,
}

enum RTCVideoViewObjectFit {
  RTCVideoViewObjectFitContain,
  RTCVideoViewObjectFitCover,
}
enum RTCRtpMediaType {
  RTCRtpMediaTypeAudio,
  RTCRtpMediaTypeVideo,
  RTCRtpMediaTypeData,
}

final typeRTCRtpMediaTypetoString = <RTCRtpMediaType, String>{
  RTCRtpMediaType.RTCRtpMediaTypeAudio: 'audio',
  RTCRtpMediaType.RTCRtpMediaTypeVideo: 'video',
  RTCRtpMediaType.RTCRtpMediaTypeData: 'data',
};

final typeStringToRTCRtpMediaType = <String, RTCRtpMediaType>{
  'audio': RTCRtpMediaType.RTCRtpMediaTypeAudio,
  'video': RTCRtpMediaType.RTCRtpMediaTypeVideo,
  'data': RTCRtpMediaType.RTCRtpMediaTypeData,
};

enum TransceiverDirection {
  SendRecv,
  SendOnly,
  RecvOnly,
  Inactive,
}

final typeStringToRtpTransceiverDirection = <String, TransceiverDirection>{
  'sendrecv': TransceiverDirection.SendRecv,
  'sendonly': TransceiverDirection.SendOnly,
  'recvonly': TransceiverDirection.RecvOnly,
  'inactive': TransceiverDirection.Inactive,
};

final typeRtpTransceiverDirectionToString = <TransceiverDirection, String>{
  TransceiverDirection.SendRecv: 'sendrecv',
  TransceiverDirection.SendOnly: 'sendonly',
  TransceiverDirection.RecvOnly: 'recvonly',
  TransceiverDirection.Inactive: 'inactive',
};

RTCIceConnectionState iceConnectionStateForString(String? state) {
  switch (state) {
    case 'new':
      return RTCIceConnectionState.RTCIceConnectionStateNew;
    case 'checking':
      return RTCIceConnectionState.RTCIceConnectionStateChecking;
    case 'connected':
      return RTCIceConnectionState.RTCIceConnectionStateConnected;
    case 'completed':
      return RTCIceConnectionState.RTCIceConnectionStateCompleted;
    case 'failed':
      return RTCIceConnectionState.RTCIceConnectionStateFailed;
    case 'disconnected':
      return RTCIceConnectionState.RTCIceConnectionStateDisconnected;
    case 'closed':
      return RTCIceConnectionState.RTCIceConnectionStateClosed;
    case 'count':
      return RTCIceConnectionState.RTCIceConnectionStateCount;
  }
  return RTCIceConnectionState.RTCIceConnectionStateClosed;
}

RTCIceGatheringState iceGatheringStateforString(String? state) {
  switch (state) {
    case 'new':
      return RTCIceGatheringState.RTCIceGatheringStateNew;
    case 'gathering':
      return RTCIceGatheringState.RTCIceGatheringStateGathering;
    case 'complete':
      return RTCIceGatheringState.RTCIceGatheringStateComplete;
  }
  return RTCIceGatheringState.RTCIceGatheringStateNew;
}

RTCSignalingState signalingStateForString(String? state) {
  switch (state) {
    case 'stable':
      return RTCSignalingState.RTCSignalingStateStable;
    case 'have-local-offer':
      return RTCSignalingState.RTCSignalingStateHaveLocalOffer;
    case 'have-local-pranswer':
      return RTCSignalingState.RTCSignalingStateHaveLocalPrAnswer;
    case 'have-remote-offer':
      return RTCSignalingState.RTCSignalingStateHaveRemoteOffer;
    case 'have-remote-pranswer':
      return RTCSignalingState.RTCSignalingStateHaveRemotePrAnswer;
    case 'closed':
      return RTCSignalingState.RTCSignalingStateClosed;
  }
  return RTCSignalingState.RTCSignalingStateClosed;
}

RTCDataChannelState rtcDataChannelStateForString(String state) {
  switch (state) {
    case 'connecting':
      return RTCDataChannelState.RTCDataChannelConnecting;
    case 'open':
      return RTCDataChannelState.RTCDataChannelOpen;
    case 'closing':
      return RTCDataChannelState.RTCDataChannelClosing;
    case 'closed':
      return RTCDataChannelState.RTCDataChannelClosed;
  }
  return RTCDataChannelState.RTCDataChannelClosed;
}

RTCPeerConnectionState peerConnectionStateForString(String? state) {
  switch (state) {
    case 'new':
      return RTCPeerConnectionState.RTCPeerConnectionStateNew;
    case 'connecting':
      return RTCPeerConnectionState.RTCPeerConnectionStateConnecting;
    case 'connected':
      return RTCPeerConnectionState.RTCPeerConnectionStateConnected;
    case 'closed':
      return RTCPeerConnectionState.RTCPeerConnectionStateClosed;
    case 'disconnected':
      return RTCPeerConnectionState.RTCPeerConnectionStateDisconnected;
    case 'failed':
      return RTCPeerConnectionState.RTCPeerConnectionStateFailed;
  }

  return RTCPeerConnectionState.RTCPeerConnectionStateClosed;
}
