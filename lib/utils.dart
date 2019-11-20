import 'dart:io';
import 'package:flutter/services.dart';

class WebRTC {
  static const MethodChannel _channel =
      const MethodChannel('FlutterWebRTC.Method');
  static MethodChannel methodChannel() => _channel;

  static bool get platformIsDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static bool get platformIsMobile => Platform.isIOS || Platform.isAndroid;

  static bool get platformIsWeb => false;
}
