import 'dart:async';
// ignore: uri_does_not_exist
import 'dart:js' as JS;

import 'rtc_peerconnection.dart';
import 'rtc_data_channel.dart';

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

Future<T> promiseToFuture<T>(JS.JsObject promise) {
  final completer = Completer<T>();
  promise.callMethod('then', [
    JS.JsFunction.withThis((_, arg) {
      completer.complete(arg);
    }),
    JS.JsFunction.withThis((_, err) {
      completer.completeError(Error());
    }),
  ]);
  return completer.future;
}
