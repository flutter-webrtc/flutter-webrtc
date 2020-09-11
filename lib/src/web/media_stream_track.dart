import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

class MediaStreamTrack {
  const MediaStreamTrack(this.jsTrack);

  final html.MediaStreamTrack jsTrack;

  set enabled(bool enabled) => jsTrack.enabled = enabled;

  bool get enabled => jsTrack.enabled;

  String get label => jsTrack.label;

  String get kind => jsTrack.kind;

  String get id => jsTrack.id;

  ///Future contains isFrontCamera
  ///Throws error if switching camera failed
  Future<bool> switchCamera() async {
    // TODO(cloudwebrtc): ???
    return false;
  }

  Future<void> adaptRes(int width, int height) async {
    // TODO(cloudwebrtc): ???
  }

  void setVolume(double volume) {
    final constraints = jsTrack.getConstraints();
    constraints['volume'] = volume;
    js.JsObject.fromBrowserObject(jsTrack)
        .callMethod('applyConstraints', [js.JsObject.jsify(constraints)]);
  }

  void setMicrophoneMute(bool mute) {
    jsTrack.enabled = !mute;
  }

  void enableSpeakerphone(bool enable) {
    // Should this throw error?
  }

  Future<dynamic> captureFrame([String filePath]) async {
    final imageCapture = html.ImageCapture(jsTrack);
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

  Future<void> dispose() {
    jsTrack.stop();
    return Future.value();
  }
}
