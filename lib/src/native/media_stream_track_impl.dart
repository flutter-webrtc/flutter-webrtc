import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../helper.dart';
import 'event_channel.dart';
import 'utils.dart';

class MediaStreamTrackNative extends MediaStreamTrack {
  MediaStreamTrackNative(this._trackId, this._label, this._kind, this._enabled,
      this._peerConnectionId,
      [this.settings_ = const {}]);

  factory MediaStreamTrackNative.fromMap(
      Map<dynamic, dynamic> map, String peerConnectionId) {
    return MediaStreamTrackNative(map['id'], map['label'], map['kind'],
        map['enabled'], peerConnectionId, map['settings'] ?? {});
  }
  final String _trackId;
  final String _label;
  final String _kind;
  final String _peerConnectionId;
  final Map<Object?, Object?> settings_;

  bool _enabled;

  bool _muted = false;

  // onEnded fires when the native side reports that the track ended by
  // itself (`mediaStreamTrackEnded`, sent on Android when the system stops a
  // screen capture). The track listens to the event channel only while a
  // handler is set and until the track is stopped.
  StreamTrackCallback? _onEnded;
  StreamSubscription<Map<String, dynamic>>? _endedSubscription;

  @override
  StreamTrackCallback? get onEnded => _onEnded;

  @override
  set onEnded(StreamTrackCallback? callback) {
    _onEnded = callback;
    if (callback == null) {
      _stopWatchingEnded();
    } else {
      _endedSubscription ??= FlutterWebRTCEventChannel
          .instance.handleEvents.stream
          .listen(_onNativeEvent);
    }
  }

  void _onNativeEvent(Map<String, dynamic> event) {
    final ended = event['mediaStreamTrackEnded'];
    if (ended is Map && ended['trackId'] == _trackId) {
      final callback = _onEnded;
      _stopWatchingEnded();
      callback?.call();
    }
  }

  void _stopWatchingEnded() {
    unawaited(_endedSubscription?.cancel());
    _endedSubscription = null;
  }

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
    return stop();
  }

  @override
  Future<void> stop() async {
    _stopWatchingEnded();
    await WebRTC.invokeMethod(
      'trackDispose',
      <String, dynamic>{'trackId': _trackId},
    );
  }
}
