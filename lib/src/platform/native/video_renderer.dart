import 'dart:async';

import 'package:flutter/services.dart';

import '../../api/bridge.g.dart' as ffi;
import '../../api/peer.dart';
import '/src/api/channel.dart';
import '/src/model/track.dart';
import '/src/platform/native/media_stream_track.dart';
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

  /// Currently rendering [MediaStreamTrack].
  MediaStreamTrack? _srcObject;

  /// [MethodChannel] for the [NativeVideoRenderer] used for the messaging with
  /// the native side.
  late MethodChannel _chan;

  @override
  int get videoWidth;

  @override
  int get videoHeight;

  @override
  int? get textureId => _textureId;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set mirror(bool mirror) {
    // No-op. Mirroring is done through [VideoView].
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
  /// Unique ID of the channel for this [NativeVideoRenderer].
  late int _channelId;

  /// Indicates whether [NativeVideoRenderer.onCanPlay] callback was called.
  bool _canPlayCalled = false;

  /// Subscription to the events of this [NativeVideoRenderer].
  StreamSubscription<dynamic>? _eventChan;

  @override
  int get videoWidth {
    return value.rotation % 180 == 0
        ? value.width.toInt()
        : value.height.toInt();
  }

  @override
  int get videoHeight {
    return value.rotation % 180 == 0
        ? value.height.toInt()
        : value.width.toInt();
  }

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
    if (track != null && track.kind() != MediaKind.video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with audio kind!';
    }
    _srcObject = track;

    await _chan.invokeMethod('setSrcObject', {
      'trackId': track?.id(),
    });

    if (track != null) {
      _canPlayCalled = false;
    }

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

  /// Listener for this [NativeVideoRenderer]'s events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic map = event;
    switch (map['event']) {
      case 'onTextureChange':
        var rotation = map['rotation'];
        var width = 0.0 + map['width'];
        var height = 0.0 + map['height'];

        var newWidth = rotation % 180 == 0 ? width : height;
        var newHeight = rotation % 180 == 0 ? height : width;

        width = newWidth;
        height = newHeight;

        value = value.copyWith(
          rotation: rotation,
          width: width,
          height: height,
          renderVideo: renderVideo,
        );

        if (width != 0 && height != 0 && !_canPlayCalled) {
          _canPlayCalled = true;
          onCanPlay?.call();
        }
        onResize?.call();
        break;
      case 'onFirstFrameRendered':
        value = value.copyWith(renderVideo: renderVideo);
        break;
    }
  }
}

/// FFI-based implementation of a [NativeVideoRenderer].
class _NativeVideoRendererFFI extends NativeVideoRenderer {
  /// Subscription to the events of this [NativeVideoRenderer].
  Stream<ffi.TextureEvent>? _eventStream;

  @override
  int get videoWidth {
    return value.width.toInt();
  }

  @override
  int get videoHeight {
    return value.height.toInt();
  }

  @override
  Future<void> initialize() async {
    final response = await _rendererFactoryChannel.invokeMethod('create');
    _textureId = response['textureId'];
    _chan = methodChannel('VideoRendererFactory', 0);
  }

  @override
  Future<void> setSrcObject(MediaStreamTrack? track) async {
    track as NativeMediaStreamTrack?;

    if (textureId == null) {
      throw 'Renderer should be initialize before setting src';
    }
    if (track != null && track.kind() != MediaKind.video) {
      throw 'VideoRenderer do not supports MediaStreamTrack with audio kind!';
    }

    _srcObject = track;
    if (track == null) {
      api!.disposeVideoSink(sinkId: textureId!);
      value = RTCVideoValue.empty;
    } else {
      var handler =
          await _chan.invokeMethod('createFrameHandler', <String, dynamic>{
        'textureId': textureId,
      });

      var trackId = track.id();
      _eventStream = api!.createVideoSink(
        sinkId: textureId!,
        peerId: track.peerId,
        trackId: trackId,
        callbackPtr: handler['handler_ptr'],
        textureId: textureId!,
      );

      _eventStream!.listen(eventListener);
      value = value.copyWith(renderVideo: renderVideo);
    }
  }

  @override
  Future<void> dispose() async {
    await setSrcObject(null);
    await _chan.invokeMethod('dispose', {'textureId': textureId});
    await super.dispose();
  }

  /// Listener for this [NativeVideoRenderer]'s events received from the native
  /// side.
  void eventListener(ffi.TextureEvent event) {
    if (event is ffi.TextureEvent_OnTextureChange) {
      var rotation = event.rotation;
      var width = 0.0 + event.width;
      var height = 0.0 + event.height;

      var newWidth = rotation % 180 == 0 ? width : height;
      var newHeight = rotation % 180 == 0 ? height : width;

      width = newWidth;
      height = newHeight;

      value = value.copyWith(
        rotation: rotation,
        width: width,
        height: height,
        renderVideo: renderVideo,
      );

      if (width != 0 && height != 0) {
        onCanPlay?.call();
      }
      onResize?.call();
    } else if (event is ffi.TextureEvent_OnFirstFrameRendered) {
      value = value.copyWith(renderVideo: renderVideo);
    }
  }
}
