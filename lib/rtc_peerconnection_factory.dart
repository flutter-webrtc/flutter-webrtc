import 'package:webrtc/webrtc.dart';
import 'package:webrtc/rtc_peerconnection.dart';
import 'package:flutter/services.dart';
import 'dart:async';

Future<RTCPeerConnection> createPeerConnection(Map<String,dynamic> configuration, Map<String,dynamic> constraints) async {
  MethodChannel channel = WebRTC.methodChannel();

  Map<String, dynamic> DEFAULT_CONSTRAINTS = {
      "mandatory": {},
      "optional": [
        {"DtlsSrtpKeyAgreement": true },
      ],
    };

    final Map<dynamic, dynamic> response = await channel.invokeMethod(
      'createPeerConnection',
      <String, dynamic>{
        'configuration': configuration,
        'constraints': constraints.length == 0? DEFAULT_CONSTRAINTS : constraints
      },
    );

    String peerConnectionId = response['peerConnectionId'];
    return new RTCPeerConnection(peerConnectionId);
}