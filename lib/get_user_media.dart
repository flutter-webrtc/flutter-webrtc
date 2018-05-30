import 'package:webrtc/webrtc.dart';
import 'package:webrtc/media_stream.dart';
import 'package:flutter/services.dart';

dynamic getUserMedia(Map<String, dynamic> mediaConstraints) async {
  MethodChannel channel = WebRTC.methodChannel();
  try {
    final Map<dynamic, dynamic> response = await channel.invokeMethod(
      'getUserMedia',
      <String, dynamic>{'constraints': mediaConstraints},
    );
    String streamId = response["streamId"];
    MediaStream stream =  new MediaStream(streamId);
    stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
    return stream;
  } on PlatformException catch (e) {
    throw 'Unable to getUserMedia: ${e.message}';
  }
}
