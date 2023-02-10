import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ScreenHelper {
  ScreenHelper._internal();

  static final _instance = ScreenHelper._internal();

  factory ScreenHelper() => _instance;

  static ScreenHelper get instance => _instance;

  // When this changes, onMetricsChanged is called.
  // https://api.flutter.dev/flutter/dart-ui/FlutterView/physicalSize.html
  static Size sizeOfPhysical = window.physicalSize;
  static double widthOfPhysical = sizeOfPhysical.width;
  static double heightOfPhysical = sizeOfPhysical.height;

  static double devicePixelRatio = window.devicePixelRatio;

  static const double widthOfStandard = 375.0;

  // If you use this, you should ensure that you also register for notifications so that you can update your MediaQueryData when the window's metrics change.
  // For example, see WidgetsBindingObserver.didChangeMetrics or dart:ui.PlatformDispatcher.onMetricsChanged.
  // https://api.flutter.dev/flutter/widgets/MediaQueryData/MediaQueryData.fromWindow.html
  static Size sizeOfLogical = MediaQueryData.fromWindow(window).size;
  static double widthOfLogical = sizeOfLogical.width;
  static double heightOfLogical = sizeOfLogical.height;

  static double ratioOfAxisX = widthOfLogical / widthOfStandard;

  bool get lessStandardWidth => widthOfLogical < widthOfStandard;
  bool get moreStandardWidth => widthOfLogical > widthOfStandard * 1.5;
  bool get bigSizeTablet => widthOfLogical > widthOfStandard * 2.5;

  // static void initialize() {}

  @override
  String toString() {
    return 'PhysicalSize: $sizeOfPhysical \nLogicalSize: $sizeOfLogical \ndevicePixelRatio: $devicePixelRatio \nratioOfAxisX: $ratioOfAxisX';
  }
}
