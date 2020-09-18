import 'dart:async';
import 'dart:html' as html;

import '../model/media_stream.dart';
import '../model/media_stream_track.dart';
import 'media_stream_track_web.dart';

class MediaStreamWeb extends MediaStream {
  MediaStreamWeb(this.jsStream, String ownerTag) : super(jsStream.id, ownerTag);
  final html.MediaStream jsStream;

  @override
  Future<void> getMediaTracks() {
    return Future.value();
  }

  @override
  Future<void> addTrack(MediaStreamTrack track, {bool addToNative = true}) {
    if (addToNative) {
      var _native = track as MediaStreamTrackWeb;
      jsStream.addTrack(_native.jsTrack);
    }
    return Future.value();
  }

  @override
  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNative = true}) async {
    if (removeFromNative) {
      var _native = track as MediaStreamTrackWeb;
      jsStream.removeTrack(_native.jsTrack);
    }
  }

  @override
  List<MediaStreamTrack> getAudioTracks() => jsStream
      .getAudioTracks()
      .map((jsTrack) => MediaStreamTrackWeb(jsTrack))
      .toList();

  @override
  List<MediaStreamTrack> getVideoTracks() => jsStream
      .getVideoTracks()
      .map((jsTrack) => MediaStreamTrackWeb(jsTrack))
      .toList();

  @override
  Future<void> dispose() async {
    jsStream.getAudioTracks().forEach((track) => track.stop());
    jsStream.getVideoTracks().forEach((track) => track.stop());
    return super.dispose();
  }
}
