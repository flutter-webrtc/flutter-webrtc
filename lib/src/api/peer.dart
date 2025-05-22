import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

import '../model/stats.dart';
import '/src/model/ice.dart';
import '/src/model/peer.dart';
import '/src/model/sdp.dart';
import '/src/model/track.dart';
import '/src/model/transceiver.dart';
import '/src/platform/native/media_stream_track.dart';
import 'bridge/api.dart' as ffi;
import 'bridge/frb_generated.dart';
import 'bridge/lib.dart';
import 'channel.dart';
import 'transceiver.dart';

/// Checks whether the running platform is a desktop.
bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

/// Opens the dynamic library and instantiates FFI bridge to Rust side.
Future<void> initFfiBridge() async {
  if (!isDesktop) {
    return;
  }
  if (RustLib.instance.initialized) {
    return;
  }

  const base = 'medea_flutter_webrtc_native';
  final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
  late final lib = Platform.isMacOS
      ? ExternalLibrary.process(iKnowHowToUseIt: true)
      : ExternalLibrary.open(path);

  await RustLib.init(externalLibrary: lib);
}

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

/// [RTCPeerConnection][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
abstract class PeerConnection {
  /// Creates a new [PeerConnection] with the provided [IceTransportType] and
  /// [IceServer]s.
  static Future<PeerConnection> create(
    IceTransportType iceTransportType,
    List<IceServer> iceServers,
  ) async {
    if (isDesktop) {
      return await _PeerConnectionFFI.create(iceTransportType, iceServers);
    } else {
      return await _PeerConnectionChannel.create(iceTransportType, iceServers);
    }
  }

  /// Returns all [VideoCodecInfo]s of the supported video encoders.
  static Future<List<VideoCodecInfo>> videoEncoders() async {
    if (isDesktop) {
      return await _PeerConnectionFFI.videoEncoders();
    } else {
      return await _PeerConnectionChannel.videoEncoders();
    }
  }

  /// Returns all [VideoCodecInfo]s of the supported video decoders.
  static Future<List<VideoCodecInfo>> videoDecoders() async {
    if (isDesktop) {
      return await _PeerConnectionFFI.videoDecoders();
    } else {
      return await _PeerConnectionChannel.videoDecoders();
    }
  }

  /// Indicator whether the [close] was called.
  bool _closed = false;

  /// Indicates whether the [close] was called.
  bool get closed => _closed;

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
  /// This allows us to make some public APIs synchronous.
  final List<RtpTransceiver> _transceivers = [];

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
    _transceivers.retainWhere((transceiver) => !transceiver.disposed);
    for (var transceiver in _transceivers) {
      await transceiver.syncMid();
    }
  }

  /// Adds a new [RtpTransceiver] to this [PeerConnection].
  Future<RtpTransceiver> addTransceiver(
    MediaKind mediaType,
    RtpTransceiverInit init,
  );

  /// Returns all the [RtpTransceiver]s owned by this [PeerConnection].
  Future<List<RtpTransceiver>> getTransceivers();

  /// Returns all the [RtcStats] of this [PeerConnection].
  Future<List<RtcStats>> getStats();

  /// Sets the provided remote [SessionDescription] to the [PeerConnection].
  Future<void> setRemoteDescription(SessionDescription description);

  /// Sets the provided local [SessionDescription] to the [PeerConnection].
  Future<void> setLocalDescription(SessionDescription description);

  /// Creates a new [SessionDescription] offer.
  Future<SessionDescription> createOffer();

  /// Creates a new [SessionDescription] answer.
  Future<SessionDescription> createAnswer();

  /// Adds a new [IceCandidate] to the [PeerConnection].
  Future<void> addIceCandidate(IceCandidate candidate);

  /// Requests the [PeerConnection] to redo [IceCandidate]s gathering.
  Future<void> restartIce();

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
  }
}

/// [MethodChannel] used for the messaging with a native side.
final _peerConnectionFactoryMethodChannel = methodChannel(
  'PeerConnectionFactory',
  0,
);

