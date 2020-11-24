typedef StreamTrackCallback = Function();

abstract class MediaStreamTrack {
  MediaStreamTrack();

  /// Returns the unique identifier of the track
  String get id;

  /// This may label audio and video sources (e.g., "Internal microphone" or
  /// "External USB Webcam").
  ///
  /// Returns the label of the object's corresponding source, if any.
  /// If the corresponding source has or had no label, returns an empty string.
  String get label;

  /// Returns the string 'audio' if this object represents an audio track
  /// or 'video' if this object represents a video track.
  String get kind;

  /// Callback for onmute event
  StreamTrackCallback onMute;

  /// Callback for unmute event
  StreamTrackCallback onUnMute;

  /// Callback foronended event
  StreamTrackCallback onEnded;

  /// Returns the enable state of [MediaStreamTrack]
  bool get enabled;

  /// Set the enable state of [MediaStreamTrack]
  ///
  /// Note: After a [MediaStreamTrack] has ended, setting the enable state
  /// will not change the ended state.
  set enabled(bool b);

  /// Returns true if the track is muted, and false otherwise.
  bool get muted;

  /// Future contains isFrontCamera
  /// Throws error if switching camera failed
  Future<bool> switchCamera();

  Future<void> adaptRes(int width, int height);

  void setVolume(double volume);

  void setMicrophoneMute(bool mute);

  void enableSpeakerphone(bool enable);

  Future<dynamic> captureFrame([String filePath]);

  Future<bool> hasTorch();

  Future<void> setTorch(bool torch);

  Future<void> dispose();
}
