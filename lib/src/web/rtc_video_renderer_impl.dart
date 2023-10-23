import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as jsutil;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dart_webrtc/dart_webrtc.dart';

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

class RTCVideoRenderer extends ValueNotifier<RTCVideoValue>
    implements VideoRenderer {
  RTCVideoRenderer()
      : _textureId = _textureCounter++,
        super(RTCVideoValue.empty);

  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  html.AudioElement? _audioElement;

  static int _textureCounter = 1;

  html.MediaStream? _videoStream;

  html.MediaStream? _audioStream;

  MediaStreamWeb? _srcObject;

  int _textureId;

  bool mirror = false;

  final _subscriptions = <StreamSubscription>[];

  String _objectFit = 'contain';

  bool _muted = false;

  set objectFit(String fit) {
    if (_objectFit == fit) return;
    _objectFit = fit;
    _videoElement?.style.objectFit = fit;
  }

  @override
  int get videoWidth => value.width.toInt();

  @override
  int get videoHeight => value.height.toInt();

  @override
  int get textureId => _textureId;

  @override
  bool get muted => _muted;

  @override
  set muted(bool mute) => _audioElement?.muted = _muted = mute;

  @override
  bool get renderVideo => _srcObject != null;

  String get _elementIdForAudio => 'audio_$viewType';

  String get _elementIdForVideo => 'video_$viewType';

  String get viewType => 'RTCVideoRenderer-$textureId';

  html.VideoElement? _videoElement;

  void _updateAllValues() {
    value = value.copyWith(
      rotation: 0,
      width: _videoElement?.videoWidth.toDouble() ?? 0.0,
      height: _videoElement?.videoHeight.toDouble() ?? 0.0,
      renderVideo: renderVideo,
    );
  }

  @override
  MediaStream? get srcObject => _srcObject;

  @override
  set srcObject(MediaStream? stream) {
    if (stream == null) {
      _videoElement?.srcObject = null;
      _audioElement?.srcObject = null;
      _srcObject = null;
      return;
    }

    _srcObject = stream as MediaStreamWeb;

    if (null != _srcObject) {
      if (stream.getVideoTracks().isNotEmpty) {
        _videoStream = html.MediaStream();
        for (final track in _srcObject!.jsStream.getVideoTracks()) {
          _videoStream!.addTrack(track);
        }
      }
      if (stream.getAudioTracks().isNotEmpty) {
        _audioStream = html.MediaStream();
        for (final track in _srcObject!.jsStream.getAudioTracks()) {
          _audioStream!.addTrack(track);
        }
      }
    } else {
      _videoStream = null;
      _audioStream = null;
    }

    if (null != _audioStream) {
      if (null == _audioElement) {
        _audioElement = html.AudioElement()
          ..id = _elementIdForAudio
          ..muted = stream.ownerTag == 'local'
          ..autoplay = true;
        _ensureAudioManagerDiv().append(_audioElement!);
      }
      _audioElement?.srcObject = _audioStream;
    }

    if (null != _videoElement) {
      _videoElement?.srcObject = _videoStream;
      _applyDefaultVideoStyles(_videoElement);
    }

    value = value.copyWith(renderVideo: renderVideo);
  }

  void setSrcObject({MediaStream? stream, String? trackId}) {
    if (stream == null) {
      _videoElement?.srcObject = null;
      _audioElement?.srcObject = null;
      _srcObject = null;
      return;
    }

    _srcObject = stream as MediaStreamWeb;

    if (null != _srcObject) {
      if (stream.getVideoTracks().isNotEmpty) {
        _videoStream = html.MediaStream();
        for (final track in _srcObject!.jsStream.getVideoTracks()) {
          if (track.id == trackId) {
            _videoStream!.addTrack(track);
          }
        }
      }
      if (stream.getAudioTracks().isNotEmpty) {
        _audioStream = html.MediaStream();
        for (final track in _srcObject!.jsStream.getAudioTracks()) {
          _audioStream!.addTrack(track);
        }
      }
    } else {
      _videoStream = null;
      _audioStream = null;
    }

    if (null != _audioStream) {
      if (null == _audioElement) {
        _audioElement = html.AudioElement()
          ..id = _elementIdForAudio
          ..muted = stream.ownerTag == 'local'
          ..autoplay = true;
        _ensureAudioManagerDiv().append(_audioElement!);
      }
      _audioElement?.srcObject = _audioStream;
    }

    if (null != _videoElement) {
      _videoElement?.srcObject = _videoStream;
      _applyDefaultVideoStyles(_videoElement);
    }

    value = value.copyWith(renderVideo: renderVideo);
  }

  html.DivElement _ensureAudioManagerDiv() {
    var div = html.document.getElementById(_elementIdForAudioManager);
    if (null != div) return div as html.DivElement;

    div = html.DivElement()
      ..id = _elementIdForAudioManager
      ..style.display = 'none';
    html.document.body?.append(div);
    return div as html.DivElement;
  }

  @override
  Future<void> dispose() async {
    _srcObject = null;
    for (var s in _subscriptions) {
      s.cancel();
    }
    _videoElement?.remove();
    _audioElement?.remove();
    final audioManager = html.document.getElementById(_elementIdForAudioManager)
        as html.DivElement?;
    if (audioManager != null && !audioManager.hasChildNodes()) {
      audioManager.remove();
    }
    return super.dispose();
  }

  @override
  Future<bool> audioOutput(String deviceId) async {
    try {
      final element = _audioElement;
      if (null != element && jsutil.hasProperty(element, 'setSinkId')) {
        await jsutil.promiseToFuture<void>(
            jsutil.callMethod(element, 'setSinkId', [deviceId]));

        return true;
      }
    } catch (e) {
      print('Unable to setSinkId: ${e.toString()}');
    }
    return false;
  }

  @override
  Future<void> initialize() async {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    _videoElement?.remove();

    final element = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..controls = false
      ..srcObject = _videoStream
      ..id = _elementIdForVideo
      ..setAttribute('playsinline', 'true');

    _applyDefaultVideoStyles(element);

    _videoElement = element;

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
        print('RTCVideoRenderer: videoElement.onError, ${error.toString()}');
        throw PlatformException(
          code: _kErrorValueToErrorName[error!.code]!,
          message: error.message != '' ? error.message : _kDefaultErrorMessage,
          details: _kErrorValueToErrorDescription[error.code],
        );
      }),
    );

    ui_web.platformViewRegistry
        .registerViewFactory(viewType, (int viewId) => _videoElement!);
  }

  void _applyDefaultVideoStyles(html.VideoElement? element) {
    if (element == null) return;

    // Flip the video horizontally if is mirrored.
    if (mirror) {
      element.style.transform = 'scaleX(-1)';
    }

    element
      ..style.objectFit = _objectFit
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
  }

  @override
  Function? onResize;

  @override
  Function? onFirstFrameRendered;
}
