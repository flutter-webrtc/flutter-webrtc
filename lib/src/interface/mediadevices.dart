import 'media_stream.dart';

class MediaStreamConstraints {
  MediaStreamConstraints({this.audio, this.video});

  /// Either a bool (which indicates whether or not an audio track is requested)
  /// or a MediaTrackConstraints object providing the constraints which must be
  /// met by the audio track included in the returned MediaStream.
  ///
  /// If constraints are specified, an audio track is inherently requested.
  dynamic audio;

  /// Either a bool (which indicates whether or not a video track is requested)
  /// or a MediaTrackConstraints object providing the constraints which must be
  /// met by the video track included in the returned MediaStream.
  ///
  /// If constraints are specified, a video track is inherently requested.
  dynamic video;
}

/// [MediaTrackSupportedConstraints] represents the list of constraints
/// controlling the capabilities of a [MediaStreamTrack].
class MediaTrackSupportedConstraints {
  MediaTrackSupportedConstraints({
    this.aspectRatio = false,
    this.autoGainControl = false,
    this.brightness = false,
    this.channelCount = false,
    this.colorTemperature = false,
    this.contrast = false,
    this.deviceId = false,
    this.echoCancellation = false,
    this.exposureCompensation = false,
    this.exposureMode = false,
    this.exposureTime = false,
    this.facingMode = false,
    this.focusDistance = false,
    this.focusMode = false,
    this.frameRate = false,
    this.groupId = false,
    this.height = false,
    this.iso = false,
    this.latency = false,
    this.noiseSuppression = false,
    this.pan = false,
    this.pointsOfInterest = false,
    this.resizeMode = false,
    this.sampleRate = false,
    this.sampleSize = false,
    this.saturation = false,
    this.sharpness = false,
    this.tilt = false,
    this.torch = false,
    this.whiteBalanceMode = false,
    this.width = false,
    this.zoom = false,
  });

  final bool aspectRatio,
      autoGainControl,
      brightness,
      channelCount,
      colorTemperature,
      contrast,
      deviceId,
      echoCancellation,
      exposureCompensation,
      exposureMode,
      exposureTime,
      facingMode,
      focusDistance,
      focusMode,
      frameRate,
      groupId,
      height,
      iso,
      latency,
      noiseSuppression,
      pan,
      pointsOfInterest,
      resizeMode,
      sampleRate,
      sampleSize,
      saturation,
      sharpness,
      tilt,
      torch,
      whiteBalanceMode,
      width,
      zoom;
}

abstract class MediaDevices {
  /// Calling this method will prompts the user to select and grant permission
  /// to capture the contents of a display or portion thereof (such as a window)
  /// as a MediaStream. The resulting stream can then be recorded using the
  /// MediaStream Recording API or transmitted as part of a WebRTC session.
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints);

  /// Calling this method will prompts the user to select and grant permission
  /// to capture the contents of a display or portion thereof (such as a window)
  /// as a MediaStream. The resulting stream can then be recorded using the
  ///  MediaStream Recording API or transmitted as part of a WebRTC session.
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints);

  @Deprecated('use enumerateDevices() instead')
  Future<List<dynamic>> getSources();

  /// Returns a List of [MediaDeviceInfo] describing the devices.
  Future<List<MediaDeviceInfo>> enumerateDevices();

  /// Returns [MediaTrackSupportedConstraints] recognized by a User Agent for
  /// controlling the Capabilities of a [MediaStreamTrack] object.
  MediaTrackSupportedConstraints getSupportedConstraints() {
    throw UnimplementedError();
  }
}

/// This describe the media input and output devices, such as microphones,
/// cameras, headsets, and so forth.
class MediaDeviceInfo {
  MediaDeviceInfo({
    this.kind,
    required this.label,
    this.groupId,
    required this.deviceId,
  });

  /// Returns a String that is an identifier for the represented device that
  /// is persisted across sessions. It is un-guessable by other applications
  /// and unique to the origin of the calling application. It is reset when
  /// the user clears cookies (for Private Browsing, a different identifier
  /// is used that is not persisted across sessions).
  final String deviceId;

  /// Returns a String that is a group identifier. Two devices have the same
  /// group identifier if they belong to the same physical device
  /// — for example a monitor with both a built-in camera and a microphone.
  final String? groupId;

  /// Returns an enumerated value that is either 'videoinput', 'audioinput' or
  /// 'audiooutput'.
  final String? kind;

  /// Returns a String that is a label describing this device
  /// (for example "External USB Webcam").
  final String label;
}
