import 'media_stream.dart';

class MediaStreamConstraints {
  MediaStreamConstraints({this.audio, this.video});
  dynamic audio;
  dynamic video;
}

abstract class MediaDevices {
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints);
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints);
  Future<List<dynamic>> getSources();
}
