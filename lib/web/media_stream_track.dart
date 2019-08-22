import 'dart:async';
// ignore: uri_does_not_exist
import 'dart:html' as HTML;
// ignore: uri_does_not_exist
import 'dart:js' as JS;

class MediaStreamTrack {
  final HTML.MediaStreamTrack jsTrack;

  MediaStreamTrack(this.jsTrack);

  set enabled(bool enabled) =>
    jsTrack.enabled = enabled;

  bool get enabled => jsTrack.enabled;
  String get label => jsTrack.label;
  String get kind => jsTrack.kind;
  String get id => jsTrack.id;

  ///Future contains isFrontCamera
  ///Throws error if switching camera failed
  Future<bool> switchCamera() async {
    //TODO
    return false;
  }

  Future<void> adaptRes(int width, int height) async {
    //TODO
  }

  void setVolume(double volume) {
    final constraints = jsTrack.getConstraints();
    constraints['volume'] = volume;
    JS.JsObject.fromBrowserObject(jsTrack).callMethod(
        'applyConstraints',
        [JS.JsObject.jsify(constraints)]
    );
  }
  
  void setMicrophoneMute(bool mute) {
    jsTrack.enabled = !mute;
  }
  
  void enableSpeakerphone(bool enable) {
    // Should this throw error?
  }

  Future<dynamic> captureFrame(String filePath, int rotation) async {
    final imageCapture = HTML.ImageCapture(jsTrack);
    return imageCapture.grabFrame();
  }

  Future<void> dispose() {
    jsTrack.stop();
    return Future.value();
  }
}
