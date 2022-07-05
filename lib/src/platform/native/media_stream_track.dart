import 'dart:async';

import 'package:flutter/services.dart';

import '/flutter_webrtc.dart';
import '/src/api/bridge.g.dart' as ffi;
import '/src/api/channel.dart';

/// Representation of a single media unit.
abstract class NativeMediaStreamTrack extends MediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  static NativeMediaStreamTrack from(dynamic map) {
    if (isDesktop) {
      return _NativeMediaStreamTrackFFI(map);
    } else {
      return _NativeMediaStreamTrackChannel.fromMap(map);
    }
  }

  /// Indicates whether this [NativeMediaStreamTrack] has been stopped.
  bool _stopped = false;

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

  /// [ended][1] event subscriber.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#event-mediastreamtrack-ended
  OnEndedCallback? _onEnded;

  /// [_eventChan] subscription to the [PeerConnection] events.
  late StreamSubscription<dynamic>? _eventSub;

  /// Listener for all the [MediaStreamTrack] events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic e = event;
    switch (e['event']) {
      case 'onEnded':
        _onEnded?.call();
        break;
    }
  }

  @override
  void onEnded(OnEndedCallback cb) {
    _onEnded = cb;
  }

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
}

/// [MethodChannel]-based implementation of a [NativeMediaStreamTrack].
class _NativeMediaStreamTrackChannel extends NativeMediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  _NativeMediaStreamTrackChannel.fromMap(dynamic map) {
    var channelId = map['channelId'];
    _chan = methodChannel('MediaStreamTrack', channelId);
    _eventChan = eventChannel('MediaStreamTrackEvent', channelId);
    _eventSub = _eventChan.receiveBroadcastStream().listen(eventListener);
    _id = map['id'];
    _deviceId = map['deviceId'];
    _kind = MediaKind.values[map['kind']];
  }

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _chan;

  /// [EventChannel] to receive all the [PeerConnection] events from.
  late EventChannel _eventChan;

  @override
  Future<void> setEnabled(bool enabled) async {
    await _chan.invokeMethod('setEnabled', {'enabled': enabled});
    _enabled = enabled;
  }

  @override
  Future<MediaStreamTrackState> state() async {
    return !_stopped
        ? MediaStreamTrackState.values[await _chan.invokeMethod('state')]
        : MediaStreamTrackState.ended;
  }

  @override
  Future<void> stop() async {
    if (!_stopped) {
      _onEnded = null;
      await _chan.invokeMethod('stop');
      _stopped = true;
    }
  }

  @override
  Future<void> dispose() async {
    _onEnded = null;
    await _chan.invokeMethod('dispose');
    await _eventSub?.cancel();
  }

  @override
  Future<MediaStreamTrack> clone() async {
    return NativeMediaStreamTrack.from(await _chan.invokeMethod('clone'));
  }
}

/// FFI-based implementation of a [NativeMediaStreamTrack].
class _NativeMediaStreamTrackFFI extends NativeMediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the provided
  /// [ffi.MediaStreamTrack].
  _NativeMediaStreamTrackFFI(ffi.MediaStreamTrack track) {
    _id = track.id.toString();
    _deviceId = track.deviceId;
    _kind = MediaKind.values[track.kind.index];
    _eventSub = api!
        .registerTrackObserver(
            trackId: track.id, kind: ffi.MediaType.values[_kind.index])
        .listen((event) {
      if (_onEnded != null) {
        _onEnded!();
      }
    });
  }

  @override
  Future<MediaStreamTrack> clone() async {
    if (!_stopped) {
      return NativeMediaStreamTrack.from(await api!
          .cloneTrack(trackId: _id, kind: ffi.MediaType.values[_kind.index]));
    } else {
      return NativeMediaStreamTrack.from(ffi.MediaStreamTrack(
          deviceId: _deviceId,
          enabled: _enabled,
          id: _id,
          kind: ffi.MediaType.values[_kind.index]));
    }
  }

  @override
  Future<void> dispose() async {
    // no-op for FFI implementation
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!_stopped) {
      await api!.setTrackEnabled(
          trackId: _id,
          enabled: enabled,
          kind: ffi.MediaType.values[_kind.index]);
    }

    _enabled = enabled;
  }

  @override
  Future<MediaStreamTrackState> state() async {
    return !_stopped
        ? MediaStreamTrackState.values[(await api!.trackState(
                trackId: _id, kind: ffi.MediaType.values[_kind.index]))
            .index]
        : MediaStreamTrackState.ended;
  }

  @override
  Future<void> stop() async {
    if (!_stopped) {
      _onEnded = null;

      await api!
          .disposeTrack(trackId: _id, kind: ffi.MediaType.values[_kind.index]);
    }
    _stopped = true;
  }
}
