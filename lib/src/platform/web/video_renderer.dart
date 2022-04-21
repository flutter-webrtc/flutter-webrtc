import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../track.dart';
import '../video_renderer.dart';
import 'media_stream_track.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

/// All active [WebVideoRenderer]s created by the library user.
Map<int, WebVideoRenderer> _videoRenderers = {};

/// Current global output audio sink ID.
String? _outputAudioSinkId;

/// Switches the current audio output sink of all [WebVideoRenderer]s to the
/// provided [deviceId].
void setOutputAudioSinkId(String deviceId) {
  _outputAudioSinkId = deviceId;
  for (var r in _videoRenderers.values) {
    r._syncSinkId();
  }
}

VideoRenderer createPlatformSpecificVideoRenderer() {
  return WebVideoRenderer();
}

// An error code value to error name Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorName = {
  1: 'MEDIA_ERR_ABORTED',
  2: 'MEDIA_ERR_NETWORK',
  3: 'MEDIA_ERR_DECODE',
  4: 'MEDIA_ERR_SRC_NOT_SUPPORTED',
};

// An error code value to description Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorDescription = {
  1: 'The user canceled the fetching of the video.',
  2: 'A network error occurred while fetching the video, despite having previously been available.',
  3: 'An error occurred while trying to decode the video, despite having previously been determined to be usable.',
  4: 'The video has been found to be unsuitable (missing or in a format not supported by your browser).',
};

// The default error message, when the error is an empty string
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const String _kDefaultErrorMessage =
    'No further diagnostic information can be determined or provided.';

class WebVideoRenderer extends VideoRenderer {
  WebVideoRenderer() : _textureId = _textureCounter++;

  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  html.AudioElement? _audioElement;

  static int _textureCounter = 1;

  html.MediaStream? _videoStream;

  WebMediaStreamTrack? _srcObject;

  final int _textureId;

  bool _mirror = false;

  @override
  set mirror(bool value) {
    if (_mirror == value) return;
    _mirror = value;
    findHtmlView()?.style.transform = value ? 'rotateY(0.5turn)' : '';
  }

  bool _enableContextMenu = true;

  set enableContextMenu(bool value) {
    if (_enableContextMenu == value) return;
    _enableContextMenu = value;
    findHtmlView()?.setAttribute('oncontextmenu', value ? '' : 'return false;');
  }

  final _subscriptions = <StreamSubscription>[];

  String _objectFit = 'contain';

  set objectFit(String fit) {
    if (_objectFit == fit) return;
    _objectFit = fit;
    findHtmlView()?.style.objectFit = fit;
  }

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int get textureId => _textureId;

  @override
  bool get renderVideo => _srcObject != null;

  String get _elementIdForVideo => 'video_RTCVideoRenderer-$textureId';

  void _updateAllValues() {
    final element = findHtmlView();
    value = value.copyWith(
      rotation: 0,
      width: element?.videoWidth.toDouble() ?? 0.0,
      height: element?.videoHeight.toDouble() ?? 0.0,
      renderVideo: renderVideo,
    );
  }

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  Future<void> setSrcObject(MediaStreamTrack? track) async {
    if (track == null) {
      findHtmlView()?.srcObject = null;
      _audioElement?.srcObject = null;
      _srcObject = null;
      return;
    }

    _srcObject = track as WebMediaStreamTrack;

    if (null != _srcObject) {
      _videoStream = html.MediaStream();
      _videoStream!.addTrack(track.jsTrack);
    } else {
      _videoStream = null;
    }

    findHtmlView()?.srcObject = _videoStream;

    value = value.copyWith(renderVideo: renderVideo);
  }

  /// Synchronizes this [WebVideoRenderer]'s output audio sink with the
  /// [_outputAudioSinkId].
  void _syncSinkId() {
    if (_outputAudioSinkId != null) {
      _audioElement?.setSinkId(_outputAudioSinkId!);
    }
  }

  html.VideoElement? findHtmlView() {
    final element = html.document.getElementById(_elementIdForVideo);
    if (null != element) {
      return element as html.VideoElement;
    } else {
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    await _srcObject?.dispose();
    _srcObject = null;
    for (var s in _subscriptions) {
      s.cancel();
    }
    final element = findHtmlView();
    element?.removeAttribute('src');
    element?.load();
    _audioElement?.remove();
    final audioManager = html.document.getElementById(_elementIdForAudioManager)
        as html.DivElement?;
    if (audioManager != null && !audioManager.hasChildNodes()) {
      audioManager.remove();
    }
    _videoRenderers.remove(_textureId);
    return super.dispose();
  }

  @override
  Future<void> initialize() async {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('RTCVideoRenderer-$textureId',
        (int viewId) {
      for (var s in _subscriptions) {
        s.cancel();
      }
      _subscriptions.clear();

      final element = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..controls = false
        ..style.objectFit = _objectFit
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.transform = _mirror ? 'rotateY(0.5turn)' : ''
        ..srcObject = _videoStream
        ..id = _elementIdForVideo
        ..setAttribute('playsinline', 'true')
        ..setAttribute(
            'oncontextmenu', _enableContextMenu ? '' : 'return false;');

      _subscriptions.add(
        element.onCanPlay.listen((dynamic _) {
          _updateAllValues();
        }),
      );

      _subscriptions.add(
        element.onResize.listen((dynamic _) {
          _updateAllValues();
          onResize?.call();
        }),
      );

      // The error event fires when some form of error occurs while attempting to load or perform the media.
      _subscriptions.add(
        element.onError.listen((html.Event _) {
          // The Event itself (_) doesn't contain info about the actual error.
          // We need to look at the HTMLMediaElement.error.
          // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
          final error = element.error;
          throw PlatformException(
            code: _kErrorValueToErrorName[error!.code]!,
            message:
                error.message != '' ? error.message : _kDefaultErrorMessage,
            details: _kErrorValueToErrorDescription[error.code],
          );
        }),
      );

      _videoRenderers[_textureId] = this;
      _syncSinkId();

      return element;
    });
  }
}
