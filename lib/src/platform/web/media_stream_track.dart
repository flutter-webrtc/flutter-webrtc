import 'dart:async';
import 'dart:html' as html;

import '/src/model/track.dart';
import '/src/platform/track.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

class WebMediaStreamTrack extends MediaStreamTrack {
  WebMediaStreamTrack(this.jsTrack);

  final html.MediaStreamTrack jsTrack;

  @override
  String deviceId() {
    return jsTrack.getSettings()['deviceId']!;
  }

  @override
  String id() {
    return jsTrack.id!;
  }

  @override
  bool isEnabled() {
    return jsTrack.enabled ?? false;
  }

  @override
  MediaKind kind() {
    var jsKind = jsTrack.kind;
    if (jsKind == 'audio') {
      return MediaKind.audio;
    } else {
      return MediaKind.video;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    jsTrack.enabled = enabled;
  }

  @override
  Future<void> stop() async {
    jsTrack.stop();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<MediaStreamTrack> clone() async {
    return WebMediaStreamTrack(jsTrack.clone());
  }
}