/// [MethodChannel]-based implementation of a [PeerConnection].
class _PeerConnectionChannel extends PeerConnection {
  /// Creates a new [PeerConnection] with the provided [IceTransportType] and
  /// [IceServer]s.
  static Future<PeerConnection> create(
    IceTransportType iceTransportType,
    List<IceServer> iceServers,
  ) async {
    dynamic res = await _peerConnectionFactoryMethodChannel
        .invokeMethod('create', {
          'iceTransportType': iceTransportType.index,
          'iceServers': iceServers.map((s) => s.toMap()).toList(),
        });

    return _PeerConnectionChannel._fromMap(res);
  }

  /// Returns all [VideoCodecInfo]s of the supported video encoders.
  static Future<List<VideoCodecInfo>> videoEncoders() async {
    dynamic res = await _peerConnectionFactoryMethodChannel.invokeMethod(
      'videoEncoders',
    );
    res as List<dynamic>;

    return res.map((info) => VideoCodecInfo.fromMap(info)).toList();
  }

  /// Returns all [VideoCodecInfo]s of the supported video decoders.
  static Future<List<VideoCodecInfo>> videoDecoders() async {
    dynamic res = await _peerConnectionFactoryMethodChannel.invokeMethod(
      'videoDecoders',
    );
    res as List<dynamic>;

    return res.map((info) => VideoCodecInfo.fromMap(info)).toList();
  }

  /// Listener for the all [PeerConnection] events received from the native
  /// side.
  Future<void> eventListener(dynamic event) async {
    dynamic e = event;

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
        if (state == PeerConnectionState.closed) {
          _eventSub?.cancel();
        }
        _onConnectionStateChange?.call(state);
        break;
      case 'onTrack':
        dynamic track = e['track'];
        dynamic transceiver = e['transceiver'];
        _onTrack?.call(
          await NativeMediaStreamTrack.from(track),
          RtpTransceiver.fromMap(transceiver),
        );
        break;
    }
  }

  /// Creates a [PeerConnection] based on the [Map] received from the native
  /// side.
  _PeerConnectionChannel._fromMap(dynamic map) {
    int channelId = map['channelId'];
    _chan = methodChannel('PeerConnection', channelId);
    _eventChan = eventChannel('PeerConnectionEvent', channelId);
    _eventSub = _eventChan.receiveBroadcastStream().listen(eventListener);
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  /// [EventChannel] from which all [PeerConnection] events will be received.
  late EventChannel _eventChan;

  /// [_eventChan] subscription to the [PeerConnection] events.
  late StreamSubscription<dynamic>? _eventSub;

  @override
  Future<void> _syncTransceiversMids() async {
    _transceivers.retainWhere((transceiver) => !transceiver.disposed);
    for (var transceiver in _transceivers) {
      await transceiver.syncMid();
    }
  }

  /// Throws [StateError] if [_closed] is `true`.
  void _checkNotClosed() {
    if (_closed) {
      throw StateError('Use PeerConnection after close');
    }
  }

  @override
  Future<RtpTransceiver> addTransceiver(
    MediaKind mediaType,
    RtpTransceiverInit init,
  ) async {
    _checkNotClosed();

    dynamic res = await _chan.invokeMethod('addTransceiver', {
      'mediaType': mediaType.index,
      'init': init.toMap(),
    });
    var transceiver = RtpTransceiver.fromMap(res);
    _transceivers.add(transceiver);

    return transceiver;
  }

  @override
  Future<List<RtpTransceiver>> getTransceivers() async {
    _checkNotClosed();

    List<dynamic>? res = await _chan.invokeMethod('getTransceivers');
    var transceivers = res!.map((t) => RtpTransceiver.fromMap(t)).toList();
    _transceivers.addAll(transceivers);

    return transceivers;
  }

  @override
  Future<void> setRemoteDescription(SessionDescription description) async {
    _checkNotClosed();

    await _chan.invokeMethod('setRemoteDescription', {
      'description': description.toMap(),
    });
    await _syncTransceiversMids();
  }

  @override
  Future<void> setLocalDescription(SessionDescription description) async {
    _checkNotClosed();

    await _chan.invokeMethod('setLocalDescription', {
      'description': description.toMap(),
    });
    await _syncTransceiversMids();
  }

  @override
  Future<SessionDescription> createOffer() async {
    _checkNotClosed();

    dynamic res = await _chan.invokeMethod('createOffer');
    return SessionDescription.fromMap(res);
  }

  @override
  Future<SessionDescription> createAnswer() async {
    _checkNotClosed();

    dynamic res = await _chan.invokeMethod('createAnswer');
    return SessionDescription.fromMap(res);
  }

  @override
  Future<void> addIceCandidate(IceCandidate candidate) async {
    _checkNotClosed();

    await _chan.invokeMethod('addIceCandidate', {
      'candidate': candidate.toMap(),
    });
  }

  @override
  Future<void> restartIce() async {
    _checkNotClosed();

    await _chan.invokeMethod('restartIce');
  }

  @override
  PeerConnectionState connectionState() {
    return _connectionState;
  }

  @override
  IceConnectionState iceConnectionState() {
    return _iceConnectionState;
  }

  @override
  Future<void> close() async {
    _checkNotClosed();

    _onIceCandidate = null;
    _closed = true;
    await super.close();
    await _chan.invokeMethod('dispose');
  }

  @override
  Future<List<RtcStats>> getStats() async {
    List<dynamic> stats = await _chan.invokeMethod('getStats');
    List<RtcStats> result = List.empty(growable: true);

    for (var s in stats) {
      var stat = RtcStats.fromMap(s);
      if (stat != null) {
        result.add(stat);
      }
    }

    return result;
  }
}

