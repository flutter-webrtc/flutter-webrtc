import 'dart:async';
import 'dart:math';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_track_impl.dart';
import 'utils.dart';

class MediaRecorderNative extends MediaRecorder {
  MediaRecorderNative({
    String? albumName = 'FlutterWebRTC',
  }) : _albumName = albumName;
  static final _random = Random();
  final _recorderId = _random.nextInt(0x7FFFFFFF);
  var _isStarted = false;
  final String? _albumName;

  @override
  Future<void> start(
    String path, {
    MediaStreamTrack? videoTrack,
    RecorderAudioChannel? audioChannel,
  }) async {
    if (audioChannel == null && videoTrack == null) {
      throw Exception('Neither audio nor video track were provided');
    }

    await WebRTC.invokeMethod('startRecordToFile', {
      'path': path,
      if (audioChannel != null) 'audioChannel': audioChannel.index,
      if (videoTrack != null) 'videoTrackId': videoTrack.id,
      'recorderId': _recorderId,
      'peerConnectionId': videoTrack is MediaStreamTrackNative
          ? videoTrack.peerConnectionId
          : null
    });
    _isStarted = true;
  }

  @override
  void startWeb(MediaStream stream,
      {Function(dynamic blob, bool isLastOne)? onDataChunk,
      String? mimeType,
      int timeSlice = 1000}) {
    throw 'It\'s for Flutter Web only';
  }

  @override
  Future<dynamic> stop() async {
    if (!_isStarted) {
      throw "Media recorder not started!";
    }
    return await WebRTC.invokeMethod('stopRecordToFile', {
      'recorderId': _recorderId,
      'albumName': _albumName,
    });
  }
}
