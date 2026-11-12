import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
import 'media_stream_impl.dart';
import 'utils.dart';

/// Experimental caller-owned PCM/video source. Does not acquire capture devices.
/// Initialize before any ordinary factory operation. One source per factory.
/// PCM is little-endian mono48kHz16bit,480samples per call. Video is packed BGRA.
class RTCExternalMediaSource {
  RTCExternalMediaSource._(
      this.stream, this.hasRenderReference, this.videoTimestampSource);
  final MediaStream stream;
  final bool hasRenderReference;
  final String videoTimestampSource;
  bool _closed = false;
  int _lastVideoTimestamp = -1;
  static const _renderChannel =
      EventChannel('FlutterWebRTC.ExternalMediaEvents');
  static Stream<Map<dynamic, dynamic>>? _renderEvents;

  static Future<RTCExternalMediaSource> create(
      {bool audio = true,
      bool video = true,
      bool audioProcessing = false}) async {
    if (!audio && !video) throw ArgumentError('At least one track is required');
    if (!Platform.isWindows && !Platform.isMacOS) {
      throw UnsupportedError('External media is implemented for Windows/macOS');
    }
    await WebRTC.initialize(options: {'externalAudioInputOnly': true});
    final result = await WebRTC.invokeMethod<Map<dynamic, dynamic>, dynamic>(
        'externalMediaCreate',
        {'audio': audio, 'video': video, 'audioProcessing': audioProcessing});
    if (result == null) throw StateError('No external stream returned');
    return RTCExternalMediaSource._(
        MediaStreamNative.fromMap(result),
        result['renderReference'] == true,
        result['videoTimestampSource'] as String? ?? 'arrival');
  }

  void _check() {
    if (_closed) throw StateError('External source is disposed');
  }

  /// PCM actually supplied to the custom macOS speaker device. Windows callers
  /// use a selected-endpoint render-loopback adapter; this API is explicit.
  Stream<Map<dynamic, dynamic>> get renderReference {
    _check();
    if (!hasRenderReference) {
      throw UnsupportedError(
          'This platform requires an external render reference adapter');
    }
    return _renderEvents ??=
        _renderChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();
  }

  Future<void> pushAudio(Uint8List pcm) async {
    _check();
    if (stream.getAudioTracks().isEmpty || pcm.length != 960) {
      throw ArgumentError(
          'Expected480 mono48k PCM16 samples and an audio track');
    }
    await WebRTC.invokeMethod<void, dynamic>(
        'externalMediaAudio', {'streamId': stream.id, 'bytes': pcm});
  }

  Future<void> pushVideo(
      Uint8List bgra, int width, int height, int timestampUs) async {
    _check();
    if (stream.getVideoTracks().isEmpty ||
        width <= 0 ||
        height <= 0 ||
        width > 1920 ||
        height > 1080 ||
        bgra.length != width * height * 4 ||
        timestampUs < 0 ||
        timestampUs > 9223372036854775 ||
        timestampUs <= _lastVideoTimestamp) {
      throw ArgumentError(
          'Expected packed BGRA <=1920x1080 and increasing timestampUs');
    }
    // Reserve before awaiting so concurrent calls cannot reorder timestamps.
    _lastVideoTimestamp = timestampUs;
    await WebRTC.invokeMethod<void, dynamic>('externalMediaVideo', {
      'streamId': stream.id,
      'bytes': bgra,
      'width': width,
      'height': height,
      'timestampUs': timestampUs
    });
  }

  Future<void> flush() async {
    _check();
    await WebRTC.invokeMethod<void, dynamic>(
        'externalMediaFlush', {'streamId': stream.id});
  }

  Future<Map<dynamic, dynamic>> stats() async {
    _check();
    return (await WebRTC.invokeMethod<Map<dynamic, dynamic>, dynamic>(
            'externalMediaStats', {'streamId': stream.id})) ??
        {};
  }

  /// Detach senders before disposing their source. Does not stop caller capture.
  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    await WebRTC.invokeMethod<void, dynamic>(
        'externalMediaDispose', {'streamId': stream.id});
  }
}