/// FFI-based implementation of a [PeerConnection].
class _PeerConnectionFFI extends PeerConnection {
  /// Creates a new [PeerConnection] with the provided [IceTransportType] and
  /// [IceServer]s.
  static Future<PeerConnection> create(
    IceTransportType iceType,
    List<IceServer> iceServers,
  ) async {
    var cfg = ffi.RtcConfiguration(
      iceTransportPolicy: ffi.IceTransportsType.values[iceType.index],
      bundlePolicy: ffi.BundlePolicy.maxBundle,
      iceServers: iceServers
          .map(
            (server) => ffi.RtcIceServer(
              urls: server.urls,
              username: server.username != null ? server.username! : '',
              credential: server.password != null ? server.password! : '',
            ),
          )
          .toList(),
    );

    var peer = _PeerConnectionFFI();
    peer._stream = ffi.createPeerConnection(configuration: cfg);
    peer._stream!.listen(peer.eventListener);

    await peer._initialized.future;

    return peer;
  }

  /// This [Completer] is used to wait the [ffi.PeerCreated] `event` when
  /// creating a new [PeerConnection].
  final Completer _initialized = Completer();

  /// Native side peer connection.
  ArcPeerConnection? _peer;

  /// [Stream] for handling [PeerConnection] `event`s.
  Stream<ffi.PeerConnectionEvent>? _stream;

  _PeerConnectionFFI();

  /// Throws [StateError] if [_closed] is `true`.
  void _checkNotClosed() {
    if (_closed) {
      throw StateError('Use PeerConnection after close');
    }
  }

  /// Returns all [VideoCodecInfo]s of the supported video encoders.
  static Future<List<VideoCodecInfo>> videoEncoders() async {
    var res = await ffi.videoEncoders();
    return res.map((info) => VideoCodecInfo.fromFFI(info)).toList();
  }

  /// Returns all [VideoCodecInfo]s of the supported video decoders.
  static Future<List<VideoCodecInfo>> videoDecoders() async {
    var res = await ffi.videoDecoders();
    return res.map((info) => VideoCodecInfo.fromFFI(info)).toList();
  }

  /// Listener for the all [PeerConnection] events received from the native
  /// side.
  Future<void> eventListener(ffi.PeerConnectionEvent event) async {
    if (event is ffi.PeerConnectionEvent_PeerCreated) {
      _peer = event.peer;
      _initialized.complete();
      return;
    } else if (event is ffi.PeerConnectionEvent_IceCandidate) {
      _onIceCandidate?.call(
        IceCandidate(event.sdpMid, event.sdpMlineIndex, event.candidate),
      );
      return;
    } else if (event is ffi.PeerConnectionEvent_IceGatheringStateChange) {
      _onIceGatheringStateChange?.call(
        IceGatheringState.values[event.field0.index],
      );
      return;
    } else if (event is ffi.PeerConnectionEvent_IceCandidateError) {
      _onIceCandidateError?.call(
        IceCandidateErrorEvent.fromMap({
          'address': event.address,
          'port': event.port,
          'url': event.url,
          'errorCode': event.errorCode,
          'errorText': event.errorText,
        }),
      );
      return;
    } else if (event is ffi.PeerConnectionEvent_NegotiationNeeded) {
      _onNegotiationNeeded?.call();
      return;
    } else if (event is ffi.PeerConnectionEvent_SignallingChange) {
      _onSignalingStateChange?.call(SignalingState.values[event.field0.index]);
      return;
    } else if (event is ffi.PeerConnectionEvent_IceConnectionStateChange) {
      _iceConnectionState = IceConnectionState.values[event.field0.index];
      _onIceConnectionStateChange?.call(_iceConnectionState);
      return;
    } else if (event is ffi.PeerConnectionEvent_ConnectionStateChange) {
      _connectionState = PeerConnectionState.values[event.field0.index];
      _onConnectionStateChange?.call(_connectionState);
      return;
    } else if (event is ffi.PeerConnectionEvent_Track) {
      _onTrack?.call(
        await NativeMediaStreamTrack.from(event.field0.track),
        RtpTransceiver.fromFFI(event.field0.transceiver),
      );
      return;
    }
  }

