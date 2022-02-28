import 'package:flutter/services.dart';

import '/src/model/transceiver.dart';
import 'channel.dart';
import 'sender.dart';

class RtpTransceiver {
  /// Creates an [RtpTransceiver] basing on the [Map] received from the native
  /// side.
  RtpTransceiver.fromMap(dynamic map) {
    int channelId = map['channelId'];
    _chan = methodChannel('RtpTransceiver', channelId);
    _sender = RtpSender.fromMap(map['sender']);
    _mid = map['mid'];
  }

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

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
  Future<void> setDirection(TransceiverDirection direction) async {
    await _chan.invokeMethod('setDirection', {'direction': direction.index});
  }

  /// Returns current preferred [TransceiverDirection] of this [RtpTransceiver].
  Future<TransceiverDirection> getDirection() async {
    int res = await _chan.invokeMethod('getDirection');
    return TransceiverDirection.values[res];
  }

  /// Synchronizes [_mid] of this [RtpTransceiver] with the native side.
  Future<void> syncMid() async {
    _mid = await _chan.invokeMethod('getMid');
  }

  /// Stops this [RtpTransceiver].
  ///
  /// After this action, no media will be transferred from/to this
  /// [RtpTransceiver].
  Future<void> stop() async {
    _isStopped = true;
    await _chan.invokeMethod('stop');
  }

  /// Notifies the [RtpTransceiver] that it was stopped by the peer.
  void stoppedByPeer() {
    _isStopped = true;
  }

  /// Indicates whether this [RtpTransceiver] is not transferring media.
  bool isStopped() {
    return _isStopped;
  }
}
