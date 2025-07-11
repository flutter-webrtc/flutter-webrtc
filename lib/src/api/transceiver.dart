import 'package:flutter/services.dart';

import 'package:medea_flutter_webrtc/src/model/capability.dart';
import '/src/model/transceiver.dart';
import 'bridge/api.dart' as ffi;
import 'bridge/api/capability/rtp_codec.dart' as ffi;
import 'bridge/lib.dart';
import 'channel.dart';
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
    return _RtpTransceiverFFI(transceiver);
  }

  /// [RtpSender] owned by this [RtpTransceiver].
  late RtpSender _sender;

  /// Indicates whether the [dispose] was called.
  bool _disposed = false;

  /// Current mID of this [RtpTransceiver].
  ///
  /// mID will be automatically updated on all actions changing it.
  String? _mid;

  /// Indicates that this [RtpTransceiver] is stopped and doesn't send or
  /// receive media.
  bool _isStopped = false;

  /// Getter for the [RtpSender] of this [RtpTransceiver].
  RtpSender get sender => _sender;

  /// Indicates whether the [dispose] was called.
  bool get disposed => _disposed;

  /// Returns current mID of this [RtpTransceiver].
  String? get mid => _mid;

  /// Changes the [TransceiverDirection] of this [RtpTransceiver].
  Future<void> setDirection(TransceiverDirection direction);

  /// Changes the preferred [RtpTransceiver] codecs to the [provided] list of
  /// [RtpCodecCapability]s.
  Future<void> setCodecPreferences(List<RtpCodecCapability> codecs);

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

  /// Disposes this [RtpTransceiver].
  Future<void> dispose();
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
  Future<void> setCodecPreferences(List<RtpCodecCapability> codecs) async {
    await _chan.invokeMethod('setCodecPreferences', {
      'codecs': codecs.map((c) => c.toMap()).toList(),
    });
  }

  @override
  Future<TransceiverDirection> getDirection() async {
    return TransceiverDirection.values[await _chan.invokeMethod(
      'getDirection',
    )];
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

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _chan.invokeMethod('dispose');
    await sender.dispose();
  }
}

/// FFI-based implementation of an [RtpTransceiver].
class _RtpTransceiverFFI extends RtpTransceiver {
  _RtpTransceiverFFI(ffi.RtcRtpTransceiver transceiver) {
    _peer = transceiver.peer;
    _transceiver = transceiver.transceiver;
    _sender = RtpSender.fromFFI(_peer, _transceiver);
    _mid = transceiver.mid;
  }

  /// Native side peer connection.
  late final ArcPeerConnection _peer;

  /// Native side transceiver.
  late final ArcRtpTransceiver _transceiver;

  @override
  Future<TransceiverDirection> getDirection() async {
    return TransceiverDirection.values[(await ffi.getTransceiverDirection(
      transceiver: _transceiver,
    )).index];
  }

  @override
  Future<void> setDirection(TransceiverDirection direction) async {
    await ffi.setTransceiverDirection(
      transceiver: _transceiver,
      direction: ffi.RtpTransceiverDirection.values[direction.index],
    );
  }

  @override
  Future<void> setCodecPreferences(List<RtpCodecCapability> codecs) async {
    var ffiCodecs = codecs.map((c) {
      var params = c.parameters.entries.map((e) => (e.key, e.value)).toList();
      return ffi.RtpCodecCapability(
        clockRate: c.clockRate,
        numChannels: c.numChannels,
        preferredPayloadType: c.preferredPayloadType,
        scalabilityModes: List.empty(),
        mimeType: c.mimeType,
        name: c.name,
        kind: ffi.MediaType.values[c.kind.index],
        parameters: params,
        feedback: List.empty(),
      );
    }).toList();
    await ffi.setCodecPreferences(transceiver: _transceiver, codecs: ffiCodecs);
  }

  @override
  Future<void> stop() async {
    await ffi.stopTransceiver(transceiver: _transceiver);
  }

  @override
  Future<void> syncMid() async {
    _mid = await ffi.getTransceiverMid(transceiver: _transceiver);
  }

  @override
  Future<void> setRecv(bool recv) async {
    await ffi.setTransceiverRecv(transceiver: _transceiver, recv: recv);
  }

  @override
  Future<void> setSend(bool send) async {
    await ffi.setTransceiverSend(transceiver: _transceiver, send: send);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _transceiver.dispose();
    _peer.dispose();
  }
}
