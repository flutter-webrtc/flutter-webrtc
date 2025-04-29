import 'package:webrtc_interface/webrtc_interface.dart' as rtc;

import '../flutter_webrtc.dart';

class MediaRecorder extends rtc.MediaRecorder {
  MediaRecorder() : _delegate = mediaRecorder();
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
  Future stop({String? albumName}) =>
      _delegate.stop(albumName: albumName ?? "FlutterWebRtc");

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
