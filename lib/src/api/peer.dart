import 'dart:async';

import 'package:flutter/services.dart';

import '/src/model/ice.dart';
import '/src/model/peer.dart';
import '/src/model/sdp.dart';
import '/src/model/track.dart';
import '/src/model/transceiver.dart';
import '/src/platform/native/media_stream_track.dart';
import 'channel.dart';
import 'transceiver.dart';

/// [MethodChannel] used for the messaging with a native side.
final _peerConnectionFactoryMethodChannel =
    methodChannel('PeerConnectionFactory', 0);

/// Shortcut for the `on_track` callback.
typedef OnTrackCallback = void Function(NativeMediaStreamTrack, RtpTransceiver);

/// Shortcut for the `on_ice_candidate` callback.
typedef OnIceCandidateCallback = void Function(IceCandidate);

/// Shortcut for the `on_ice_connection_state_change` callback.
typedef OnIceConnectionStateChangeCallback = void Function(IceConnectionState);

/// Shortcut for the `on_connection_state_change` callback.
typedef OnConnectionStateChangeCallback = void Function(PeerConnectionState);

/// Shortcut for the `on_ice_gathering_state_change` callback.
typedef OnIceGatheringStateChangeCallback = void Function(IceGatheringState);

/// Shortcut for the `on_negotiation_needed` callback.
typedef OnNegotiationNeededCallback = void Function();

/// Shortcut for the `on_signaling_state_change` callback.
typedef OnSignalingStateChangeCallback = void Function(SignalingState);

/// Shortcut for the `on_ice_candidate_error` callback.
typedef OnIceCandidateErrorCallback = void Function(IceCandidateErrorEvent);

class PeerConnection {
  /// Creates a [PeerConnection] based on the [Map] received from the native
  /// side.
  PeerConnection._fromMap(dynamic map) {
    int channelId = map['channelId'];
    _chan = methodChannel('PeerConnection', channelId);
    _eventChan = eventChannel('PeerConnectionEvent', channelId);
    _eventSub = _eventChan.receiveBroadcastStream().listen(eventListener);
  }

  /// Listener for the all [PeerConnection] events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic e = event;
    switch (e['event']) {
      case 'onIceCandidate':
        dynamic iceCandidate = e['candidate'];
        _onIceCandidate?.call(IceCandidate.fromMap(iceCandidate));
        break;
      case 'onIceGatheringStateChange':
        var state = IceGatheringState.values[e['state']];
        _onIceGatheringStateChange?.call(state);
        break;
      case 'onIceCandidateError':
        var errorEvent = IceCandidateErrorEvent.fromMap(e['errorEvent']);
        _onIceCandidateError?.call(errorEvent);
        break;
      case 'onNegotiationNeeded':
        _onNegotiationNeeded?.call();
        break;
      case 'onSignalingStateChange':
        var state = SignalingState.values[e['state']];
        _onSignalingStateChange?.call(state);
        break;
      case 'onIceConnectionStateChange':
        var state = IceConnectionState.values[e['state']];
        _iceConnectionState = state;
        _onIceConnectionStateChange?.call(state);
        break;
      case 'onConnectionStateChange':
        var state = PeerConnectionState.values[e['state']];
        _connectionState = state;
        _onConnectionStateChange?.call(state);
        break;
      case 'onTrack':
        dynamic track = e['track'];
        dynamic transceiver = e['transceiver'];
        _onTrack?.call(NativeMediaStreamTrack.fromMap(track),
            RtpTransceiver.fromMap(transceiver));
        break;
    }
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  /// [EventChannel] from which all [PeerConnection] events will be received.
  late EventChannel _eventChan;

  /// [_eventChan] subscription to the [PeerConnection] events.
  late StreamSubscription<dynamic>? _eventSub;

  /// `on_ice_connection_state_change` event subscriber.
  OnIceConnectionStateChangeCallback? _onIceConnectionStateChange;

  /// `on_ice_candidate` event subscriber.
  OnIceCandidateCallback? _onIceCandidate;

  /// `on_ice_candidate_error` event subscriber.
  OnIceCandidateErrorCallback? _onIceCandidateError;

  /// `on_track` event subscriber.
  OnTrackCallback? _onTrack;

  /// `on_connection_state_change` event subscriber.
  OnConnectionStateChangeCallback? _onConnectionStateChange;

  /// `on_ice_gathering_state_change` event subscriber.
  OnIceGatheringStateChangeCallback? _onIceGatheringStateChange;

  /// `on_negotiation_needed` event subscriber.
  OnNegotiationNeededCallback? _onNegotiationNeeded;

  /// `on_signaling_state_change` event subscriber.
  OnSignalingStateChangeCallback? _onSignalingStateChange;

  /// Current [IceConnectionState] of this [PeerConnection].
  ///
  /// This field will be updated automatically based on the events received from
  /// the native side.
  IceConnectionState _iceConnectionState = IceConnectionState.new_;

  /// Current [PeerConnectionState] of this [PeerConnection].
  ///
  /// This field will be updated automatically based on the events received from
  /// the native side.
  PeerConnectionState _connectionState = PeerConnectionState.new_;

  /// All [RtpTransceiver]s owned by this [PeerConnection].
  ///
  /// This list will be automatically updated on a call of some action which
  /// theoretically can change it.
  ///
  /// This allows us, to make some public APIs synchronous.
  final List<RtpTransceiver> _transceivers = [];

