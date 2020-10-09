import '../interface/media_stream.dart';
import '../interface/mediadevices.dart';
import '../interface/navigator.dart';
import 'mediadevices_impl.dart';

class NavigatorWeb extends Navigator {
  @override
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints) {
    return mediaDevices.getDisplayMedia(mediaConstraints);
  }

  @override
  Future<List> getSources() {
    return mediaDevices.getSources();
  }

  @override
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints) {
    return mediaDevices.getUserMedia(mediaConstraints);
  }

  @override
  MediaDevices get mediaDevices => MediaDevicesWeb();
}
