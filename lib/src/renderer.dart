import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../flutter_webrtc.dart';
import 'interface/rtc_video_renderer.dart' as r;

@Deprecated('Use videoRenderer() instead')
class RTCVideoRenderer extends r.VideoRenderer {
  factory RTCVideoRenderer() => videoRenderer();

  @override
  bool muted;

  @override
  MediaStream srcObject;

  @override
  Future<void> initialize() {
    throw UnimplementedError();
  }

  @override
  bool get renderVideo => throw UnimplementedError();
}
