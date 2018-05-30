import 'package:flutter/services.dart';

class WebRTC {
  static const MethodChannel _channel = const MethodChannel('cloudwebrtc.com/WebRTC.Method');
  static MethodChannel methodChannel() => _channel;
}
