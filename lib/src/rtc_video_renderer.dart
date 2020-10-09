import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../flutter_webrtc.dart';
import 'interface/rtc_video_renderer.dart';

class RTCVideoRenderer extends VideoRenderer {
  RTCVideoRenderer() : _delegate = videoRenderer();

  final VideoRenderer _delegate;

  @override
  Future<void> initialize() => _delegate.initialize();

  @override
  bool get renderVideo => _delegate.renderVideo;

  @override
  bool get muted => _delegate.muted;

  @override
  MediaStream get srcObject => _delegate.srcObject;

  @override
  set muted(bool mute) => _delegate.muted = mute;

  @override
  set srcObject(MediaStream stream) => _delegate.srcObject = stream;

  @override
  int get textureId => _delegate.textureId;
}