  /// Creates a new [PeerConnection] with the provided [IceTransportType] and
  /// [IceServer]s.
  static Future<PeerConnection> create(
      IceTransportType iceTransportType, List<IceServer> iceServers) async {
    dynamic res =
        await _peerConnectionFactoryMethodChannel.invokeMethod('create', {
      'iceTransportType': iceTransportType.index,
      'iceServers': iceServers.map((s) => s.toMap()).toList(),
    });

    return PeerConnection._fromMap(res);
  }

  /// Subscribes the provided callback to the `on_track` events of this
  /// [PeerConnection].
  void onTrack(OnTrackCallback f) {
    _onTrack = f;
  }

  /// Subscribes the provided callback to the `on_ice_candidate` events of this
  /// [PeerConnection].
  void onIceCandidate(OnIceCandidateCallback f) {
    _onIceCandidate = f;
  }

  /// Subscribes the provided callback to the `on_ice_candidate_error` events of
  /// this [PeerConnection].
  void onIceCandidateError(OnIceCandidateErrorCallback f) {
    _onIceCandidateError = f;
  }

  /// Subscribes the provided callback to the `on_ice_connection_state_change`
  /// events of this [PeerConnection].
  void onIceConnectionStateChange(OnIceConnectionStateChangeCallback f) {
    _onIceConnectionStateChange = f;
  }

  /// Subscribes the provided callback to the `on_connection_state_change`
  /// events of this [PeerConnection].
  void onConnectionStateChange(OnConnectionStateChangeCallback f) {
    _onConnectionStateChange = f;
  }

  /// Subscribes the provided callback to the `on_ice_gathering_state_change`
  /// events of this [PeerConnection].
  void onIceGatheringStateChange(OnIceGatheringStateChangeCallback f) {
    _onIceGatheringStateChange = f;
  }

  /// Subscribes the provided callback to the `on_negotiation_needed` events of
  /// this [PeerConnection].
  void onNegotiationNeeded(OnNegotiationNeededCallback f) {
    _onNegotiationNeeded = f;
  }

  /// Subscribes the provided callback to the `on_signaling_state_change` events
  /// of this [PeerConnection].
  void onSignalingStateChange(OnSignalingStateChangeCallback f) {
    _onSignalingStateChange = f;
  }

  /// Synchronizes mIDs of the [_transceivers] owned by this [PeerConnection].
  Future<void> _syncTransceiversMids() async {
    for (var transceiver in _transceivers) {
      await transceiver.syncMid();
    }
  }

  /// Adds a new [RtpTransceiver] to this [PeerConnection].
  Future<RtpTransceiver> addTransceiver(
      MediaKind mediaType, RtpTransceiverInit init) async {
    dynamic res = await _chan.invokeMethod(
        'addTransceiver', {'mediaType': mediaType.index, 'init': init.toMap()});
    var transceiver = RtpTransceiver.fromMap(res);
    _transceivers.add(transceiver);

    return transceiver;
  }

  /// Returns all the [RtpTransceiver]s owned by this [PeerConnection].
  Future<List<RtpTransceiver>> getTransceivers() async {
    List<dynamic> res = await _chan.invokeMethod('getTransceivers');
    var transceivers = res.map((t) => RtpTransceiver.fromMap(t)).toList();
    _transceivers.addAll(transceivers);

    return transceivers;
  }

  /// Sets the provided remote [SessionDescription] to the [PeerConnection].
  Future<void> setRemoteDescription(SessionDescription description) async {
    await _chan.invokeMethod(
        'setRemoteDescription', {'description': description.toMap()});
    await _syncTransceiversMids();
  }

  /// Sets the provided local [SessionDescription] to the [PeerConnection].
  Future<void> setLocalDescription(SessionDescription description) async {
    await _chan.invokeMethod(
        'setLocalDescription', {'description': description.toMap()});
    await _syncTransceiversMids();
  }

  /// Creates a new [SessionDescription] offer.
  Future<SessionDescription> createOffer() async {
    dynamic res = await _chan.invokeMethod('createOffer');
    return SessionDescription.fromMap(res);
  }

  /// Creates a new [SessionDescription] answer.
  Future<SessionDescription> createAnswer() async {
    dynamic res = await _chan.invokeMethod('createAnswer');
    return SessionDescription.fromMap(res);
  }

  /// Adds a new [IceCandidate] to the [PeerConnection].
  Future<void> addIceCandidate(IceCandidate candidate) async {
    await _chan
        .invokeMethod('addIceCandidate', {'candidate': candidate.toMap()});
  }

  /// Requests the [PeerConnection] to redo [IceCandidate]s gathering.
  Future<void> restartIce() async {
    await _chan.invokeMethod('restartIce');
  }

  /// Returns the current [PeerConnectionState] of this [PeerConnection].
  PeerConnectionState connectionState() {
    return _connectionState;
  }

  /// Returns the current [IceConnectionState] of this [PeerConnection].
  IceConnectionState iceConnectionState() {
    return _iceConnectionState;
  }

  /// Closes this [PeerConnection] and all it's owned entities (for example,
  /// [RtpTransceiver]s).
  Future<void> close() async {
    for (var e in _transceivers) {
      e.stoppedByPeer();
    }
    await _eventSub?.cancel();
    await _chan.invokeMethod('dispose');
  }
}
