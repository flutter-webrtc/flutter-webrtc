import 'dart:typed_data';

import 'package:webrtc_interface/webrtc_interface.dart' show MediaStreamTrack;

import 'audio_track_sink_native.dart'
    if (dart.library.js_interop) 'audio_track_sink_web.dart' as impl;

/// One decoded PCM frame of a single audio track.
/// `pcm` is signed 16-bit little-endian, `channels` interleaved.
/// Empty pcm = silence that was already filtered out upstream.
class AudioFrame {
  const AudioFrame({
    required this.pcm,
    required this.sampleRate,
    required this.channels,
  });

  final Uint8List pcm;
  final int sampleRate;
  final int channels;
}

/// Opens a decoded-audio tap on one audio track.
///
/// Local tracks yield captured PCM before it is sent (mute the track and
/// the stream keeps producing silent frames). Remote tracks yield PCM after
/// libwebrtc decoded them. One stream per track: this is the per-source tap
/// `MediaRecorder`'s INPUT/OUTPUT file mix cannot provide.
///
/// The stream is closed when the track ends or [cancel] is called on the
/// subscription. Throws UnsupportedError on platforms without a sink.
Stream<AudioFrame> audioTrackFrames(MediaStreamTrack track) =>
    impl.audioTrackFrames(track);
