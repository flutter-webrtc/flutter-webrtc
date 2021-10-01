import 'dart:async';
import 'dart:math';

import '../interface/enums.dart';
import '../interface/media_recorder.dart';
import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import 'utils.dart';

class MediaRecorderNative extends MediaRecorder {
  static final _random = Random();
  final _recorderId = _random.nextInt(0x7FFFFFFF);

  @override
  Future<void> start(String path,
      {MediaStreamTrack? videoTrack, RecorderAudioChannel? audioChannel
      // TODO(cloudwebrtc): add codec/quality options
      }) async {
    if (audioChannel == null && videoTrack == null) {
      throw Exception('Neither audio nor video track were provided');
    }

    await WebRTC.invokeMethod('startRecordToFile', {
      'path': path,
      if (audioChannel != null) 'audioChannel': audioChannel.index,
      if (videoTrack != null) 'videoTrackId': videoTrack.id,
      'recorderId': _recorderId
    });
  }

  @override
  void startWeb(MediaStream stream,
      {Function(dynamic blob, bool isLastOne)? onDataChunk, String? mimeType}) {
    throw 'It\'s for Flutter Web only';
  }

  @override
  Future<dynamic> stop() async => await WebRTC.invokeMethod(
      'stopRecordToFile', {'recorderId': _recorderId});
}
