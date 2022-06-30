import 'package:flutter/services.dart';

import '/src/model/transceiver.dart';
import 'bridge.g.dart' as ffi;
import 'channel.dart';
import 'peer.dart';
import 'sender.dart';

/// [RTCTransceiver][1] representation
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
abstract class RtpTransceiver {
  /// Creates an [RtpTransceiver] basing on the [Map] received from the native
  /// side.
  static RtpTransceiver fromMap(dynamic map) {
    return _RtpTransceiverChannel.fromMap(map);
  }

  /// Creates an [RtpTransceiver] basing on the [ffi.RtcRtpTransceiver] received
  /// from the native side.
  static RtpTransceiver fromFFI(ffi.RtcRtpTransceiver transceiver) {
    return RtpTransceiverFFI(transceiver);
  }

  /// [RtpSender] owned by this [RtpTransceiver].
  late RtpSender _sender;

  /// Current mID of this [RtpTransceiver].
  ///
  /// mID will be automatically updated on all actions changing it.
  String? _mid;

  /// Indicates that this [RtpTransceiver] is stopped and doesn't send or
  /// receive media.
  bool _isStopped = false;

  /// Getter for the [RtpSender] of this [RtpTransceiver].
  RtpSender get sender => _sender;

  /// Returns current mID of this [RtpTransceiver].
  String? get mid => _mid;

  /// Changes the [TransceiverDirection] of this [RtpTransceiver].
  Future<void> setDirection(TransceiverDirection direction);

  /// Changes the receive direction of this [RtpTransceiver].
  ///
  /// This is designed to allow atomic change of an [RtpTransceiver] direction
  /// based on the current direction. Since [getDirection] and [setDirection]
  /// are both asynchronous operations changing direction might introduce data
  /// races.
  Future<void> setRecv(bool recv);

  /// Changes the send direction of this [RtpTransceiver].
  ///
  /// This is designed to allow atomic change of an [RtpTransceiver] direction
  /// based on the current direction. Since [getDirection] and [setDirection]
  /// are both asynchronous operations changing direction might introduce data
  /// races.
  Future<void> setSend(bool send);

  /// Returns current preferred [TransceiverDirection] of this [RtpTransceiver].
  Future<TransceiverDirection> getDirection();

  /// Synchronizes [_mid] of this [RtpTransceiver] with the native side.
  Future<void> syncMid();

  /// Stops this [RtpTransceiver].
  ///
  /// After this action, no media will be transferred from/to this
  /// [RtpTransceiver].
  Future<void> stop();

  /// Notifies the [RtpTransceiver] that it was stopped by the peer.
  void stoppedByPeer() {
    _isStopped = true;
  }

  /// Indicates whether this [RtpTransceiver] is not transferring media.
  bool isStopped() {
    return _isStopped;
  }
}

/// [MethodChannel]-based implementation of an [RtpTransceiver].
class _RtpTransceiverChannel extends RtpTransceiver {
  /// Creates an [RtpTransceiver] basing on the [Map] received from the native
  /// side.
  _RtpTransceiverChannel.fromMap(dynamic map) {
    int channelId = map['channelId'];
    _chan = methodChannel('RtpTransceiver', channelId);
    _sender = RtpSender.fromMap(map['sender']);
    _mid = map['mid'];
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    await _chan.invokeMethod('setDirection', {'direction': direction.index});
  }

  @override
  Future<TransceiverDirection> getDirection() async {
    return TransceiverDirection
        .values[await _chan.invokeMethod('getDirection')];
  }

  @override
  Future<void> syncMid() async {
    _mid = await _chan.invokeMethod('getMid');
  }

  @override
  Future<void> stop() async {
    _isStopped = true;
    await _chan.invokeMethod('stop');
  }

  @override
  Future<void> setRecv(bool recv) async {
    await _chan.invokeMethod('setRecv', {'recv': recv});
  }

  @override
  Future<void> setSend(bool send) async {
    await _chan.invokeMethod('setSend', {'send': send});
  }
}

/// FFI-based implementation of an [RtpTransceiver].
class RtpTransceiverFFI extends RtpTransceiver {
  RtpTransceiverFFI(ffi.RtcRtpTransceiver transceiver) {
    _peerId = transceiver.peerId;
    _id = transceiver.index;
    _sender = RtpSender.fromFFI(_peerId, _id);
    _mid = transceiver.mid;
  }

  /// ID of the native side peer.
  late final int _peerId;

  /// ID of the native side transceiver.
  late final int _id;

  /// Returns ID of the native side peer.
  int get id => _id;

  @override
  Future<TransceiverDirection> getDirection() async {
    return TransceiverDirection.values[(await api.getTransceiverDirection(
            peerId: _peerId, transceiverIndex: _id))
        .index];
  }

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    await api.setTransceiverDirection(
        peerId: _peerId,
        transceiverIndex: _id,
        direction: ffi.RtpTransceiverDirection.values[direction.index]);
  }

  @override
  Future<void> stop() async {
    await api.stopTransceiver(peerId: _peerId, transceiverIndex: _id);
  }

  @override
  Future<void> syncMid() async {
    _mid = await api.getTransceiverMid(peerId: _peerId, transceiverIndex: _id);
  }

  @override
  Future<void> setRecv(bool recv) async {
    await api.setTransceiverRecv(
        peerId: _peerId, transceiverIndex: _id, recv: recv);
  }

  @override
  Future<void> setSend(bool send) async {
    await api.setTransceiverSend(
        peerId: _peerId, transceiverIndex: _id, send: send);
  }
}
