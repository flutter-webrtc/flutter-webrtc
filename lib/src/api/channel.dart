import 'package:flutter/services.dart';

/// Prefix for the all the channels created by the [flutter_webrtc] library.
const prefix = 'FlutterWebRtc';

/// Returns a [MethodChannel] compound from the provided `name` and `id`.
MethodChannel methodChannel(String name, int id) {
  return MethodChannel('$prefix/$name/$id');
}

/// Returns an [EventChannel] compound from the provided `name` and `id`.
EventChannel eventChannel(String name, int id) {
  return EventChannel('$prefix/$name/$id');
}
