import 'dart:html' as html;

import '/src/model/track.dart';
import '/src/platform/audio_renderer.dart';
import '/src/platform/track.dart';
import '/src/platform/web/media_stream_track.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

/// Creates a new [AudioRenderer] for the web platform.
AudioRenderer createPlatformSpecificAudioRenderer() {
  return WebAudioRenderer();
}

class WebAudioRenderer extends AudioRenderer {
  /// Constructs a new [WebAudioRenderer].
  WebAudioRenderer() : _id = _textureCounter++;

  /// HTML element ID for the audio manager's [html.DivElement].
  static const _elementIdForAudioManager = 'html_webrtc_audio_manager_list';

  /// Counter for the [_id].
  static int _textureCounter = 1;

  /// Unique ID of this [WebAudioRenderer].
  final int _id;

  /// [html.AudioElement] playing the [_srcObject].
  html.AudioElement? _element;

  /// ID of the `audio` HTML element of this [WebAudioRenderer].
  String get _elementId => 'audio-renderer-$_id';

  /// Audio [MediaStreamTrack], currently played by this [WebAudioRenderer].
  MediaStreamTrack? _srcObject;

  @override
  Future<void> dispose() async {
    _srcObject = null;
    _element?.srcObject = null;
    final audioManager = html.document.getElementById(_elementIdForAudioManager)
        as html.DivElement?;
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
          "MediaStreamTracks with video kind isn't supported in AudioRenderer");
    }
    srcObject as WebMediaStreamTrack;

    _srcObject = srcObject;

    var stream = html.MediaStream();
    stream.addTrack(srcObject.jsTrack);

    if (_element == null) {
      _element = html.AudioElement()
        ..id = _elementId
        ..autoplay = true;
      _getAudioManagerDiv().append(_element!);
    }
    _element!.srcObject = stream;
  }

  /// Returns the [html.DivElement] for the audio manager.
  ///
  /// If [html.DivElement] doesn't exist, then creates and returns it.
  html.DivElement _getAudioManagerDiv() {
    var div = html.document.getElementById(_elementIdForAudioManager);
    if (div != null) {
      return div as html.DivElement;
    }

    div = html.DivElement()
      ..id = _elementIdForAudioManager
      ..style.display = 'none';
    html.document.body?.append(div);

    return div as html.DivElement;
  }
}
