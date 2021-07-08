import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as jsutil;

import 'package:flutter/services.dart';

import '../interface/media_stream.dart';
import '../interface/rtc_video_renderer.dart';
import 'media_stream_impl.dart';
import 'ui_fake.dart' if (dart.library.html) 'dart:ui' as ui;

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

class RTCVideoRendererWeb extends VideoRenderer {
  RTCVideoRendererWeb() : _textureId = _textureCounter++;

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

  set objectFit(String fit) =>
      findHtmlView()?.style.objectFit = _objectFit = fit;

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

  void _updateAllValues() {
    var element = findHtmlView();
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
      _audioElement?.srcObject = _audioStream;
      return;
    }

    _srcObject = stream as MediaStreamWeb;

    if (null != _srcObject) {
      if (stream.getVideoTracks().isNotEmpty) {
        _videoStream = html.MediaStream();
        for (var track in _srcObject!.jsStream.getVideoTracks()) {
          _videoStream!.addTrack(track);
        }
      }
      if (stream.getAudioTracks().isNotEmpty) {
        _audioStream = html.MediaStream();
        for (var track in _srcObject!.jsStream.getAudioTracks()) {
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
          ..id = 'audio_RTCVideoRenderer-$textureId'
          ..muted = stream.ownerTag == 'local'
          ..autoplay = true;
        getAudioManageDiv().append(_audioElement!);
      }
      _audioElement?.srcObject = _audioStream;
    }

    findHtmlView()?.srcObject = _videoStream;

    value = value.copyWith(renderVideo: renderVideo);
  }

  html.DivElement getAudioManageDiv() {
    var div = html.document.getElementById('html_webrtc_audio_manage_list');
    if (null != div) {
      return div as html.DivElement;
    }
    div = html.DivElement();
    div.id = 'html_webrtc_audio_manage_list';
    div.style.display = 'none';
    html.document.body!.append(div);
    return div as html.DivElement;
  }

  html.VideoElement? findHtmlView() {
    var video =
        html.document.getElementById('video_RTCVideoRenderer-$textureId');
    if (null != video) {
      return video as html.VideoElement;
    }
    final fltPv = html.document.getElementsByTagName('flt-platform-view');
    if (fltPv.isEmpty) return null;
    var child = (fltPv.first as html.Element).shadowRoot!.childNodes;
    for (var item in child) {
      if ((item as html.Element).id == 'video_RTCVideoRenderer-$textureId') {
        return item as html.VideoElement;
      }
    }
    return null;
  }

  @override
  Future<void> dispose() async {
    await _srcObject?.dispose();
    _srcObject = null;
    _subscriptions.forEach((s) => s.cancel());
    var element = findHtmlView();
    element?.removeAttribute('src');
    element?.load();
    getAudioManageDiv().remove();
    return super.dispose();
  }

  @override
  Future<bool> audioOutput(String deviceId) async {
    try {
      var element = findHtmlView();
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
    var id = 'RTCVideoRenderer-$textureId';
    // // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(id, (int viewId) {
      _subscriptions.forEach((s) => s.cancel());
      _subscriptions.clear();

      var element = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..controls = false
        ..style.objectFit = _objectFit
        ..style.border = 'none'
        ..srcObject = _videoStream
        ..id = 'video_$id'
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
          var error = element.error;
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
}
