import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import '../enums.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';

class MediaRecorder {
  String filePath;
  html.MediaRecorder _recorder;
  List<html.Blob> _chunks;
  Completer<dynamic> _completer;

  /// For Android use audioChannel param
  /// For iOS use audioTrack
  Future<void> start(
    String path, {
    MediaStreamTrack videoTrack,
    MediaStreamTrack audioTrack,
    RecorderAudioChannel audioChannel,
    int rotation,
  }) {
    throw 'Use startWeb on Flutter Web!';
  }

  /// Only for Flutter Web
  void startWeb(MediaStream stream,
      {Function(dynamic blob, bool isLastOne) onDataChunk,
      String mimeType = 'video/webm'}) {
    _recorder = html.MediaRecorder(stream.jsStream, {'mimeType': mimeType});
    if (onDataChunk == null) {
      _chunks = [];
      _completer = Completer();
      _recorder.addEventListener('dataavailable', (html.Event event) {
        final html.Blob blob = js.JsObject.fromBrowserObject(event)['data'];
        if (blob.size > 0) {
          _chunks.add(blob);
        }
        if (_recorder.state == 'inactive') {
          final blob = html.Blob(_chunks, mimeType);
          _completer?.complete(html.Url.createObjectUrlFromBlob(blob));
          _completer = null;
        }
      });
      _recorder.onError.listen((error) {
        _completer?.completeError(error);
        _completer = null;
      });
    } else {
      _recorder.addEventListener('dataavailable', (html.Event event) {
        final html.Blob blob = js.JsObject.fromBrowserObject(event)['data'];
        onDataChunk(blob, _recorder.state == 'inactive');
      });
    }
    _recorder.start();
  }

  Future<dynamic> stop() {
    _recorder?.stop();
    return _completer?.future ?? Future.value();
  }
}
