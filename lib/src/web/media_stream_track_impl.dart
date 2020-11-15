import 'dart:async';
import 'dart:html' as html;

import 'package:dart_webrtc/dart_webrtc.dart' as dart_webrtc;
import 'package:js/js.dart';

import '../interface/media_stream_track.dart';

class MediaStreamTrackWeb extends MediaStreamTrack {
  MediaStreamTrackWeb(this.jsTrack) {
    jsTrack.onended = allowInterop((event) {
      onEnded?.call();
    });
    jsTrack.onmute = allowInterop((event) {
      onMute?.call();
    });
  }

  final dart_webrtc.MediaStreamTrack jsTrack;

  @override
  String get id => jsTrack.id;

  @override
  String get kind => jsTrack.kind;

  @override
  String get label => jsTrack.label;

  @override
  bool get enabled => jsTrack.enabled;

  @override
  set enabled(bool b) {
    jsTrack.enabled = b;
  }

  @override
  Future<bool> switchCamera() async {
    // TODO(cloudwebrtc): ???
    return false;
  }

  @override
  Future<void> adaptRes(int width, int height) async {
    // TODO(cloudwebrtc): ???
  }

  @override
  void setVolume(double volume) {
    final constraints = jsTrack.getConstraints();
    constraints['volume'] = volume;
    jsTrack.applyConstraints(constraints);
  }

  @override
  void setMicrophoneMute(bool mute) {
    jsTrack.enabled = !mute;
  }

  @override
  void enableSpeakerphone(bool enable) {
    // Should this throw error?
  }

  @override
  Future<dynamic> captureFrame([String filePath]) async {
    final imageCapture = html.ImageCapture(jsTrack as html.MediaStreamTrack);
    final bitmap = await imageCapture.grabFrame();
    final html.CanvasElement canvas = html.Element.canvas();
    canvas.width = bitmap.width;
    canvas.height = bitmap.height;
    final html.ImageBitmapRenderingContext renderer =
        canvas.getContext('bitmaprenderer');
    renderer.transferFromImageBitmap(bitmap);
    final dataUrl = canvas.toDataUrl();
    bitmap.close();
    return dataUrl;
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    jsTrack.stop();
  }

  @override
  Future<bool> hasTorch() {
    return Future.value(false);
  }

  @override
  Future<void> setTorch(bool torch) {
    throw UnimplementedError('The web implementation does not support torch');
  }
}
