import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js;

import '../interface/media_stream_track.dart';

class MediaStreamTrackWeb extends MediaStreamTrack {
  MediaStreamTrackWeb(this.jsTrack) {
    jsTrack.onEnded.listen((event) => onEnded?.call());
    jsTrack.onMute.listen((event) => onMute?.call());
    jsTrack.onUnmute.listen((event) => onUnMute?.call());
  }

  final html.MediaStreamTrack jsTrack;

  @override
  String get id => jsTrack.id;

  @override
  String get kind => jsTrack.kind;

  @override
  String get label => jsTrack.label;

  @override
  bool get enabled => jsTrack.enabled;

  @override
  bool get muted => jsTrack.muted;

  @override
  set enabled(bool b) {
    jsTrack.enabled = b;
  }

  @override
  Map<String, dynamic> getConstraints() {
    return jsTrack.getConstraints();
  }

  @override
  Future<void> applyConstraints([Map<String, dynamic> constraints]) async {
    // TODO(wermathurin): Wait for: https://github.com/dart-lang/sdk/commit/1a861435579a37c297f3be0cf69735d5b492bc6c
    // to be merged to use jsTrack.applyConstraints() directly
    final arg = js.jsify(constraints);

    final _val = await js.promiseToFuture<void>(
        js.callMethod(jsTrack, 'applyConstraints', [arg]));
    return _val;
  }

  // TODO(wermathurin): https://github.com/dart-lang/sdk/issues/44319
  // @override
  // MediaTrackCapabilities getCapabilities() {
  //   var _converted = jsTrack.getCapabilities();
  //   print(_converted['aspectRatio'].runtimeType);
  //   return null;
  // }

  @override
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

  @override
  Future<void> dispose() async {
    return stop();
  }

  @override
  Future<void> stop() async {
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
