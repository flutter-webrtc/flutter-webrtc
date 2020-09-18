import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'rtc_video_renderer.dart';

abstract class RTCFactory {
  Future<RTCPeerConnection> createPeerConnection(
      Map<String, dynamic> configuration,
      [Map<String, dynamic> constraints]);

  Future<MediaStream> createLocalMediaStream(String label);

  MediaDevices mediaDevices();

  MediaRecorder mediaRecorder();

  RTCVideoRenderer videoRenderer();
}
