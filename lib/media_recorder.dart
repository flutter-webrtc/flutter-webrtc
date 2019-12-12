import 'dart:async';
import 'dart:math';

import 'media_stream.dart';
import 'media_stream_track.dart';
import 'utils.dart';
import 'enums.dart';

class MediaRecorder {
  static final _random = Random();
  final _recorderId = _random.nextInt(0x7FFFFFFF);

  Future<void> start(String path,
      {MediaStreamTrack videoTrack, RecorderAudioChannel audioChannel
      //TODO: add codec/quality options
      }) async {
    if (path == null) throw ArgumentError.notNull("path");
    if (audioChannel == null && videoTrack == null)
      throw Exception("Neither audio nor video track were provided");

    await WebRTC.methodChannel().invokeMethod('startRecordToFile', {
      'path': path,
      'audioChannel': audioChannel?.index,
      'videoTrackId': videoTrack?.id,
      'recorderId': _recorderId
    });
  }

  void startWeb(MediaStream stream,
      {Function(dynamic blob, bool isLastOne) onDataChunk,
      String mimeType = 'video/mp4;codecs=h264'}) {
    throw "It's for Flutter Web only";
  }

  Future<dynamic> stop() async => await WebRTC.methodChannel()
      .invokeMethod('stopRecordToFile', {'recorderId': _recorderId});
}
