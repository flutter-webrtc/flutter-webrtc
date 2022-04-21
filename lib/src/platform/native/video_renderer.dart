import 'dart:async';

import 'package:flutter/services.dart';

import '../../api/peer.dart';
import '/src/api/channel.dart';
import '/src/model/track.dart';
import '/src/platform/track.dart';
import '/src/platform/video_renderer.dart';

/// Creates a new [NativeVideoRenderer].
VideoRenderer createPlatformSpecificVideoRenderer() {
  if (isDesktop) {
    return _NativeVideoRendererFFI();
  } else {
    return _NativeVideoRendererChannel();
  }
}

/// [MethodChannel] for factory used for the messaging with the native side.
final _rendererFactoryChannel = methodChannel('VideoRendererFactory', 0);

/// [VideoRenderer] implementation for the native platform.
abstract class NativeVideoRenderer extends VideoRenderer {
  /// Unique ID for the texture on which video will be rendered.
  int? _textureId;

  /// Unique ID of the channel for the native side `VideoRenderer`.
  late int _channelId;

  /// Currently rendering [MediaStreamTrack].
  MediaStreamTrack? _srcObject;

  /// Subscription to the events of this [NativeVideoRenderer].
  StreamSubscription<dynamic>? _eventChan;

  /// [MethodChannel] for the [NativeVideoRenderer] used for the messaging with
  /// the native side.
  late MethodChannel _chan;

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int? get textureId => _textureId;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set mirror(bool mirror) {
    // No-op. Mirroring is done through [RTCViewView].
  }

  /// Listener for the [NativeVideoRenderer] events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic map = event;
    switch (map['event']) {
      case 'onTextureChangeRotation':
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'onTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        onResize?.call();
        break;
      case 'onFirstFrameRendered':
        value = value.copyWith(renderVideo: renderVideo);
        break;
    }
  }

  /// Listener for the errors of the native event channel.
  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  bool get renderVideo => srcObject != null;
}

/// [MethodChannel]-based implementation of a [NativeVideoRenderer].
class _NativeVideoRendererChannel extends NativeVideoRenderer {
  @override
  Future<void> initialize() async {
    final response = await _rendererFactoryChannel.invokeMethod('create');
    _textureId = response['textureId'];
    _channelId = response['channelId'];
    _eventChan = eventChannel('VideoRendererEvent', _channelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    _chan = methodChannel('VideoRenderer', _channelId);
  }

  @override
  Future<void> setSrcObject(MediaStreamTrack? track) async {
    if (textureId == null) {
      throw 'Renderer should be initialize before setting src';
    }
    if (track?.kind() != MediaKind.video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with video kind!';
    }
    _srcObject = track;

    await _chan.invokeMethod('setSrcObject', {
      'trackId': track?.id(),
    });

    value = (track == null)
        ? RTCVideoValue.empty
        : value.copyWith(renderVideo: renderVideo);
  }

  @override
  Future<void> dispose() async {
    await _eventChan?.cancel();
    await _chan.invokeMethod('dispose');
    await super.dispose();
  }
}

/// FFI-based implementation of a [NativeVideoRenderer].
class _NativeVideoRendererFFI extends NativeVideoRenderer {
  @override
  Future<void> initialize() async {
    final response = await _rendererFactoryChannel.invokeMethod('create');
    _textureId = response['textureId'];
    _channelId = response['channelId'];
    _eventChan = eventChannel('VideoRendererEvent', _channelId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    _chan = methodChannel('VideoRendererFactory', 0);
  }

  @override
  Future<void> setSrcObject(MediaStreamTrack? track) async {
    if (textureId == null) {
      throw 'Renderer should be initialize before setting src';
    }
    if (track != null && track.kind() != MediaKind.video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with audio kind!';
    }

    _srcObject = track;
    var sinkId = textureId ?? 0;
    if (track == null) {
      api.disposeVideoSink(sinkId: sinkId);
      value = RTCVideoValue.empty;
    } else {
      var handler =
          await _chan.invokeMethod('createFrameHandler', <String, dynamic>{
        'textureId': textureId,
      });

      var trackId = track.id();
      await api
          .createVideoSink(
              sinkId: sinkId,
              trackId: trackId,
              callbackPtr: handler['handler_ptr'])
          .then((_) => {value = value.copyWith(renderVideo: renderVideo)});
    }
  }

  @override
  Future<void> dispose() async {
    await _eventChan?.cancel();
    await setSrcObject(null);
    await _chan.invokeMethod('dispose', {'textureId': textureId});
    await super.dispose();
  }
}
