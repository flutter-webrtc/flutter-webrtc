import 'package:webrtc_interface/webrtc_interface.dart';

/// Web stub for [CustomVideoSource]. Custom video sources are native-only
/// (Android/iOS/macOS); every method throws [UnimplementedError] on web.
///
/// See `docs/custom-video-source.md` for the full contract.
class CustomVideoSource {
  CustomVideoSource._();

  static Future<MediaStream> createStream(
    String sourceType, {
    int width = 1280,
    int height = 720,
    int fps = 30,
    Map<String, dynamic>? options,
  }) {
    throw UnimplementedError('CustomVideoSource is not supported on web');
  }

  static Future<dynamic> command(
    MediaStreamTrack track,
    String command, [
    Map<String, dynamic>? args,
  ]) {
    throw UnimplementedError('CustomVideoSource is not supported on web');
  }
}
