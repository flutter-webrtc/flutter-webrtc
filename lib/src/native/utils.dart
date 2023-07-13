import 'dart:io';

import 'package:flutter/services.dart';

class WebRTC {
  static const MethodChannel _channel = MethodChannel('FlutterWebRTC.Method');

  static bool get platformIsDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get platformIsWindows => Platform.isWindows;

  static bool get platformIsMacOS => Platform.isMacOS;

  static bool get platformIsLinux => Platform.isLinux;

  static bool get platformIsMobile => Platform.isIOS || Platform.isAndroid;

  static bool get platformIsIOS => Platform.isIOS;

  static bool get platformIsAndroid => Platform.isAndroid;

  static bool get platformIsWeb => false;

  static Future<T?> invokeMethod<T, P>(String methodName,
      [dynamic param]) async {
    await initialize();

    return _channel.invokeMethod<T>(
      methodName,
      param,
    );
  }

  static bool initialized = false;

  static Future<void> initialize({Map<String, dynamic>? options}) async {
    if (!initialized) {
      await _channel.invokeMethod<void>('initialize', <String, dynamic>{
        'options': options ?? {},
      });
      initialized = true;
    }
  }
}
