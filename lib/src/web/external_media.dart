import 'dart:async';
import 'dart:typed_data';
import 'package:webrtc_interface/webrtc_interface.dart';

/// Placeholder with explicit failure until the external-media Web backend lands.
class RTCExternalMediaSource {
  static Future<RTCExternalMediaSource> create(
          {bool audio = true,
          bool video = true,
          bool audioProcessing = false}) async =>
      throw UnsupportedError('External media Web backend is not implemented');
  MediaStream get stream =>
      throw UnsupportedError('External media Web backend');
  bool get hasRenderReference => false;
  String get videoTimestampSource => 'unsupported';
  Stream<Map<dynamic, dynamic>> get renderReference =>
      throw UnsupportedError('External media Web backend');
  Future<void> pushAudio(Uint8List pcm) async =>
      throw UnsupportedError('External media Web backend');
  Future<void> pushVideo(
          Uint8List bgra, int width, int height, int timestampUs) async =>
      throw UnsupportedError('External media Web backend');
  Future<void> flush() async =>
      throw UnsupportedError('External media Web backend');
  Future<Map<dynamic, dynamic>> stats() async =>
      throw UnsupportedError('External media Web backend');
  Future<void> dispose() async {}
}
