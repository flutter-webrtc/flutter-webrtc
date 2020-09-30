import 'media_stream.dart';
import 'mediadevices.dart';

abstract class Navigator {
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints);
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints);
  Future<List<dynamic>> getSources();
  MediaDevices get mediaDevices;
}
