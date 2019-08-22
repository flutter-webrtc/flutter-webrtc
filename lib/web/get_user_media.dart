import 'dart:async';
// ignore: uri_does_not_exist
import 'dart:js' as JS;
// ignore: uri_does_not_exist
import 'dart:html' as HTML;
import 'media_stream.dart';

class navigator {

  static Future<MediaStream> getUserMedia(Map<String, dynamic> mediaConstraints) async {
    final nav = HTML.window.navigator;
    final jsStream = await nav.getUserMedia(
        audio: mediaConstraints['audio'] ?? false,
        video: mediaConstraints['video'] ?? false
    );
    print("Got jsStream ${jsStream}");
    return MediaStream(jsStream);
  }

  //TODO: test this
  static Future<MediaStream> getDisplayMedia(Map<String, dynamic> mediaConstraints) async {
    final nav = HTML.window.navigator;
    final mediaDevices = nav.mediaDevices;
    final jsMediaDevices = JS.JsObject.fromBrowserObject(mediaDevices);
    if (jsMediaDevices.hasProperty(getDisplayMedia)) {
      final JS.JsObject arg = JS.JsObject.jsify({"video":true});
      JS.JsObject getDisplayMediaPromise = jsMediaDevices.callMethod('getDisplayMedia',[arg]);
      final HTML.MediaStream jsStream = await HTML.promiseToFuture(getDisplayMediaPromise);
      return MediaStream(jsStream);
    } else {
      final HTML.MediaStream jsStream = await nav.getUserMedia(
        video: {"mediaSource":'screen'},
        audio: mediaConstraints['audio'] ?? false
      );
      return MediaStream(jsStream);
    }
  }

  //FIXME(rostopira): throws weird error
  static Future<List<dynamic>> getSources() async {
    final List devices = await HTML.window.navigator.mediaDevices.enumerateDevices();
    return devices.cast<dynamic>();
  }

}
