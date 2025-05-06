import 'package:flutter_webrtc/flutter_webrtc.dart';

extension VideoRendererExtension on RTCVideoRenderer {
  RTCVideoValue get videoValue => value;
}
