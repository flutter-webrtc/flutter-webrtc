import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import '../interface/enums.dart';
import '../interface/media_recorder.dart';
import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import 'media_stream_impl.dart';

class MediaRecorderWeb extends MediaRecorder {
  late html.MediaRecorder _recorder;
  late Completer<String> _completer;

  @override
  Future<void> start(
    String path, {
    MediaStreamTrack? videoTrack,
    MediaStreamTrack? audioTrack,
    RecorderAudioChannel? audioChannel,
    int? rotation,
  }) {
    throw 'Use startWeb on Flutter Web!';
  }

  @override
  void startWeb(
    MediaStream stream, {
    Function(dynamic blob, bool isLastOne)? onDataChunk,
    String mimeType = 'video/webm',
  }) {
    var _native = stream as MediaStreamWeb;
    _recorder = html.MediaRecorder(_native.jsStream, {'mimeType': mimeType});
    if (onDataChunk == null) {
      var _chunks = <html.Blob>[];
      _completer = Completer<String>();
      _recorder.addEventListener('dataavailable', (html.Event event) {
        final html.Blob blob = js.JsObject.fromBrowserObject(event)['data'];
        if (blob.size > 0) {
          _chunks.add(blob);
        }
        if (_recorder.state == 'inactive') {
          final blob = html.Blob(_chunks, mimeType);
          _completer.complete(html.Url.createObjectUrlFromBlob(blob));
        }
      });
      _recorder.onError.listen((error) {
        _completer.completeError(error);
      });
    } else {
      _recorder.addEventListener('dataavailable', (html.Event event) {
        onDataChunk(
          js.JsObject.fromBrowserObject(event)['data'],
          _recorder.state == 'inactive',
        );
      });
    }
    _recorder.start();
  }

  @override
  Future<dynamic> stop() {
    _recorder.stop();
    return _completer.future;
  }
}
