import '../flutter_webrtc.dart';
import 'interface/rtc_video_renderer.dart';

class RTCVideoRenderer {
  RTCVideoRenderer() : _delegate = videoRenderer();

  final VideoRenderer _delegate;

  VideoRenderer get delegate => _delegate;

  set onResize(Function func) => _delegate.onResize = func;

  Future<void> initialize() => _delegate.initialize();

  int get videoWidth => _delegate.videoWidth;

  int get videoHeight => _delegate.videoHeight;

  bool get renderVideo => _delegate.renderVideo;

  bool get muted => _delegate.muted;

  MediaStream? get srcObject => _delegate.srcObject;

  set muted(bool mute) => _delegate.muted = mute;

  set audioOutput(String deviceId) => _delegate.audioOutput(deviceId);

  set srcObject(MediaStream? stream) => _delegate.srcObject = stream;

  int? get textureId => _delegate.textureId;

  Future<void> dispose() async {
    return _delegate.dispose();
  }
}
