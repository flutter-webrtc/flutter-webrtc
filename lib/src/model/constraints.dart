/// Display media constraints data.
class DisplayConstraints {
  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {};
  }
}

/// Device audio and video constraints data.
class DeviceConstraints {
  /// Optional constraints to lookup audio devices with.
  DeviceConstraintMap<AudioConstraints> audio = DeviceConstraintMap();

  /// Optional constraints to lookup video devices with.
  DeviceConstraintMap<DeviceVideoConstraints> video = DeviceConstraintMap();

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, Map<String, dynamic>> toMap() {
    return {
      'audio': audio.toMap(),
      'video': video.toMap(),
    };
  }
}

/// Abstract device constraint property.
class DeviceConstraintMap<T extends DeviceMediaConstraints> {
  /// Storage for the mandatory constraint.
  T? mandatory;

  /// Storage for the optional constraint.
  T? optional;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {
      'mandatory': mandatory?.toMap(),
      'optional': optional?.toMap(),
    };
  }
}

/// Some device abstract constraints.
abstract class DeviceMediaConstraints {
  /// Converts [DeviceMediaConstraints] to the [Map] expected by Flutter.
  Map<String, dynamic> toMap();
}

/// [DeviceMediaConstraints] for audio devices.
class AudioConstraints implements DeviceMediaConstraints {
  String? deviceId;

  /// Converts this model to the [Map] expected by Flutter.
  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (deviceId != null) {
      map['deviceId'] = deviceId;
    }
    return map;
  }
}

/// Directions in which a camera may produce a video.
enum FacingMode {
  /// Indicates that video source is facing toward the user (this includes, for
  /// example, the front-facing camera on a smartphone).
  user,

  /// Indicates that video source is facing away from the user, thereby viewing
  /// their environment (the back camera on a smartphone).
  environment,
}

/// Device constraints related to a video.
class DeviceVideoConstraints implements DeviceMediaConstraints {
  /// Constraint to search for a device with some concrete device ID.
  String? deviceId;

  /// Constraint to search for a device with some [FacingMode].
  FacingMode? facingMode;

  /// Constraint to search for a device with a concrete height.
  int? height;

  /// Constraint to search for a device with a concrete width.
  int? width;

  /// Constraint to search for a device with a concrete FPS.
  int? fps;

  /// Converts this model to the [Map] expected by Flutter.
  @override
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (deviceId != null) {
      map['deviceId'] = deviceId;
    }
    if (facingMode != null) {
      map['facingMode'] = facingMode!.index;
    }
    if (height != null) {
      map['height'] = height;
    }
    if (width != null) {
      map['width'] = width;
    }
    if (fps != null) {
      map['fps'] = fps;
    }
    return map;
  }
}
