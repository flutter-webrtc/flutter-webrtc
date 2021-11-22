import 'dart:async';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'factory_impl.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    [Map<String, dynamic> constraints = const {}]) async {
  return RTCFactoryNative.instance
      .createPeerConnection(configuration, constraints);
}

Future<MediaStream> createLocalMediaStream(String label) async {
  return RTCFactoryNative.instance.createLocalMediaStream(label);
}

MediaRecorder mediaRecorder() {
  return RTCFactoryNative.instance.mediaRecorder();
}

VideoRenderer videoRenderer() {
  return RTCFactoryNative.instance.videoRenderer();
}

Navigator get navigator => RTCFactoryNative.instance.navigator;
