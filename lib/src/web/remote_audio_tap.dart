import 'dart:typed_data';

import 'package:webrtc_interface/webrtc_interface.dart';

class RTCRemoteAudioPcm {
  RTCRemoteAudioPcm(this.data, this.sampleRate, this.channels, this.frames);
  final Uint8List data;
  final int sampleRate;
  final int channels;
  final int frames;
}

/// Not implemented on the web.
class RTCRemoteAudioTap {
  static Future<RTCRemoteAudioTap> attach(MediaStreamTrack track,
          {bool silenceNativePlayout = true}) =>
      throw UnsupportedError(
          'Remote audio taps are not implemented on the web');

  String get id => throw UnsupportedError('web');
  String get trackId => throw UnsupportedError('web');
  Stream<RTCRemoteAudioPcm> get pcm => throw UnsupportedError(
      'Remote audio taps are not implemented on the web');
  Future<Map<dynamic, dynamic>> stats() async => {};
  Future<void> detach() async {}
}
