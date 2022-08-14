import 'package:webrtc_interface/webrtc_interface.dart';

import 'mediadevices_impl.dart';

class NavigatorNative extends Navigator {
  NavigatorNative._internal();

  static final NavigatorNative instance = NavigatorNative._internal();

  @override
  Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints) {
    return mediaDevices.getDisplayMedia(mediaConstraints);
  }

  @override
  Future<List> getSources() {
    return mediaDevices.enumerateDevices();
  }

  @override
  Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints) {
    return mediaDevices.getUserMedia(mediaConstraints);
  }

  @override
  MediaDevices get mediaDevices => MediaDeviceNative.instance;
}
