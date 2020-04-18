import 'dart:html' as HTML;

class DeviceInfo {
  static String get label {
    return 'Flutter Web ( ' + HTML.window.navigator.userAgent + ' )';
  }

  static String get userAgent {
    return 'flutter-webrtc/web-plugin 0.0.1';
  }
}
