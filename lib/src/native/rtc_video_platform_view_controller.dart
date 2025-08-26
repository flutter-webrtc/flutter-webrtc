import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import '../helper.dart';
import '../video_renderer_extension.dart' show AudioControl;
import 'utils.dart';

class RTCVideoPlatformViewController extends ValueNotifier<RTCVideoValue>
    implements VideoRenderer, AudioControl {
  RTCVideoPlatformViewController(int viewId) : super(RTCVideoValue.empty) {
    _viewId = viewId;
  }
  int? _viewId;
  bool _disposed = false;
  MediaStream? _srcObject;
  StreamSubscription<dynamic>? _eventSubscription;

  @override
  Future<void> initialize() async {
    _eventSubscription?.cancel();
    _eventSubscription = EventChannel('FlutterWebRTC/PlatformViewId$_viewId')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int? get textureId => _viewId;

  @override
  MediaStream? get srcObject => _srcObject;

  @override
  Function? onResize;

  @override
  Function? onFirstFrameRendered;

  Function? onSrcObjectChange;

  @override
  set srcObject(MediaStream? stream) {
    if (_disposed) {
      throw 'Can\'t set srcObject: The RTCVideoPlatformController is disposed';
    }
    if (_viewId == null) throw 'Call initialize before setting the stream';
    if (_srcObject == stream) return;
    _srcObject = stream;
    onSrcObjectChange?.call();
    WebRTC.invokeMethod(
        'videoPlatformViewRendererSetSrcObject', <String, dynamic>{
      'viewId': _viewId,
      'streamId': stream?.id ?? '',
      'ownerTag': stream?.ownerTag ?? ''
    }).then((_) {
      value = (stream == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    }).catchError((e) {
      print(
          'Got exception for RTCVideoPlatformController::setSrcObject: ${e.message}');
    }, test: (e) => e is PlatformException);
  }

  Future<void> setSrcObject({MediaStream? stream, String? trackId}) async {
    if (_disposed) {
      throw 'Can\'t set srcObject: The RTCVideoPlatformController is disposed';
    }
    if (_viewId == null) throw 'Call initialize before setting the stream';
    if (_srcObject == stream) return;
    _srcObject = stream;
    onSrcObjectChange?.call();
    var oldviewId = _viewId;
    try {
      await WebRTC.invokeMethod(
          'videoPlatformViewRendererSetSrcObject', <String, dynamic>{
        'viewId': _viewId,
        'streamId': stream?.id ?? '',
        'ownerTag': stream?.ownerTag ?? '',
        'trackId': trackId ?? '0'
      });
      value = (stream == null)
          ? RTCVideoValue.empty
          : value.copyWith(renderVideo: renderVideo);
    } on PlatformException catch (e) {
      throw 'Got exception for RTCVideoPlatformController::setSrcObject: viewId $oldviewId [disposed: $_disposed] with stream ${stream?.id}, error: ${e.message}';
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (_viewId != null) {
      try {
        await WebRTC.invokeMethod(
            'videoPlatformViewRendererDispose', <String, dynamic>{
          'viewId': _viewId,
        });
        _viewId = null;
      } on PlatformException catch (e) {
        throw 'Failed to RTCVideoPlatformController::dispose: ${e.message}';
      }
    }
    _disposed = true;
    super.dispose();
  }

  void eventListener(dynamic event) {
    if (_disposed) return;
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didPlatformViewChangeRotation':
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'didPlatformViewChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'didFirstFrameRendered':
        value = value.copyWith(renderVideo: renderVideo);
        onFirstFrameRendered?.call();
        break;
    }
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  bool get renderVideo => _viewId != null && _srcObject != null;

  @override
  bool get muted => _srcObject?.getAudioTracks()[0].muted ?? true;

  @override
  set muted(bool mute) {
    if (_disposed) {
      throw Exception(
          'Can\'t be muted: The RTCVideoPlatformController is disposed');
    }
    if (_srcObject == null) {
      throw Exception('Can\'t be muted: The MediaStream is null');
    }
    if (_srcObject!.ownerTag != 'local') {
      throw Exception(
          'You\'re trying to mute a remote track, this is not supported');
    }
    if (_srcObject!.getAudioTracks().isEmpty) {
      throw Exception('Can\'t be muted: The MediaStreamTrack(audio) is empty');
    }

    Helper.setMicrophoneMute(mute, _srcObject!.getAudioTracks()[0]);
  }

  @override
  Future<bool> audioOutput(String deviceId) async {
    try {
      await Helper.selectAudioOutput(deviceId);
    } catch (e) {
      print('Helper.selectAudioOutput ${e.toString()}');
      return false;
    }
    return true;
  }

  @override
  Future<void> setVolume(double value) async {
    try {
      if (_srcObject == null) {
        throw Exception('Can\'t set volume: The MediaStream is null');
      }
      for (MediaStreamTrack track in _srcObject!.getAudioTracks()) {
        await Helper.setVolume(value, track);
      }
    } catch (e) {
      print('Helper.setVolume ${e.toString()}');
    }
  }
}
