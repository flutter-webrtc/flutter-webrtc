import 'package:webrtc_interface/webrtc_interface.dart';

import 'mediadevices_impl.dart';
import 'desktopcapturer_impl.dart';

class NavigatorNative extends Navigator {
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
  MediaDevices get mediaDevices => MediaDeviceNative();

  @override
  DesktopCapturer get desktopCapturer => DesktopCapturerNative();
}
