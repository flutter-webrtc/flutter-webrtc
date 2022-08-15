import 'dart:async';

import 'package:flutter/services.dart';

class FlutterWebRTCEventChannel {
  FlutterWebRTCEventChannel._internal() {
    EventChannel('FlutterWebRTC.Event')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  static final FlutterWebRTCEventChannel instance =
      FlutterWebRTCEventChannel._internal();

  final StreamController<Map<String, dynamic>> handleEvents =
      StreamController.broadcast();

  void eventListener(dynamic event) async {
    final Map<dynamic, dynamic> map = event;
    handleEvents.add(<String, dynamic>{map['event'] as String: map});
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }
}
