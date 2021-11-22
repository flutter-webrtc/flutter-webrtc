library flutter_webrtc;

export 'package:webrtc_interface/webrtc_interface.dart'
    hide MediaDevices, MediaRecorder, Navigator;

export 'src/helper.dart';
export 'src/media_devices.dart';
export 'src/media_recorder.dart';
export 'src/native/rtc_peerconnection_factory.dart'
    if (dart.library.html) 'src/web/rtc_peerconnection_factory.dart';
export 'src/native/rtc_video_view_impl.dart'
    if (dart.library.html) 'src/web/rtc_video_view_impl.dart';
export 'src/native/utils.dart' if (dart.library.html) 'src/web/utils.dart';
export 'src/rtc_video_renderer.dart';
