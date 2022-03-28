import 'package:webrtc_interface/src/media_recorder.dart' as _interface;

import '../flutter_webrtc.dart';

class MediaRecorder extends _interface.MediaRecorder {
  MediaRecorder() : _delegate = mediaRecorder();
  final _interface.MediaRecorder _delegate;

  @override
  Future<void> start(String path,
          {MediaStreamTrack? videoTrack, RecorderAudioChannel? audioChannel}) =>
      _delegate.start(path, videoTrack: videoTrack, audioChannel: audioChannel);

  @override
  Future stop() => _delegate.stop();

  @override
  void startWeb(
    MediaStream stream, {
    Function(dynamic blob, bool isLastOne)? onDataChunk,
    String? mimeType,
  }) =>
      _delegate.startWeb(stream,
          onDataChunk: onDataChunk, mimeType: mimeType ?? 'video/webm');
}
