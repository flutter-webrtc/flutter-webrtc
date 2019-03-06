import 'dart:async';
import 'dart:math';

import 'package:flutter_webrtc/media_stream_track.dart';
import 'package:flutter_webrtc/utils.dart';

class MediaRecorder {
  static final _random = Random();
  final _recorderId = _random.nextInt(0x7FFFFFFF);

  Future<void> start(String path, {
    MediaStreamTrack videoTrack,
    RecorderAudioChannel audioChannel
    //TODO: add codec/quality options
  }) async {
    if (path == null)
      throw ArgumentError.notNull("path");
    if (audioChannel == null && videoTrack == null)
      throw Exception("Neither audio nor video track were provided");

    await WebRTC.methodChannel().invokeMethod('startRecordToFile', {
      'path' : path,
      'audioChannel' : audioChannel?.index,
      'videoTrackId' : videoTrack?.id,
      'recorderId' : _recorderId
    });
  }

  Future<void> stop() async =>
      await WebRTC.methodChannel().invokeMethod('stopRecordToFile', {
        'recorderId' : _recorderId
      });

}

enum RecorderAudioChannel { INPUT, OUTPUT }