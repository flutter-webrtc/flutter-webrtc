/// Represents an information about some media device.
class MediaDeviceInfo {
  /// Identifier of the represented media device.
  var deviceId: String

  /// Human-readable device description (for example, "External USB Webcam").
  var label: String

  /// Media kind of the represented media device.
  var kind: MediaDeviceKind

  /// Initializes a new `MediaDeviceInfo` based on the provided data.
  init(deviceId: String, label: String, kind: MediaDeviceKind) {
    self.deviceId = deviceId
    self.label = label
    self.kind = kind
  }

  /// Converts this `MediaDeviceInfo` into a `Dictionary` which can be returned
  /// to Flutter side.
  func asFlutterResult() -> [String: Any?] {
    [
      "deviceId": self.deviceId,
      "label": self.label,
      "kind": self.kind.rawValue,
    ]
  }
}
