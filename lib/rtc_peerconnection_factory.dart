import 'dart:async';
import 'package:flutter/services.dart';

import 'rtc_peerconnection.dart';
import 'utils.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    Map<String, dynamic> constraints) async {
  MethodChannel methodChannel = WebRTC.methodChannel();

  final Map<dynamic, dynamic> response = await methodChannel.invokeMethod(
    'createPeerConnection',
    <String, dynamic>{
      'configuration': configuration,
      'constraints': (constraints == null || constraints.length == 0)
          ? defaultConstraints
          : constraints
    },
  );

  return new RTCPeerConnection(response['peerConnectionId'], configuration);
}
