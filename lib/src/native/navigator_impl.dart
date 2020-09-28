import 'package:flutter_webrtc/src/interface/media_stream.dart';
import 'package:flutter_webrtc/src/interface/navigator.dart';
import 'package:flutter_webrtc/src/interface/mediadevices.dart';
import 'package:flutter_webrtc/src/native/mediadevices_impl.dart';

class NavigatorNative extends Navigator {
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
  MediaDevices get mediaDevices => MediaDeviceNative();
}
