import 'dart:async';

import 'package:flutter/services.dart';

import '/medea_flutter_webrtc.dart';
import '/src/api/bridge/api.dart' as ffi;
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
  void eventListener(dynamic event) async {
    final dynamic e = event;
    switch (e['event']) {
      case 'onEnded':
        _onEnded?.call();
        await _eventSub?.cancel();
        _eventSub = null;
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
      _stopped = true;
      _onEnded = null;
      await _chan.invokeMethod('dispose');
      await _eventSub?.cancel();
      _eventSub = null;
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
    ffi.MediaStreamTrack track,
  ) async {
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
    _eventSub = ffi
        .registerTrackObserver(
          peerId: _peerId,
          trackId: track.id,
          kind: ffi.MediaType.values[_kind.index],
        )
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
    if (!isOnAudioLevelAvailable()) {
      return;
    }
    ffi.setAudioLevelObserverEnabled(
      peerId: _peerId,
      trackId: _id,
      enabled: cb != null,
    );
    _onAudioLevelChanged = cb;
  }

  @override
  bool isOnAudioLevelAvailable() {
    return !_stopped && _kind == MediaKind.audio && _deviceId != 'remote';
  }

  @override
  Future<MediaStreamTrack> clone() async {
    var ffiTrack = _stopped
        ? null
        : await ffi.cloneTrack(
            trackId: _id,
            peerId: _peerId,
            kind: ffi.MediaType.values[_kind.index],
          );

    if (ffiTrack != null) {
      return NativeMediaStreamTrack.from(ffiTrack);
    } else {
      return NativeMediaStreamTrack.from(
        ffi.MediaStreamTrack(
          deviceId: _deviceId,
          enabled: _enabled,
          peerId: _peerId,
          id: _id,
          kind: ffi.MediaType.values[_kind.index],
        ),
      );
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!_stopped) {
      await ffi.setTrackEnabled(
        peerId: _peerId,
        trackId: _id,
        enabled: enabled,
        kind: ffi.MediaType.values[_kind.index],
      );
    }

    _enabled = enabled;
  }

  @override
  Future<MediaStreamTrackState> state() async {
    return !_stopped
        ? MediaStreamTrackState.values[(await ffi.trackState(
            peerId: _peerId,
            trackId: _id,
            kind: ffi.MediaType.values[_kind.index],
          )).index]
        : MediaStreamTrackState.ended;
  }

  @override
  FacingMode? facingMode() {
    return null;
  }

  @override
  Future<int?> height() async {
    if (_stopped) {
      return null;
    }

    return await ffi.trackHeight(
      trackId: _id,
      peerId: _peerId,
      kind: ffi.MediaType.values[_kind.index],
    );
  }

  @override
  Future<int?> width() async {
    if (_stopped) {
      return null;
    }

    return await ffi.trackWidth(
      trackId: _id,
      peerId: _peerId,
      kind: ffi.MediaType.values[_kind.index],
    );
  }

  @override
  Future<void> stop() async {
    if (!_stopped) {
      _onEnded = null;
      _onAudioLevelChanged = null;

      await ffi.disposeTrack(
        trackId: _id,
        peerId: _peerId,
        kind: ffi.MediaType.values[_kind.index],
      );
    }
    _stopped = true;
  }

  @override
  bool isAudioProcessingAvailable() {
    return !_stopped && _kind == MediaKind.audio && _deviceId != 'remote';
  }

  @override
  Future<void> setAutoGainControlEnabled(bool enabled) async {
    if (!isAudioProcessingAvailable()) {
      super.setAutoGainControlEnabled(enabled);
    }

    await ffi.updateAudioProcessing(
      trackId: _id,
      conf: ffi.AudioProcessingConstraints(autoGainControl: enabled),
    );
  }

  @override
  Future<void> setEchoCancellationEnabled(bool enabled) async {
    if (!isAudioProcessingAvailable()) {
      super.setEchoCancellationEnabled(enabled);
    }

    await ffi.updateAudioProcessing(
      trackId: _id,
      conf: ffi.AudioProcessingConstraints(echoCancellation: enabled),
    );
  }

  @override
  Future<void> setHighPassFilterEnabled(bool enabled) async {
    if (!isAudioProcessingAvailable()) {
      super.setHighPassFilterEnabled(enabled);
    }

    await ffi.updateAudioProcessing(
      trackId: _id,
      conf: ffi.AudioProcessingConstraints(highPassFilter: enabled),
    );
  }

  @override
  Future<void> setNoiseSuppressionEnabled(bool enabled) async {
    if (!isAudioProcessingAvailable()) {
      super.setNoiseSuppressionEnabled(enabled);
    }

    await ffi.updateAudioProcessing(
      trackId: _id,
      conf: ffi.AudioProcessingConstraints(noiseSuppression: enabled),
    );
  }

  @override
  Future<void> setNoiseSuppressionLevel(NoiseSuppressionLevel level) async {
    if (!isAudioProcessingAvailable()) {
      super.setNoiseSuppressionLevel(level);
    }

    await ffi.updateAudioProcessing(
      trackId: _id,
      conf: ffi.AudioProcessingConstraints(
        noiseSuppressionLevel: ffi.NoiseSuppressionLevel.values[level.index],
      ),
    );
  }

  @override
  Future<bool> isNoiseSuppressionEnabled() async {
    if (!isAudioProcessingAvailable()) {
      super.isNoiseSuppressionEnabled();
    }

    return (await ffi.getAudioProcessingConfig(trackId: _id)).noiseSuppression;
  }

  @override
  Future<NoiseSuppressionLevel> getNoiseSuppressionLevel() async {
    if (!isAudioProcessingAvailable()) {
      super.getNoiseSuppressionLevel();
    }

    var level = (await ffi.getAudioProcessingConfig(
      trackId: _id,
    )).noiseSuppressionLevel;

    return NoiseSuppressionLevel.values[level.index];
  }

  @override
  Future<bool> isHighPassFilterEnabled() async {
    if (!isAudioProcessingAvailable()) {
      super.isHighPassFilterEnabled();
    }

    return (await ffi.getAudioProcessingConfig(trackId: _id)).highPassFilter;
  }

  @override
  Future<bool> isEchoCancellationEnabled() async {
    if (!isAudioProcessingAvailable()) {
      super.isEchoCancellationEnabled();
    }

    return (await ffi.getAudioProcessingConfig(trackId: _id)).echoCancellation;
  }

  @override
  Future<bool> isAutoGainControlEnabled() async {
    if (!isAudioProcessingAvailable()) {
      super.isAutoGainControlEnabled();
    }

    return (await ffi.getAudioProcessingConfig(trackId: _id)).autoGainControl;
  }
}
