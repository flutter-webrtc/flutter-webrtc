import 'dart:typed_data';

import 'package:flutter_webrtc/src/helper.dart';

typedef StreamTrackCallback = Function();

abstract class MediaStreamTrack {
  MediaStreamTrack();

  /// Returns the unique identifier of the track
  String? get id;

  /// This may label audio and video sources (e.g., "Internal microphone" or
  /// "External USB Webcam").
  ///
  /// Returns the label of the object's corresponding source, if any.
  /// If the corresponding source has or had no label, returns an empty string.
  String? get label;

  /// Returns the string 'audio' if this object represents an audio track
  /// or 'video' if this object represents a video track.
  String? get kind;

  /// Callback for onmute event
  StreamTrackCallback? onMute;

  /// Callback for unmute event
  StreamTrackCallback? onUnMute;

  /// Callback foronended event
  StreamTrackCallback? onEnded;

  /// Returns the enable state of [MediaStreamTrack]
  bool get enabled;

  /// Set the enable state of [MediaStreamTrack]
  ///
  /// Note: After a [MediaStreamTrack] has ended, setting the enable state
  /// will not change the ended state.
  set enabled(bool b);

  /// Returns true if the track is muted, and false otherwise.
  bool? get muted;

  /// Returns a map containing the set of constraints most recently established
  /// for the track using a prior call to applyConstraints().
  ///
  /// These constraints indicate values and ranges of values that the Web site
  /// or application has specified are required or acceptable for the included
  /// constrainable properties.
  Map<String, dynamic> getConstraints() {
    throw UnimplementedError();
  }

  /// Applies a set of constraints to the track.
  ///
  /// These constraints let the Web site or app establish ideal values and
  /// acceptable ranges of values for the constrainable properties of the track,
  /// such as frame rate, dimensions, echo cancelation, and so forth.
  Future<void> applyConstraints([Map<String, dynamic>? constraints]) {
    throw UnimplementedError();
  }

  // TODO(wermathurin): This ticket is related to the implementation of jsTrack.getCapabilities(),
  //  https://github.com/dart-lang/sdk/issues/44319.
  //
  // MediaTrackCapabilities getCapabilities() {
  //   throw UnimplementedError();
  // }

  // MediaStreamTrack clone();

  Future<void> stop();

  /// Throws error if switching camera failed
  @Deprecated('use Helper.switchCamera() instead')
  Future<bool> switchCamera() {
    throw UnimplementedError();
  }

  @deprecated
  Future<void> adaptRes(int width, int height) {
    throw UnimplementedError();
  }

  void setVolume(double volume) {
    Helper.setVolume(volume, this);
  }

  void setMicrophoneMute(bool mute) {
    Helper.setMicrophoneMute(mute, this);
  }

  void enableSpeakerphone(bool enable) {
    throw UnimplementedError();
  }

  Future<ByteBuffer> captureFrame() {
    throw UnimplementedError();
  }

  Future<bool> hasTorch() {
    throw UnimplementedError();
  }

  Future<void> setTorch(bool torch) {
    throw UnimplementedError();
  }

  @Deprecated('use stop() instead')
  Future<void> dispose();

  @override
  String toString() {
    return 'Track(id: $id, kind: $kind, label: $label, enabled: $enabled, muted: $muted)';
  }
}

// TODO(wermathurin): Need to implement missing API

// readonly attribute MediaStreamTrackState readyState;
// MediaTrackCapabilities getCapabilities();
// MediaTrackSettings getSettings();
