import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'utils.dart';

/// Decoded PCM of one remote audio track, as delivered by the native track
/// sink before the playout mixer applies the track volume.
class RTCRemoteAudioPcm {
  RTCRemoteAudioPcm(this.data, this.sampleRate, this.channels, this.frames);

  /// Interleaved little-endian PCM16.
  final Uint8List data;
  final int sampleRate;
  final int channels;
  final int frames;
}

/// Experimental: receives the decoded PCM of a remote audio track so that the
/// application can process and play it itself.
///
/// With [silenceNativePlayout] the track's playout volume is set to 0: the SDK
/// keeps decoding and pulling the track (the tap keeps receiving), but nothing
/// of it reaches the native speaker. The previous volume is restored on
/// [detach]. Only Windows and macOS are implemented.
///
/// The native sink runs on a real-time audio thread. It only appends to a
/// bounded buffer without waiting for locks; a separate thread delivers the
/// buffered PCM to [pcm]. Data that cannot be buffered is dropped and counted
/// in [stats] rather than blocking audio.
class RTCRemoteAudioTap {
  RTCRemoteAudioTap._(this.id, this.trackId) {
    _subscription = EventChannel('FlutterWebRTC/remoteAudioTap/$id')
        .receiveBroadcastStream()
        .listen((event) {
      final map = event as Map<dynamic, dynamic>;
      _controller.add(RTCRemoteAudioPcm(
          map['data'] as Uint8List,
          map['sampleRate'] as int,
          map['channels'] as int,
          map['frames'] as int));
    }, onError: _controller.addError);
  }

  final String id;
  final String trackId;
  final _controller = StreamController<RTCRemoteAudioPcm>.broadcast();
  StreamSubscription<dynamic>? _subscription;
  bool _detached = false;

  Stream<RTCRemoteAudioPcm> get pcm => _controller.stream;

  static Future<RTCRemoteAudioTap> attach(MediaStreamTrack track,
      {bool silenceNativePlayout = true}) async {
    if (track.kind != 'audio') {
      throw ArgumentError('Expected an audio track');
    }
    if (!Platform.isWindows && !Platform.isMacOS) {
      throw UnsupportedError(
          'Remote audio taps are implemented for Windows/macOS');
    }
    final result = await WebRTC.invokeMethod<Map<dynamic, dynamic>, dynamic>(
        'remoteAudioTapAttach', <String, dynamic>{
      'trackId': track.id,
      'silenceNativePlayout': silenceNativePlayout,
    });
    if (result == null) throw StateError('No remote audio tap returned');
    return RTCRemoteAudioTap._(result['tapId'] as String, track.id!);
  }

  /// Delivered/dropped counters of the native buffer.
  Future<Map<dynamic, dynamic>> stats() async {
    if (_detached) return {};
    return (await WebRTC.invokeMethod<Map<dynamic, dynamic>, dynamic>(
            'remoteAudioTapStats', <String, dynamic>{'tapId': id})) ??
        {};
  }

  /// Removes the sink and restores the native playout volume. Idempotent.
  Future<void> detach() async {
    if (_detached) return;
    _detached = true;
    await WebRTC.invokeMethod<void, dynamic>(
        'remoteAudioTapDetach', <String, dynamic>{'tapId': id});
    await _subscription?.cancel();
    await _controller.close();
  }
}
