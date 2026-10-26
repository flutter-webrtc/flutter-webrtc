import 'dart:async';

import 'package:flutter/services.dart';
import 'package:webrtc_interface/webrtc_interface.dart' show MediaStreamTrack;

import '../flutter_webrtc.dart' show WebRTC;
import 'audio_track_sink.dart';
import 'native/media_stream_track_impl.dart';

var _captureSeq = 0;

Stream<AudioFrame> audioTrackFrames(MediaStreamTrack track) {
  if (track is! MediaStreamTrackNative) {
    throw UnsupportedError('audioTrackFrames: not a native track');
  }
  if (track.kind != 'audio') {
    throw UnsupportedError('audioTrackFrames: track is not audio');
  }

  final captureId = ++_captureSeq;
  final channel = EventChannel('FlutterWebRTC/audioTrackCapture$captureId');
  final started = WebRTC.invokeMethod('startAudioTrackCapture', {
    'trackId': track.id,
    'peerConnectionId': track.peerConnectionId,
    'captureId': captureId,
  });

  StreamSubscription? sub;
  var cancelled = false;
  final controller = StreamController<AudioFrame>(
    onCancel: () async {
      cancelled = true;
      await sub?.cancel();
      await WebRTC.invokeMethod('stopAudioTrackCapture', {
        'captureId': captureId,
      });
    },
  );

  started.then((_) {
    if (cancelled) return;
    sub = channel.receiveBroadcastStream().listen(
      (event) {
        final m = event as Map;
        controller.add(
          AudioFrame(
            pcm: m['pcm'] as Uint8List,
            sampleRate: m['sampleRate'] as int,
            channels: m['channels'] as int,
          ),
        );
      },
      onError: controller.addError,
      onDone: controller.close,
    );
  }).catchError((Object e) {
    controller.addError(e);
    controller.close();
  });

  return controller.stream;
}
