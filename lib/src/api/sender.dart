import 'package:flutter/services.dart';

import 'package:medea_flutter_webrtc/src/model/track.dart';
import '../model/capability.dart';
import '/src/api/parameters.dart';
import '/src/platform/track.dart';
import 'bridge/api.dart' as ffi;
import 'bridge/lib.dart';
import 'channel.dart';
import 'peer.dart';

/// [MethodChannel] used for the messaging with a native side.
final _peerConnectionFactoryMethodChannel =
    methodChannel('PeerConnectionFactory', 0);

/// [RTCSender][1] implementation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtpsender
abstract class RtpSender {
  /// Creates an [RtpSender] basing on the [Map] received from the native side.
  static RtpSender fromMap(dynamic map) {
    return _RtpSenderChannel.fromMap(map);
  }

  /// Create a new [RtpSender] from the provided [peerId] and [transceiverId].
  static RtpSender fromFFI(
      ArcPeerConnection peer, ArcRtpTransceiver transceiver) {
    return _RtpSenderFFI(peer, transceiver);
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t);

  /// Disposes this [RtpSender].
  Future<void> dispose();

  /// Returns [RtpParameters] of this [RtpSender].
  Future<RtpParameters> getParameters();

  /// Sets the provided [RtpParameters].
  Future<void> setParameters(RtpParameters parameters);

  /// [RtpCapabilities] of an RTP sender of the specified [MediaKind].
  static Future<RtpCapabilities> getCapabilities(MediaKind kind) {
    if (isDesktop) {
      return _RtpSenderFFI.getCapabilities(kind);
    } else {
      return _RtpSenderChannel.getCapabilities(kind);
    }
  }
}

/// [MethodChannel]-based implementation of an [RtpSender].
class _RtpSenderChannel extends RtpSender {
  /// [RtpCapabilities] of an [RTP] sender of the provided [MediaKind].
  ///
  /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
  static Future<RtpCapabilities> getCapabilities(MediaKind kind) async {
    var map = await _peerConnectionFactoryMethodChannel
        .invokeMethod('getRtpSenderCapabilities', {'kind': kind.index});
    return RtpCapabilities.fromMap(map);
  }

  /// Creates an [RtpSender] basing on the [Map] received from the native side.
  _RtpSenderChannel.fromMap(dynamic map) {
    _chan = methodChannel('RtpSender', map['channelId']);
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  @override
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    _track = t;
    await _chan.invokeMethod('replaceTrack', {'trackId': t?.id()});
  }

  @override
  Future<void> dispose() async {
    await _chan.invokeMethod('dispose');
  }

  @override
  Future<RtpParameters> getParameters() async {
    dynamic parameters = await _chan.invokeMethod('getParameters');

    return RtpParameters.fromMap(parameters);
  }

  @override
  Future<void> setParameters(RtpParameters parameters) async {
    await _chan.invokeListMethod('setParameters', parameters.toMap());
  }
}

/// FFI-based implementation of an [RtpSender].
class _RtpSenderFFI extends RtpSender {
  /// [RtpCapabilities] of an [RTP] sender of the provided [MediaKind].
  ///
  /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
  static Future<RtpCapabilities> getCapabilities(MediaKind kind) async {
    return RtpCapabilities.fromFFI(await ffi.getRtpSenderCapabilities(
        kind: ffi.MediaType.values[kind.index]));
  }

  /// Native side peer connection.
  final ArcPeerConnection _peer;

  /// Native side transceiver.
  final ArcRtpTransceiver _transceiver;

  _RtpSenderFFI(this._peer, this._transceiver);

  @override
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    await ffi.senderReplaceTrack(
        peer: _peer, transceiver: _transceiver, trackId: t?.id());
  }

  @override
  Future<void> dispose() async {
    // no-op for FFI implementation
  }

  @override
  Future<RtpParameters> getParameters() async {
    return RtpParameters.fromFFI(
        await ffi.senderGetParameters(transceiver: _transceiver));
  }

  @override
  Future<void> setParameters(RtpParameters parameters) async {
    await ffi.senderSetParameters(
        transceiver: _transceiver, params: parameters.toFFI());
  }
}
