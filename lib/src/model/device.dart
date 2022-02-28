/// Media device kind.
enum MediaDeviceKind {
  /// Represents an audio input device (for example, a microphone).
  audioinput,

  /// Represents an audio output device (for example, a pair of headphones).
  audiooutput,

  /// Represents a video input device (for example, a webcam).
  videoinput,
}

/// Information about some media device.
class MediaDeviceInfo {
  /// Creates a [MediaDeviceInfo] basing on the [Map] received from the native
  /// side.
  MediaDeviceInfo.fromMap(dynamic map) {
    deviceId = map['deviceId'];
    label = map['label'];
    kind = MediaDeviceKind.values[map['kind']];
  }

  /// Identifier of the represented device.
  late String deviceId;

  /// Human-readable device description (for example, "External USB Webcam").
  late String label;

  /// Media kind of the device (for example, `audioinput` for microphone).
  late MediaDeviceKind kind;
}
