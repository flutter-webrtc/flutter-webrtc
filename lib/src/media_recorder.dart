import 'package:flutter/foundation.dart';

import 'package:webrtc_interface/webrtc_interface.dart' as rtc;

import '../flutter_webrtc.dart';
import 'native/media_recorder_impl.dart' show MediaRecorderNative;

class MediaRecorder extends rtc.MediaRecorder {
  MediaRecorder({
    String? albumName,
  }) : _delegate = (kIsWeb || kIsWasm)
            ? mediaRecorder()
            : MediaRecorderNative(albumName: albumName);

  final rtc.MediaRecorder _delegate;

  @override
  Future<void> start(
    String path, {
    MediaStreamTrack? videoTrack,
    RecorderAudioChannel? audioChannel,
    int rotationDegrees = 0,
  }) {
    return _delegate.start(
      path,
      videoTrack: videoTrack,
      audioChannel: audioChannel,
    );
  }

  @override
  Future stop() => _delegate.stop();

  @override
  void startWeb(
    MediaStream stream, {
    Function(dynamic blob, bool isLastOne)? onDataChunk,
    String? mimeType,
    int timeSlice = 1000,
  }) =>
      _delegate.startWeb(
        stream,
        onDataChunk: onDataChunk,
        mimeType: mimeType ?? 'video/webm',
        timeSlice: timeSlice,
      );
}
