import 'dart:async';
import 'dart:js_interop';

import 'package:collection/collection.dart';
import 'package:web/web.dart' as web;

import '../../model/constraints.dart';
import '/src/model/track.dart';
import '/src/platform/track.dart';

// ignore_for_file: avoid_web_libraries_in_flutter

class WebMediaStreamTrack extends MediaStreamTrack {
  WebMediaStreamTrack(this.jsTrack);

  final web.MediaStreamTrack jsTrack;

  @override
  String deviceId() {
    return jsTrack.getSettings().deviceId;
  }

  @override
  String id() {
    return jsTrack.id;
  }

  @override
  void onEnded(OnEndedCallback cb) {
    jsTrack.onended = cb.toJS;
  }

  @override
  bool isEnabled() {
    return jsTrack.enabled;
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
  Future<MediaStreamTrackState> state() {
    return Future.value(
      jsTrack.readyState == 'live'
          ? MediaStreamTrackState.live
          : MediaStreamTrackState.ended,
    );
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

  @override
  FacingMode? facingMode() {
    var settings = jsTrack.getSettings();
    String? facingMode = settings.facingMode;
    return FacingMode.values.firstWhereOrNull(
      (element) => element.name.toLowerCase() == facingMode,
    );
  }

  @override
  FutureOr<int?> height() {
    var settings = jsTrack.getSettings();
    return settings.height;
  }

  @override
  FutureOr<int?> width() {
    var settings = jsTrack.getSettings();
    return settings.width;
  }
}
