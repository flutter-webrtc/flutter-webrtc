import 'dart:async';
import 'package:flutter/services.dart';
import 'rtc_peerconnection.dart';
import 'utils.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    Map<String, dynamic> constraints) async {
  MethodChannel channel = WebRTC.methodChannel();

  Map<String, dynamic> defaultConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };

  final Map<dynamic, dynamic> response = await channel.invokeMethod(
    'createPeerConnection',
    <String, dynamic>{
      'configuration': configuration,
      'constraints': constraints.length == 0 ? defaultConstraints : constraints
    },
  );

  String peerConnectionId = response['peerConnectionId'];
  return new RTCPeerConnection(peerConnectionId, configuration);
}
