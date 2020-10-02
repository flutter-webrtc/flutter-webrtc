import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/interface/media_stream_track.dart';

import 'package:flutter_webrtc/src/interface/media_stream.dart';

import 'package:flutter_webrtc/src/interface/enums.dart';

import 'interface/media_recorder.dart';

class MediaRecorder extends IMediaRecorder {
  MediaRecorder() : _delegate = mediaRecorder();
  final IMediaRecorder _delegate;

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
