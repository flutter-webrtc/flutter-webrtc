import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

import 'media_stream.dart';
import 'media_stream_track.dart';
import 'utils.dart';
import 'enums.dart';

class MediaRecorder {
  MethodChannel _channel = WebRTC.methodChannel();
  static final _random = Random();
  final _recorderId = _random.nextInt(0x7FFFFFFF);

  MediaRecorder();

  Future<void> start(String path,
      {MediaStreamTrack videoTrack, RecorderAudioChannel audioChannel
      //TODO: add codec/quality options
      }) async {
    if (path == null) throw ArgumentError.notNull("path");
    if (audioChannel == null && videoTrack == null)
      throw Exception("Neither audio nor video track were provided");

    await _channel.invokeMethod('startRecordToFile', {
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

  Future<dynamic> stop() async => await _channel
      .invokeMethod('stopRecordToFile', {'recorderId': _recorderId});
}
