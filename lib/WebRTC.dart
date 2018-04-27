import 'package:flutter/services.dart';

class WebRTC {
  static const MethodChannel _channel = const MethodChannel('cloudwebrtc.com/WebRTC.Method');
  static MethodChannel methodChannel() => _channel;

  static const EventChannel _eventChannel = const EventChannel('cloudwebrtc.com/WebRTC.Event');
  static EventChannel eventChannel() => _eventChannel;
}
