import 'media_stream.dart';

abstract class MediaDevices {
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints);
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints);
  Future<List<dynamic>> getSources();
}
