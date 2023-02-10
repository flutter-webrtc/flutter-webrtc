import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
import 'package:rxdart/rxdart.dart';

class OrientationHelper {
  static Future<void> setPreferredOrientations(
      List<DeviceOrientation> orientations) {
    return OrientationPlugin.setPreferredOrientations(orientations);
  }

  static Future<void> forceOrientation(DeviceOrientation orientation) {
    return OrientationPlugin.forceOrientation(orientation);
  }

  static DeviceOrientation get initOrientation => DeviceOrientation.portraitUp;
  static Stream<DeviceOrientation>? _onOrientationChange;

  static Stream<DeviceOrientation> get onOrientationChange {
    _onOrientationChange ??= OrientationPlugin.onOrientationChange
        .shareValueSeeded(initOrientation)
        .distinct((previous, next) => previous == next);
    return _onOrientationChange!;
  }
}
