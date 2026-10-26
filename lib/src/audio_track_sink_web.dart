import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dart_webrtc/dart_webrtc.dart' as dw show MediaStreamTrackWeb;
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart' show MediaStreamTrack;

import 'audio_track_sink.dart';

/// Decoded PCM of a web audio track via Web Audio.
///
/// ponytail: ScriptProcessorNode is deprecated and runs on the main
/// thread, but it is the only API that works in every browser without a
/// separately served AudioWorklet module. For a transcription tap
/// (mono, modest rates) it is enough; the upgrade path is an
/// AudioWorkletNode with an inlined blob module.
Stream<AudioFrame> audioTrackFrames(MediaStreamTrack track) {
  if (track is! dw.MediaStreamTrackWeb) {
    throw UnsupportedError('audioTrackFrames: not a web track');
  }
  final jsTrack = track.jsTrack;
  if (jsTrack.kind != 'audio') {
    throw UnsupportedError('audioTrackFrames: track is not audio');
  }

  final ctx = web.AudioContext();
  final jsStream = web.MediaStream()..addTrack(jsTrack);
  final src = ctx.createMediaStreamSource(jsStream);
  const bufferSize = 4096;
  // Mono in, mono out — the tap downmixes anyway; let the browser mix.
  final proc = ctx.createScriptProcessor(bufferSize, 1, 1);

  // Proc must reach ctx.destination for onaudioprocess to fire, but the
  // track is already audible elsewhere — route through a silent gain so
  // the tap never plays back (mic feedback / doubled remote audio).
  final mute = ctx.createGain()..gain.value = 0.0;

  final controller = StreamController<AudioFrame>(
    onCancel: () async {
      proc.disconnect();
      mute.disconnect();
      src.disconnect();
      await ctx.close().toDart;
    },
  );

  proc.onaudioprocess = (web.AudioProcessingEvent e) {
    if (controller.isClosed) return;
    final buf = e.inputBuffer;
    final nCh = buf.numberOfChannels;
    final len = buf.length;
    // Downmix to mono while converting float [-1,1] -> s16le.
    final s16 = Uint8List(len * 2);
    final bd = s16.buffer.asByteData();
    for (var i = 0; i < len; i++) {
      var sample = 0.0;
      for (var c = 0; c < nCh; c++) {
        sample += buf.getChannelData(c).toDart[i];
      }
      sample /= nCh;
      final clamped = sample.clamp(-1.0, 1.0);
      bd.setInt16(i * 2, (clamped * 32767).round(), Endian.little);
    }
    controller.add(
      AudioFrame(pcm: s16, sampleRate: buf.sampleRate.round(), channels: 1),
    );
  }.toJS;

  src.connect(proc);
  proc.connect(mute);
  mute.connect(ctx.destination);
  return controller.stream;
}
