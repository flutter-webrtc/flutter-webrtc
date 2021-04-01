import 'package:flutter/services.dart';

class WebRTC {
  static bool get platformIsDesktop => false;

  static bool get platformIsWindows => false;

  static bool get platformIsLinux => false;

  static bool get platformIsMobile => false;

  static bool get platformIsIOS => false;

  static bool get platformIsAndroid => false;

  static bool get platformIsWeb => true;

  static MethodChannel methodChannel() =>
      throw UnimplementedError('No need to use methodChannel in the web!');
}
