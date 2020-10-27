import 'package:flutter/services.dart';

class WebRTC {
  static bool get platformIsDesktop => false;

  static bool get platformIsMobile => false;

  static bool get platformIsWeb => true;

  static MethodChannel methodChannel() => throw UnimplementedError;
}

Map<String, dynamic> convertToDart(Object jsObject) {
  return {};
}
