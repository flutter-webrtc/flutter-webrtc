import 'dart:async';

import 'package:flutter/services.dart';

import '/medea_flutter_webrtc.dart';
import '/src/api/bridge.g.dart' as ffi;
import '/src/api/channel.dart';

/// Representation of a single media unit.
abstract class NativeMediaStreamTrack extends MediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  static Future<NativeMediaStreamTrack> from(dynamic map) async {
    if (isDesktop) {
      return await _NativeMediaStreamTrackFFI.create(map);
    } else {
      return _NativeMediaStreamTrackChannel.fromMap(map);
    }
  }

  /// Indicates whether this [NativeMediaStreamTrack] has been stopped.
  bool _stopped = false;

  /// Indicates whether this [NativeMediaStreamTrack] has been disposed.
  bool _disposed = false;

  /// Indicates whether this [NativeMediaStreamTrack] transmits media.
  ///
  /// If it's `false` then blank (black screen for video and `0dB` for audio)
  /// media will be transmitted.
  bool _enabled = true;

  /// ID of the [PeerConnection] that fired this track in its
  /// [PeerConnection.onTrack] callback.
  ///
  /// Always `null` for local tracks.
  int? _peerId;

  /// Returns ID of the [PeerConnection] that fired this track in its
  /// [PeerConnection.onTrack] callback.
  ///
  /// Always `null` for local tracks.
  int? get peerId => _peerId;

  /// Unique ID of this [NativeMediaStreamTrack].
  late String _id;

  /// [MediaKind] of this [NativeMediaStreamTrack].
  late MediaKind _kind;

  /// [FacingMode] of this [NativeMediaStreamTrack].
  FacingMode? _facingMode;

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
    if (map['facingMode'] != null) {
      _facingMode = FacingMode.values[map['facingMode']];
    }
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
    if (!_stopped && !_disposed) {
      _stopped = true;
      _onEnded = null;
      await _chan.invokeMethod('stop');
    }
  }

  @override
  Future<void> dispose() async {
    if (!_disposed) {
      _disposed = true;
      _onEnded = null;
      if (!_stopped) {
        _stopped = true;
        await _chan.invokeMethod('stop');
      }
      await _chan.invokeMethod('dispose');
      await _eventSub?.cancel();
    }
  }

  @override
  Future<MediaStreamTrack> clone() async {
    return NativeMediaStreamTrack.from(await _chan.invokeMethod('clone'));
  }

  @override
  FacingMode? facingMode() {
    return _facingMode;
  }

  @override
  Future<int?> height() async {
    return await _chan.invokeMethod('height');
  }

  @override
  Future<int?> width() async {
    return await _chan.invokeMethod('width');
  }
}

/// FFI-based implementation of a [NativeMediaStreamTrack].
class _NativeMediaStreamTrackFFI extends NativeMediaStreamTrack {
  /// Subscriber for audio level updates of this track.
  OnAudioLevelChangedCallback? _onAudioLevelChanged;

  /// [Completer] used to await for the [ffi.TrackCreated] event after creating
  /// a new [MediaStreamTrack].
  final Completer _initialized = Completer();

  /// Creates a new [MediaStreamTrack] from the provided [ffi.MediaStreamTrack].
  static Future<_NativeMediaStreamTrackFFI> create(
      ffi.MediaStreamTrack track) async {
    var ffiTrack = _NativeMediaStreamTrackFFI(track);
    await ffiTrack._initialized.future;
    return ffiTrack;
  }

  /// Creates a [NativeMediaStreamTrack] basing on the provided
  /// [ffi.MediaStreamTrack].
  _NativeMediaStreamTrackFFI(ffi.MediaStreamTrack track) {
    _id = track.id.toString();
    _deviceId = track.deviceId;
    _peerId = track.peerId;
    _kind = MediaKind.values[track.kind.index];
    _eventSub = api!
        .registerTrackObserver(
            peerId: _peerId,
            trackId: track.id,
            kind: ffi.MediaType.values[_kind.index])
        .listen((event) {
      if (event is ffi.TrackEvent_AudioLevelUpdated) {
        _onAudioLevelChanged?.call(event.field0);
      } else if (event is ffi.TrackEvent_Ended) {
        _onEnded?.call();
      } else if (event is ffi.TrackEvent_TrackCreated) {
        _initialized.complete();
      }
    });
  }

  @override
  void onAudioLevelChanged(OnAudioLevelChangedCallback? cb) {
    api!.setAudioLevelObserverEnabled(
      peerId: _peerId,
      trackId: _id,
      enabled: cb != null,
    );
    _onAudioLevelChanged = cb;
  }

  @override
  bool isOnAudioLevelAvailable() {
    if (_kind != MediaKind.audio || _deviceId == 'remote') {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<MediaStreamTrack> clone() async {
    if (!_stopped) {
      return NativeMediaStreamTrack.from(await api!.cloneTrack(
          trackId: _id,
          peerId: _peerId,
          kind: ffi.MediaType.values[_kind.index]));
    } else {
      return NativeMediaStreamTrack.from(ffi.MediaStreamTrack(
          deviceId: _deviceId,
          enabled: _enabled,
          peerId: _peerId,
          id: _id,
          kind: ffi.MediaType.values[_kind.index]));
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!_stopped) {
      await api!.setTrackEnabled(
          peerId: _peerId,
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
                peerId: _peerId,
                trackId: _id,
                kind: ffi.MediaType.values[_kind.index]))
            .index]
        : MediaStreamTrackState.ended;
  }

  @override
  FacingMode? facingMode() {
    return null;
  }

  @override
  Future<int?> height() async {
    return await api!.trackHeight(
        trackId: _id, peerId: _peerId, kind: ffi.MediaType.values[_kind.index]);
  }

  @override
  Future<int?> width() async {
    return await api!.trackWidth(
        trackId: _id, peerId: _peerId, kind: ffi.MediaType.values[_kind.index]);
  }

  @override
  Future<void> stop() async {
    if (!_stopped) {
      _onEnded = null;

      await api!.disposeTrack(
          trackId: _id,
          peerId: _peerId,
          kind: ffi.MediaType.values[_kind.index]);
    }
    _stopped = true;
  }
}
