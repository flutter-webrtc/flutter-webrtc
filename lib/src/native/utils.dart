import 'dart:io';
import 'package:flutter/services.dart';

class WebRTC {
  static const MethodChannel _channel = MethodChannel('FlutterWebRTC.Method');
  static MethodChannel methodChannel() => _channel;

  static bool get platformIsDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static bool get platformIsMobile => Platform.isIOS || Platform.isAndroid;

  static bool get platformIsIOS => Platform.isIOS;

  static bool get platformIsAndroid => Platform.isAndroid;

  static bool get platformIsWeb => false;
}
