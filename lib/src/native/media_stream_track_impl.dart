import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../helper.dart';
import 'utils.dart';

class MediaStreamTrackNative extends MediaStreamTrack {
  MediaStreamTrackNative(
    this._trackId,
    this._label,
    this._kind,
    this._enabled,
    this._peerConnectionId,
    [this.settings_ = const {},
    this.isLocal = false] // Default isLocal to false if not specified
  );

  factory MediaStreamTrackNative.fromMap(
      Map<dynamic, dynamic> map, String peerConnectionId, {bool isLocalTrack = false}) {
    return MediaStreamTrackNative(
      map['id'] as String,
      map['label'] as String,
      map['kind'] as String,
      map['enabled'] as bool,
      peerConnectionId,
      map['settings'] as Map<Object?, Object?>? ?? const {},
      isLocalTrack, // Pass isLocalTrack to constructor
    );
  }
  final String _trackId;
  final String _label;
  final String _kind;
  final String _peerConnectionId;
  final Map<Object?, Object?> settings_;
  final bool isLocal; // Flag to indicate if it's a local track

  bool _enabled;
  String _readyState = 'live'; // Possible values: 'live', 'ended'

  // Stream controller for the onEnded event
  final StreamController<void> _onEndedController = StreamController<void>.broadcast();

  /// Stream that emits an event when the track ends.
  @override
  Stream<void> get onEnded => _onEndedController.stream;

  bool _muted = false;

  String get peerConnectionId => _peerConnectionId;

  @override
  set enabled(bool enabled) {
    WebRTC.invokeMethod('mediaStreamTrackSetEnable', <String, dynamic>{
      'trackId': _trackId,
      'enabled': enabled,
      'peerConnectionId': _peerConnectionId
    });
    _enabled = enabled;

    if (kind == 'audio') {
      _muted = !enabled;
      muted ? onMute?.call() : onUnMute?.call();
    }
  }

  @override
  bool get enabled => _enabled;

  @override
  String get label => _label;

  @override
  String get kind => _kind;

  @override
  String get id => _trackId;

  @override
  String get readyState => _readyState;

  @override
  bool get muted => _muted;

  @override
  Future<bool> hasTorch() => WebRTC.invokeMethod(
        'mediaStreamTrackHasTorch',
        <String, dynamic>{'trackId': _trackId},
      ).then((value) => value ?? false);

  @override
  Future<void> setTorch(bool torch) => WebRTC.invokeMethod(
        'mediaStreamTrackSetTorch',
        <String, dynamic>{'trackId': _trackId, 'torch': torch},
      );

  @override
  Future<bool> switchCamera() => Helper.switchCamera(this);

  Future<void> setZoom(double zoomLevel) => Helper.setZoom(this, zoomLevel);

  @Deprecated('Use Helper.setSpeakerphoneOn instead')
  @override
  void enableSpeakerphone(bool enable) async {
    return Helper.setSpeakerphoneOn(enable);
  }

  @override
  Future<ByteBuffer> captureFrame() async {
    var filePath = await getTemporaryDirectory();
    await WebRTC.invokeMethod(
      'captureFrame',
      <String, dynamic>{
        'trackId': _trackId,
        'peerConnectionId': _peerConnectionId,
        'path': '${filePath.path}/captureFrame.png'
      },
    );
    return File('${filePath.path}/captureFrame.png')
        .readAsBytes()
        .then((value) => value.buffer);
  }

  @override
  Future<void> applyConstraints([Map<String, dynamic>? constraints]) {
    if (constraints == null) return Future.value();

    var current = getConstraints();
    if (constraints.containsKey('volume') &&
        current['volume'] != constraints['volume']) {
      Helper.setVolume(constraints['volume'], this);
    }

    return Future.value();
  }

  @override
  Map<String, dynamic> getSettings() {
    return settings_.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Future<void> dispose() async {
    await stop(); // stop() will call setEnded and close controller
  }

  @override
  Future<void> stop() async {
    // Call setEnded first to update state and notify listeners
    // before the native track is actually disposed.
    setEnded();

    await WebRTC.invokeMethod(
      'trackDispose',
      <String, dynamic>{'trackId': _trackId, 'peerConnectionId': _peerConnectionId},
    );
  }

  /// Called by external events (e.g., native layer, or when RTCPeerConnection.onRemoveTrack fires)
  /// to signal that the track has ended.
  void setEnded() {
    if (_readyState == 'ended') return; // Already ended

    print('MediaStreamTrackNative [$id] ended.');
    _readyState = 'ended';
    _enabled = false; // A track that ended is also effectively disabled

    if (!_onEndedController.isClosed) {
      _onEndedController.add(null); // Signal the event
      _onEndedController.close();   // Close the stream as 'ended' is a final state
    }
  }

  /// Restarts a local track.
  /// This involves stopping the current track and re-acquiring a new one
  /// using the provided [mediaConstraints].
  /// Returns the new [MediaStreamTrack] if successful, otherwise null.
  /// The caller (e.g. CallQualityManager or application) is responsible
  /// for replacing this track on any RTCRtpSenders using `sender.replaceTrack(newTrack)`.
  Future<MediaStreamTrack?> restart(Map<String, dynamic> mediaConstraints) async {
    if (!isLocal) {
      final message = 'MediaStreamTrackNative [$id] restart() called on a non-local track. Operation aborted.';
      print(message);
      throw Exception(message);
    }
    if (_readyState == 'ended') {
       // This instance is already ended, conceptually it cannot be "restarted".
       // A new track should be created by the application logic that originally created this one.
       // However, for auto-restart scenarios, we might allow creating a new track from here.
       print('MediaStreamTrackNative [$id] restart() called on an already ended track. Will attempt to acquire a new track of the same kind.');
    }

    print('MediaStreamTrackNative [$id] restarting with constraints: $mediaConstraints...');
    final oldKind = kind; // Save kind

    // Ensure the current track is fully stopped before attempting to get a new one.
    // This also marks it as 'ended' and notifies listeners.
    if (_readyState != 'ended') {
      await stop();
    }

    try {
      // Re-acquire the stream with new constraints
      // Note: navigator.mediaDevices should be accessible here.
      // If not, it might need to be passed in or accessed via a singleton.
      final newStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      MediaStreamTrack? newTrack;

      if (oldKind == 'video') {
        newTrack = newStream.getVideoTracks().firstOrNull;
      } else if (oldKind == 'audio') {
        newTrack = newStream.getAudioTracks().firstOrNull;
      }

      if (newTrack != null) {
        print('MediaStreamTrackNative [$id] successfully re-acquired as new track ID: ${newTrack.id} of kind $oldKind.');
        // The current instance (_this_) remains 'ended'. We return the NEW track.
        return newTrack;
      } else {
        print('MediaStreamTrackNative [$id] restart failed: No track of kind $oldKind found in new stream from getUserMedia.');
        return null;
      }
    } catch (e) {
      print('MediaStreamTrackNative [$id] restart failed during getUserMedia: $e');
      if (e is MediaDeviceAcquireError) rethrow; // Propagate specific errors
      return null;
    }
  }
}
