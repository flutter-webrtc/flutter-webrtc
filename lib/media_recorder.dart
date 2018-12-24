import 'dart:math';

import 'package:flutter_webrtc/media_stream_track.dart';
import 'package:flutter_webrtc/utils.dart';
import 'package:meta/meta.dart';

class MediaRecorder {
  static final _random = Random();
  final _recorderId = _random.nextInt(0x7FFFFFFF);

  Future<void> start({
    @required String path,
    MediaStreamTrack audioTrack,
    MediaStreamTrack videoTrack,
    //TODO: add codec/quality options
  }) async {
    if (path == null)
      throw ArgumentError.notNull("path");
    if (audioTrack == null && videoTrack == null)
      throw Exception("Neither audio nor video track were provided");

    await WebRTC.methodChannel().invokeMethod('startRecordToFile', {
      'path' : path,
      'audioTrackId' : audioTrack?.id,
      'videoTrackId' : videoTrack?.id,
      'recorderId' : _recorderId
    });
  }

  Future<void> stop() async =>
      await WebRTC.methodChannel().invokeMethod('stopRecordToFile', {
        'recorderId' : _recorderId
      });

}