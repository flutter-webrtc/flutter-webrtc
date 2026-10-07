import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as web_ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:web/web.dart' as web;

import '../video_renderer_extension.dart' show AudioControl;

const bool useHtmlElementView =
    bool.fromEnvironment("WEBRTC_USE_HTML_ELEMENT_VIEW", defaultValue: false);

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
    implements VideoRenderer, AudioControl {
  RTCVideoRenderer()
      : _textureId = _textureCounter++,
        super(RTCVideoValue.empty);

  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  web.HTMLAudioElement? _audioElement;

  static int _textureCounter = 1;

  final web.MediaStream _videoStream = web.MediaStream();

  final web.MediaStream _audioStream = web.MediaStream();

  MediaStreamWeb? _srcObject;
  String? _selectedVideoTrackId;
  web.EventListener? _sourceTrackListener;
  int _sourceGeneration = 0;

  final int _textureId;

  bool _initialized = false;
  bool _disposed = false;
  bool _mirror = false;

  bool get mirror => _mirror;

  set mirror(bool value) {
    if (_mirror == value) return;
    _mirror = value;
    _syncVideoElement();
  }

  final _subscriptions = <StreamSubscription>[];

  String _objectFit = 'contain';

  bool _muted = false;

  web.HTMLVideoElement? element;

  set objectFit(String fit) {
    if (_objectFit == fit) return;
    _objectFit = fit;
    _syncVideoElement();
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
  set muted(bool mute) {
    _muted = mute;
    _audioElement?.muted = mute;
  }

  @override
  bool get renderVideo => _srcObject != null;

  bool get hasVideoTracks => _videoStream.getVideoTracks().toDart.any(
        (track) => track.readyState != 'ended',
      );

  int get sourceGeneration => _sourceGeneration;

  String get _elementIdForAudio => 'audio_$viewType';

  String get _elementIdForVideo => 'video_$viewType';

  String get viewType => 'RTCVideoRenderer-$textureId';

  void _updateAllValues(web.HTMLVideoElement fallback) {
    final element = findHtmlView() ?? fallback;
    value = value.copyWith(
      rotation: 0,
      width: element.videoWidth.toDouble(),
      height: element.videoHeight.toDouble(),
      renderVideo: renderVideo,
    );
  }

  @override
  MediaStream? get srcObject => _srcObject;

  @override
  set srcObject(MediaStream? stream) {
    _setStreams(stream);
    value = value.copyWith(renderVideo: renderVideo);
  }

  Future<void> setSrcObject({MediaStream? stream, String? trackId}) async {
    _setStreams(stream, trackId: trackId);
    value = value.copyWith(renderVideo: renderVideo);
  }

  void _setStreams(MediaStream? stream, {String? trackId}) {
    _removeSourceTrackListeners();
    _srcObject = stream as MediaStreamWeb?;
    _selectedVideoTrackId = trackId;
    _synchronizeSourceTracks();
    _addSourceTrackListeners();
    _sourceGeneration++;

    _ensureAudioElement();
  }

  void _synchronizeSourceTracks() {
    final videoTracks = _srcObject?.jsStream.getVideoTracks().toDart.where(
              (track) =>
                  _selectedVideoTrackId == null ||
                  track.id == _selectedVideoTrackId,
            ) ??
        const <web.MediaStreamTrack>[];
    final audioTracks =
        _srcObject?.jsStream.getAudioTracks().toDart ?? const [];
    _synchronizeTracks(_videoStream, videoTracks);
    _synchronizeTracks(_audioStream, audioTracks);
  }

  void _addSourceTrackListeners() {
    final stream = _srcObject?.jsStream;
    if (stream == null) return;
    final listener = ((web.Event _) {
      _synchronizeSourceTracks();
      _ensureAudioElement();
      _sourceGeneration++;
      notifyListeners();
    }).toJS;
    _sourceTrackListener = listener;
    stream
      ..addEventListener('addtrack', listener)
      ..addEventListener('removetrack', listener);
  }

  void _ensureAudioElement() {
    final audioTracks = _audioStream.getAudioTracks().toDart;
    if (_audioElement == null && audioTracks.isEmpty) return;
    _audioElement ??= web.HTMLAudioElement()
      ..id = _elementIdForAudio
      ..autoplay = true;
    _audioElement!.muted = _muted || _srcObject?.ownerTag == 'local';
    if (_audioElement!.parentNode == null) {
      _ensureAudioManagerDiv().append(_audioElement!);
    }
    if (_audioElement!.srcObject != _audioStream) {
      _audioElement!.srcObject = _audioStream;
    }
  }

  void _removeSourceTrackListeners() {
    final stream = _srcObject?.jsStream;
    final listener = _sourceTrackListener;
    if (stream != null && listener != null) {
      stream
        ..removeEventListener('addtrack', listener)
        ..removeEventListener('removetrack', listener);
    }
    _sourceTrackListener = null;
  }

  void _synchronizeTracks(
    web.MediaStream target,
    Iterable<web.MediaStreamTrack> desiredTracks,
  ) {
    final desiredById = <String, web.MediaStreamTrack>{
      for (final track in desiredTracks) track.id: track,
    };
    final currentTracks = target.getTracks().toDart;

    for (final currentTrack in currentTracks) {
      final desiredTrack = desiredById[currentTrack.id];
      if (desiredTrack == null || desiredTrack != currentTrack) {
        target.removeTrack(currentTrack);
      }
    }
    for (final desiredTrack in desiredById.values) {
      final currentTrack = target.getTrackById(desiredTrack.id);
      if (currentTrack == null || currentTrack != desiredTrack) {
        target.addTrack(desiredTrack);
      }
    }
  }

  web.HTMLDivElement _ensureAudioManagerDiv() {
    var div = web.document.getElementById(_elementIdForAudioManager);
    if (null != div) return div as web.HTMLDivElement;

    div = web.HTMLDivElement()
      ..id = _elementIdForAudioManager
      ..style.display = 'none';
    web.document.body?.append(div);
    return div as web.HTMLDivElement;
  }

  web.HTMLVideoElement? findHtmlView() {
    final htmlElement = element;
    if (htmlElement != null) return htmlElement;
    final domElement = web.document.getElementById(_elementIdForVideo);
    return domElement as web.HTMLVideoElement?;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    findHtmlView()?.srcObject = null;
    _audioElement?.srcObject = null;
    _removeSourceTrackListeners();
    _srcObject = null;
    await Future.wait(
        _subscriptions.map((subscription) => subscription.cancel()));
    _subscriptions.clear();
    _audioElement?.remove();
    _audioElement = null;
    final audioManager = web.document.getElementById(_elementIdForAudioManager)
        as web.HTMLDivElement?;
    if (audioManager != null && !audioManager.hasChildNodes()) {
      audioManager.remove();
    }
    if (!useHtmlElementView) {
      element?.remove();
    }
    element = null;
    super.dispose();
  }

  @override
  Future<bool> audioOutput(String deviceId) async {
    try {
      final element = _audioElement;
      if (null != element &&
          element.getProperty('setSinkId'.toJS).isDefinedAndNotNull) {
        await (element.callMethod('setSinkId'.toJS, deviceId.toJS) as JSPromise)
            .toDart;

        return true;
      }
    } catch (e) {
      print('Unable to setSinkId: ${e.toString()}');
    }
    return false;
  }

  web.HTMLVideoElement createElement() {
    if (element != null) return element!;

    final createdElement = web.HTMLVideoElement()
      ..autoplay = true
      ..muted = true
      ..controls = false
      ..srcObject = _videoStream
      ..id = _elementIdForVideo
      ..setAttribute('playsinline', 'true');
    element = createdElement;

    _applyDefaultVideoStyles(createdElement);

    _subscriptions.add(
      createdElement.onCanPlay.listen((dynamic _) {
        _updateAllValues(createdElement);
      }),
    );

    _subscriptions.add(
      createdElement.onResize.listen((dynamic _) {
        _updateAllValues(createdElement);
        onResize?.call();
      }),
    );

    // The error event fires when some form of error occurs while attempting to load or perform the media.
    _subscriptions.add(
      createdElement.onError.listen((web.Event _) {
        final error = createdElement.error;
        print('RTCVideoRenderer: videoElement.onError, ${error.toString()}');
        throw PlatformException(
          code: _kErrorValueToErrorName[error!.code]!,
          message: error.message != '' ? error.message : _kDefaultErrorMessage,
          details: _kErrorValueToErrorDescription[error.code],
        );
      }),
    );

    _subscriptions.add(
      createdElement.onEnded.listen((dynamic _) {
        notifyListeners();
      }),
    );

    return createdElement;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (useHtmlElementView) {
      web_ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        return createElement();
      }, isVisible: true);
    } else {
      web.window.document.body!.appendChild(createElement());
    }
  }

  void _syncVideoElement() {
    final htmlElement = element;
    if (htmlElement == null) return;
    _applyDefaultVideoStyles(htmlElement);
  }

  void _applyDefaultVideoStyles(web.HTMLVideoElement element) {
    element.style.transform = mirror ? 'scaleX(-1)' : '';
    if (useHtmlElementView) {
      element
        ..style.objectFit = _objectFit
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    } else {
      element.style.pointerEvents = 'none';
      element.style.opacity = '0';
      element.style.position = 'absolute';
      element.style.left = '0px';
      element.style.top = '0px';
    }
  }

  @override
  Function? onResize;

  @override
  Function? onFirstFrameRendered;

  @override
  Future<void> setVolume(double volume) async {
    _audioElement?.volume = volume.clamp(0.0, 1.0);
  }
}
