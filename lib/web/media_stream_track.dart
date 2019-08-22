import 'dart:async';
// ignore: uri_does_not_exist
import 'dart:html' as HTML;
// ignore: uri_does_not_exist
import 'dart:js' as JS;

class MediaStreamTrack {
  final HTML.MediaStreamTrack jsTrack;
  HTML.VideoElement videoElement;

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
    final video = videoElement;
    if (video == null)
      throw "Not attached to video element!";
    final HTML.CanvasElement canvas = HTML.Element.canvas();
    final HTML.CanvasRenderingContext2D context = canvas.getContext('2d');
    final settings = jsTrack.getSettings();
    var width = settings['width'];
    var height = settings['height'];
    if (width is! num || height is! num)
      throw "Unable to get video size";
    width = (width as num).toInt();
    height = (height as num).toInt();
    canvas.width = width;
    canvas.height = height;
    context.drawImageScaled(video, 0, 0, width, height);
    final resultData = canvas.toDataUrl('image/jpg');
    return resultData;
  }

  Future<void> dispose() {
    jsTrack.stop();
    return Future.value();
  }
}
