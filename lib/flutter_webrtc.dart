library flutter_webrtc;

export 'package:webrtc_interface/webrtc_interface.dart'
    hide MediaDevices, MediaRecorder, Navigator;

export 'src/helper.dart';
export 'src/desktop_capturer.dart';
export 'src/media_devices.dart';
export 'src/media_recorder.dart';
export 'src/video_renderer_extension.dart';
export 'src/native/factory_impl.dart'
    if (dart.library.js_interop) 'src/web/factory_impl.dart';
export 'src/native/rtc_video_renderer_impl.dart'
    if (dart.library.js_interop) 'src/web/rtc_video_renderer_impl.dart';
export 'src/native/rtc_video_view_impl.dart'
    if (dart.library.js_interop) 'src/web/rtc_video_view_impl.dart';
export 'src/native/utils.dart'
    if (dart.library.js_interop) 'src/web/utils.dart';
export 'src/native/adapter_type.dart';
export 'src/native/camera_utils.dart';
export 'src/native/audio_management.dart';
export 'src/native/android/audio_configuration.dart';
export 'src/native/ios/audio_configuration.dart';
export 'src/native/rtc_video_platform_view_controller.dart';
export 'src/native/rtc_video_platform_view.dart';
