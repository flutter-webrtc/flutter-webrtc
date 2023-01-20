import '/src/api/bridge.g.dart' as ffi;

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
    isFailed = map['isFailed'];
  }

  /// Creates a [MediaDeviceInfo] basing on the [ffi.MediaDeviceInfo] received
  /// from the native side.
  MediaDeviceInfo.fromFFI(ffi.MediaDeviceInfo info) {
    deviceId = info.deviceId;
    label = info.label;
    kind = MediaDeviceKind.values[info.kind.index];
    isFailed = false;
  }

  /// Identifier of the represented device.
  late String deviceId;

  /// Human-readable device description (for example, "External USB Webcam").
  late String label;

  /// Media kind of the device (for example, `audioinput` for microphone).
  late MediaDeviceKind kind;

  /// Indicator whether the last attempt to use this device failed.
  late bool isFailed;
}

/// Information about a display.
class MediaDisplayInfo {
  /// Creates a [MediaDisplayInfo] basing on the [ffi.MediaDisplayInfo] received
  /// from the native side.
  MediaDisplayInfo.fromFFI(ffi.MediaDisplayInfo info) {
    deviceId = info.deviceId;
    title = info.title;
  }

  /// Identifier of the device representing the display.
  late String deviceId;

  /// Title of the display.
  late String? title;
}
