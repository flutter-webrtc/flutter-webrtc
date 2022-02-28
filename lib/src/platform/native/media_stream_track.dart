import 'package:flutter/services.dart';

import '/src/api/channel.dart';
import '/src/model/track.dart';
import '/src/platform/track.dart';

/// Representation of a single media unit.
class NativeMediaStreamTrack extends MediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  NativeMediaStreamTrack.fromMap(dynamic map) {
    _chan = methodChannel('MediaStreamTrack', map['channelId']);
    _id = map['id'];
    _deviceId = map['deviceId'];
    _kind = MediaKind.values[map['kind']];
  }

  /// Indicates whether this [NativeMediaStreamTrack] transmits media.
  ///
  /// If it's `false` then blank (black screen for video and `0dB` for audio)
  /// media will be transmitted.
  bool _enabled = true;

  /// Unique ID of this [NativeMediaStreamTrack].
  late String _id;

  /// [MediaKind] of this [NativeMediaStreamTrack].
  late MediaKind _kind;

  /// Unique ID of the device from which this [NativeMediaStreamTrack] was
  /// created.
  ///
  /// "remote" - for the remove tracks.
  late String _deviceId;

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _chan;

  @override
  String id() {
    return _id;
  }

  @override
  MediaKind kind() {
    return _kind;
  }

  @override
  String deviceId() {
    return _deviceId;
  }

  @override
  bool isEnabled() {
    return _enabled;
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    await _chan.invokeMethod('setEnabled', {'enabled': enabled});
    _enabled = enabled;
  }

  @override
  Future<void> stop() async {
    await _chan.invokeMethod('stop');
  }

  // TODO(evdokimovs): implement disposing for native side
  @override
  Future<void> dispose() async {}

  @override
  Future<MediaStreamTrack> clone() async {
    return NativeMediaStreamTrack.fromMap(await _chan.invokeMethod('clone'));
  }
}
