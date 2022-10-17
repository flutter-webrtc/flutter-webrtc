import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as jsutil;
import 'dart:ui' as ui;

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

  final int _textureId;

  bool mirror = false;

  final _subscriptions = <StreamSubscription>[];

  String _objectFit = 'contain';

  bool _muted = false;

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
  bool get muted => _muted;

  @override
  set muted(bool mute) => _audioElement?.muted = _muted = mute;

  @override
  bool get renderVideo => _srcObject != null;

  String get _elementIdForAudio => 'audio_RTCVideoRenderer-$textureId';
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
  MediaStream? get srcObject => _srcObject;

  @override
  set srcObject(MediaStream? stream) {
    if (stream == null) {
      findHtmlView()?.srcObject = null;
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

    findHtmlView()?.srcObject = _videoStream;

    value = value.copyWith(renderVideo: renderVideo);
  }

  void setSrcObject({MediaStream? stream, String? trackId}) {
    if (stream == null) {
      findHtmlView()?.srcObject = null;
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

    findHtmlView()?.srcObject = _videoStream;

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

  html.VideoElement? findHtmlView() {
    final element = html.document.getElementById(_elementIdForVideo);
    if (null != element) return element as html.VideoElement;
    return null;
  }

  @override
  Future<void> dispose() async {
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
        ..srcObject = _videoStream
        ..id = _elementIdForVideo
        ..setAttribute('playsinline', 'true');

      _subscriptions.add(
        element.onCanPlay.listen((dynamic _) {
          _updateAllValues();
          // print('RTCVideoRenderer: videoElement.onCanPlay ${value.toString()}');
        }),
      );

      _subscriptions.add(
        element.onResize.listen((dynamic _) {
          _updateAllValues();
          onResize?.call();
          // print('RTCVideoRenderer: videoElement.onResize ${value.toString()}');
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
            message:
                error.message != '' ? error.message : _kDefaultErrorMessage,
            details: _kErrorValueToErrorDescription[error.code],
          );
        }),
      );

      _subscriptions.add(
        element.onEnded.listen((dynamic _) {
          // print('RTCVideoRenderer: videoElement.onEnded');
        }),
      );

      return element;
    });
  }

  @override
  Function? onResize;

  @override
  Function? onFirstFrameRendered;
}