  @override
  Future<void> addIceCandidate(IceCandidate candidate) async {
    _checkNotClosed();

    await ffi.addIceCandidate(
      peer: _peer!,
      candidate: candidate.candidate,
      sdpMid: candidate.sdpMid,
      sdpMlineIndex: candidate.sdpMLineIndex,
    );
  }

  @override
  Future<RtpTransceiver> addTransceiver(
    MediaKind mediaType,
    RtpTransceiverInit init,
  ) async {
    _checkNotClosed();

    var transceiver = RtpTransceiver.fromFFI(
      await ffi.addTransceiver(
        peer: _peer!,
        mediaType: ffi.MediaType.values[mediaType.index],
        init: ffi.RtpTransceiverInit(
          direction: ffi.RtpTransceiverDirection.values[init.direction.index],
          sendEncodings: init.sendEncodings.map((e) => e.toFFI().$1).toList(),
        ),
      ),
    );

    _transceivers.add(transceiver);

    return transceiver;
  }

  @override
  Future<void> close() async {
    _checkNotClosed();

    _onIceCandidate = null;
    _closed = true;
    await super.close();
    await ffi.disposePeerConnection(peer: _peer!);
    _peer!.dispose();
  }

  @override
  Future<SessionDescription> createAnswer() async {
    _checkNotClosed();

    var res = await ffi.createAnswer(
      peer: _peer!,
      voiceActivityDetection: true,
      iceRestart: false,
      useRtpMux: true,
    );

    return SessionDescription(SessionDescriptionType.answer, res.sdp);
  }

  @override
  Future<SessionDescription> createOffer() async {
    _checkNotClosed();

    var res = await ffi.createOffer(
      peer: _peer!,
      voiceActivityDetection: true,
      iceRestart: false,
      useRtpMux: true,
    );

    return SessionDescription(SessionDescriptionType.offer, res.sdp);
  }

  @override
  Future<List<RtpTransceiver>> getTransceivers() async {
    _checkNotClosed();

    var transceivers = (await ffi.getTransceivers(
      peer: _peer!,
    )).map((transceiver) => RtpTransceiver.fromFFI(transceiver)).toList();
    _transceivers.addAll(transceivers);

    return transceivers;
  }

  @override
  Future<void> restartIce() async {
    _checkNotClosed();

    return await ffi.restartIce(peer: _peer!);
  }

  @override
  Future<void> setLocalDescription(SessionDescription description) async {
    _checkNotClosed();

    await ffi.setLocalDescription(
      peer: _peer!,
      kind: ffi.SdpType.values[description.type.index],
      sdp: description.description,
    );
    await _syncTransceiversMids();
  }

  @override
  Future<void> setRemoteDescription(SessionDescription description) async {
    _checkNotClosed();

    await ffi.setRemoteDescription(
      peer: _peer!,
      kind: ffi.SdpType.values[description.type.index],
      sdp: description.description,
    );
    await _syncTransceiversMids();
  }

  @override
  Future<List<RtcStats>> getStats() async {
    var stats = await ffi.getPeerStats(peer: _peer!);
    List<RtcStats> result = List.empty(growable: true);

    for (var s in stats) {
      var stat = RtcStats.fromFFI(s);
      if (stat != null) {
        result.add(stat);
      }
    }

    return result;
  }
}
