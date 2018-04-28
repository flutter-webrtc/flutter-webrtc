import 'package:webrtc/WebRTC.dart';
import 'package:webrtc/MediaStream.dart';
import 'package:flutter/services.dart';

dynamic getUserMedia(Map<String, dynamic> mediaConstraints) async {
  MethodChannel channel = WebRTC.methodChannel();
    try {
        final Map<dynamic, dynamic> response = await channel.invokeMethod(
        'getUserMedia',
        <String, dynamic>{ 'constraints': mediaConstraints },
        );
        String mediaStreamId = response["streamId"];
        return new MediaStream(mediaStreamId);
    } on PlatformException catch (e) {
        throw 'Unable to getUserMedia: ${e.message}';
    }
}