import 'package:flutter/services.dart';

import '/src/platform/track.dart';
import 'channel.dart';

class RtpSender {
  /// Creates an [RtpSender] basing on the [Map] received from the native side.
  RtpSender.fromMap(dynamic map) {
    _chan = methodChannel('RtpSender', map['channelId']);
  }

  /// Current [MediaStreamTrack] of this [RtpSender].
  MediaStreamTrack? _track;

  /// [MethodChannel] used for the messaging with the native side.
  late MethodChannel _chan;

  /// Getter for the [MediaStreamTrack] currently owned by this [RtpSender].
  MediaStreamTrack? get track => _track;

  /// Replaces [MediaStreamTrack] of this [RtpSender].
  Future<void> replaceTrack(MediaStreamTrack? t) async {
    _track = t;
    await _chan.invokeMethod('replaceTrack', {'trackId': t?.id()});
  }
}
