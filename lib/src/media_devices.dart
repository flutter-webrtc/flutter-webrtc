import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaDevices {
  @Deprecated(
      'Use the navigator(). getUserMedia(Map<String, dynamic>) provide from the facrory instead')
  static Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    return navigator().getUserMedia(mediaConstraints);
  }

  @Deprecated(
      'Use the navigator().getDisplayMedia(Map<String, dynamic>) provide from the facrory instead')
  static Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    return navigator().getDisplayMedia(mediaConstraints);
  }

  @Deprecated(
      'Use the navigator().getSources() provide from the facrory instead')
  static Future<List<dynamic>> getSources() {
    return navigator().getSources();
  }
}
