import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '/src/model/track.dart';
import '/src/platform/audio_renderer.dart';
import '/src/platform/track.dart';
import '/src/platform/web/media_stream_track.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

/// Current global output audio sink ID.
String? _outputAudioSinkId;

/// Switches the current audio output sink of all [WebAudioRenderer]s to the
/// provided [deviceId].
void setOutputAudioSinkId(String deviceId) {
  _outputAudioSinkId = deviceId;

  final audioManager =
      web.document.getElementById(WebAudioRenderer._elementIdForAudioManager)
          as web.HTMLDivElement?;

  if (audioManager != null) {
    final children = audioManager.children;
    for (int i = 0; i < children.length; ++i) {
      final child = children.item(i);
      if (child != null && child.isA<web.HTMLAudioElement>()) {
        // TODO: Replace once dart-lang/web#205 is fixed:
        //       https://github.com/dart-lang/web/issues/205
        child.callMethod('setSinkId'.toJS, deviceId.toJS);
      }
    }
  }
}

/// Creates a new [AudioRenderer] for the web platform.
AudioRenderer createPlatformSpecificAudioRenderer() {
  return WebAudioRenderer();
}

class WebAudioRenderer extends AudioRenderer {
  /// Constructs a new [WebAudioRenderer].
  WebAudioRenderer() : _id = _textureCounter++;

  /// HTML element ID for the audio manager's [web.HTMLDivElement].
  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  /// Counter for the [_id].
  static int _textureCounter = 1;

  /// Unique ID of this [WebAudioRenderer].
  final int _id;

  /// [web.HTMLAudioElement] playing the [_srcObject].
  web.HTMLAudioElement? _element;

  /// ID of the `audio` HTML element of this [WebAudioRenderer].
  String get _elementId => 'audio-renderer-$_id';

  /// Audio [MediaStreamTrack], currently played by this [WebAudioRenderer].
  MediaStreamTrack? _srcObject;

  @override
  Future<void> dispose() async {
    _srcObject = null;
    _element?.srcObject = null;
    _element?.remove();
    _element = null;
    final audioManager =
        web.document.getElementById(_elementIdForAudioManager)
            as web.HTMLDivElement?;
    if (audioManager != null && !audioManager.hasChildNodes()) {
      audioManager.remove();
    }
  }

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set srcObject(MediaStreamTrack? srcObject) {
    if (srcObject == null) {
      _element?.srcObject = null;
      _srcObject = null;
      return;
    }

    if (srcObject.kind() != MediaKind.audio) {
      throw Exception(
        'MediaStreamTracks with video kind isn\'t supported in AudioRenderer',
      );
    }
    srcObject as WebMediaStreamTrack;

    _srcObject = srcObject;

    var stream = web.MediaStream();
    stream.addTrack(srcObject.jsTrack);

    if (_element == null) {
      _element = web.HTMLAudioElement()
        ..id = _elementId
        ..autoplay = true;
      _getAudioManagerDiv().append(_element!);

      try {
        if (_outputAudioSinkId != null) {
          // TODO: Replace once dart-lang/web#205 is fixed:
          //       https://github.com/dart-lang/web/issues/205
          _element?.callMethod('setSinkId'.toJS, _outputAudioSinkId!.toJS);
        }
      } catch (_) {
        // No-op, as `setSinkId` might not be available in the browser.
      }
    }
    _element!.srcObject = stream;
  }

  /// Returns the [web.HTMLDivElement] for the audio manager.
  ///
  /// If [web.HTMLDivElement] doesn't exist, then creates and returns it.
  web.HTMLDivElement _getAudioManagerDiv() {
    var div = web.document.getElementById(_elementIdForAudioManager);
    if (div != null) {
      return div as web.HTMLDivElement;
    }

    div = web.HTMLDivElement()
      ..id = _elementIdForAudioManager
      ..style.display = 'none';
    web.document.body?.append(div);

    return div as web.HTMLDivElement;
  }
}
