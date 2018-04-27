import 'package:webrtc/WebRTC.dart';
import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/RTCPeerConnection.dart';
import 'package:flutter/services.dart';

dynamic getUserMedia(MediaConstraints mediaConstraints) async {
  MethodChannel channel = WebRTC.methodChannel();
    try {
        final Map<dynamic, dynamic> response = await channel.invokeMethod(
        'getUserMedia',
        <String, dynamic>{ 'constraints': mediaConstraints },
        );
        int mediaStreamId = response['mediaStreamId'];
        return new MediaStream(channel,mediaStreamId);
    } on PlatformException catch (e) {
        throw 'Unable to getUserMedia: ${e.message}';
    }
}