import 'package:flutter/services.dart';
import 'rtc_peerconnection.dart';
import 'rtc_data_channel.dart';

class WebRTC {
  static const MethodChannel _channel = const MethodChannel('cloudwebrtc.com/WebRTC.Method');
  static MethodChannel methodChannel() => _channel;
}

RTCIceConnectionState iceConnectionStateForString(String state) {
  switch (state) {
    case "new":
      return RTCIceConnectionState.RTCIceConnectionStateNew;
    case "checking":
      return RTCIceConnectionState.RTCIceConnectionStateChecking;
    case "connected":
      return RTCIceConnectionState.RTCIceConnectionStateConnected;
    case "completed":
      return RTCIceConnectionState.RTCIceConnectionStateCompleted;
    case "failed":
      return RTCIceConnectionState.RTCIceConnectionStateFailed;
    case "disconnected":
      return RTCIceConnectionState.RTCIceConnectionStateDisconnected;
    case "closed":
      return RTCIceConnectionState.RTCIceConnectionStateClosed;
    case "count":
      return RTCIceConnectionState.RTCIceConnectionStateCount;
  }
  return RTCIceConnectionState.RTCIceConnectionStateClosed;
}

RTCIceGatheringState iceGatheringStateforString(String state) {
  switch (state) {
    case "new":
      return RTCIceGatheringState.RTCIceGatheringStateNew;
    case "gathering":
      return RTCIceGatheringState.RTCIceGatheringStateGathering;
    case "complete":
      return RTCIceGatheringState.RTCIceGatheringStateComplete;
  }
  return RTCIceGatheringState.RTCIceGatheringStateNew;
}

RTCSignalingState signalingStateForString(String state) {
  switch (state) {
    case "stable":
      return RTCSignalingState.RTCSignalingStateStable;
    case "have-local-offer":
      return RTCSignalingState.RTCSignalingStateHaveLocalOffer;
    case "have-local-pranswer":
      return RTCSignalingState.RTCSignalingStateHaveLocalPrAnswer;
    case "have-remote-offer":
      return RTCSignalingState.RTCSignalingStateHaveRemoteOffer;
    case "have-remote-pranswer":
      return RTCSignalingState.RTCSignalingStateHaveRemotePrAnswer;
    case "closed":
      return RTCSignalingState.RTCSignalingStateClosed;
  }
  return RTCSignalingState.RTCSignalingStateClosed;
}

RTCDataChannelState rtcDataChannelStateForString(String state) {
  switch (state) {
    case "connecting":
      return RTCDataChannelState.RTCDataChannelConnecting;
    case "open":
      return RTCDataChannelState.RTCDataChannelOpen;
    case "closing":
      return RTCDataChannelState.RTCDataChannelClosing;
    case "closed":
      return RTCDataChannelState.RTCDataChannelClosed;
  }
  return RTCDataChannelState.RTCDataChannelClosed;
}
