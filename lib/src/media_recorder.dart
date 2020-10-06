import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/interface/media_stream_track.dart';

import 'package:flutter_webrtc/src/interface/media_stream.dart';

import 'package:flutter_webrtc/src/interface/enums.dart';

import 'interface/media_recorder.dart' as _interface;

class MediaRecorder extends _interface.MediaRecorder {
  MediaRecorder() : _delegate = mediaRecorder();
  final MediaRecorder _delegate;

  @override
  Future<void> start(String path,
          {MediaStreamTrack videoTrack, RecorderAudioChannel audioChannel}) =>
      _delegate.start(path, videoTrack: videoTrack, audioChannel: audioChannel);

  @override
  Future stop() => _delegate.stop();

  @override
  void startWeb(
    MediaStream stream, {
    Function(dynamic blob, bool isLastOne) onDataChunk,
    String mimeType,
  }) =>
      _delegate.startWeb(stream, onDataChunk: onDataChunk, mimeType: mimeType);
}
