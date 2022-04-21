import 'package:flutter/services.dart';

import '/src/platform/track.dart';
import 'channel.dart';
import 'peer.dart';

/// [RTCSender][1] implementation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtpsender
abstract class RtpSender {
  /// Creates an [RtpSender] basing on the [Map] received from the native side.
  static RtpSender fromMap(dynamic map) {
    return _RtpSenderChannel.fromMap(map);
  }

  /// Create a new [RtpSender] from the provided [peerId] and [transceiverId].
  static RtpSender fromFFI(int peerId, int transceiverId) {
    return _RtpSenderFFI(peerId, transceiverId);
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t);
}

/// [MethodChannel]-based implementation of a [RtpSender].
class _RtpSenderChannel extends RtpSender {
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
}

/// FFI-based implementation of a [RtpSender].
class _RtpSenderFFI extends RtpSender {
  /// ID of the native side peer.
  final int _peerId;

  /// ID of the native side transceiver.
  final int _transceiverId;

  _RtpSenderFFI(this._peerId, this._transceiverId);

  @override
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    await api.senderReplaceTrack(
        peerId: _peerId, transceiverIndex: _transceiverId, trackId: t?.id());
  }
}
