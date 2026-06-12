import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_impl.dart';
import 'utils.dart';

/// Generic API for app-provided ("custom") video sources.
///
/// The app registers a capturer factory on the native side
/// (`CustomVideoSourceRegistry` on Android, `FlutterRTCCustomVideoSourceRegistry` on
/// iOS/macOS) under a `sourceType` name, then creates a regular
/// [MediaStream] from it via [createStream]. Runtime interaction with the
/// capturer (e.g. `updateOverlay`, `hitTest`) goes through [command].
///
/// See `docs/custom-video-source.md` for the full contract.
class CustomVideoSource {
  CustomVideoSource._();

  /// Creates a local [MediaStream] whose single video track is fed by the
  /// custom capturer registered under [sourceType].
  ///
  /// Throws a [PlatformException] with code `CustomVideoSourceNotRegistered`
  /// if no factory is registered for [sourceType].
  static Future<MediaStream> createStream(
    String sourceType, {
    int width = 1280,
    int height = 720,
    int fps = 30,
    Map<String, dynamic>? options,
  }) async {
    final response = await WebRTC.invokeMethod(
      'createCustomVideoTrack',
      <String, dynamic>{
        'sourceType': sourceType,
        'width': width,
        'height': height,
        'fps': fps,
        'options': options ?? {},
      },
    );
    if (response == null) {
      throw Exception('createCustomVideoTrack returned null, something wrong');
    }
    return MediaStreamNative.fromMap(<dynamic, dynamic>{
      'streamId': response['streamId'],
      'ownerTag': response['ownerTag'] ?? 'local',
      'audioTracks': response['audioTracks'] ?? [],
      'videoTracks': response['videoTracks'] ?? [],
    });
  }

  /// Sends [command] (with optional [args]) to the custom capturer backing
  /// [track] and returns whatever the capturer implementation returns
  /// (map/scalar/null).
  ///
  /// Throws a [PlatformException] with code
  /// `CustomVideoSourceCommandUnsupported` if the capturer does not support
  /// [command].
  static Future<dynamic> command(
    MediaStreamTrack track,
    String command, [
    Map<String, dynamic>? args,
  ]) {
    return WebRTC.invokeMethod(
      'customVideoSourceCommand',
      <String, dynamic>{
        'trackId': track.id,
        'command': command,
        'args': args ?? {},
      },
    );
  }
}
