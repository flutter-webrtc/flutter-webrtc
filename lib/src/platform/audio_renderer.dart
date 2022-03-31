import '/src/platform/track.dart';

import 'native/audio_renderer.dart'
    if (dart.library.html) 'web/audio_renderer.dart';

/// Renderer for audio [MediaStreamTrack]s.
abstract class AudioRenderer {
  /// Returns the [MediaStreamTrack], currently played by this [AudioRenderer].
  MediaStreamTrack? get srcObject;

  /// Sets the [MediaStreamTrack] to be played by this [AudioRenderer].
  set srcObject(MediaStreamTrack? srcObject);

  /// Disposes this [AudioRenderer].
  Future<void> dispose();
}

/// Creates a new platform-specific [AudioRenderer].
AudioRenderer createAudioRenderer() {
  return createPlatformSpecificAudioRenderer();
}
