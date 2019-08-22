import 'dart:async';
// ignore: uri_does_not_exist
import 'dart:html' as HTML;
import 'media_stream_track.dart';

class MediaStream {
  final HTML.MediaStream jsStream;
  MediaStream(this.jsStream);

  Future<void> getMediaTracks() {
    return Future.value();
  }

  String get id => jsStream.id;
  Future<void> addTrack(MediaStreamTrack track, {bool addToNaitve = true}) {
    if (addToNaitve) {
      jsStream.addTrack(track.jsTrack);
    }
    return Future.value();
  }

  Future<void> removeTrack(MediaStreamTrack track, {bool removeFromNaitve = true}) async {
    if (removeFromNaitve) {
      jsStream.removeTrack(track.jsTrack);
    }
  }

  List<MediaStreamTrack> getAudioTracks() => jsStream
      .getAudioTracks()
      .map((jsTrack) => MediaStreamTrack(jsTrack))
      .toList();

  List<MediaStreamTrack> getVideoTracks() => jsStream
      .getVideoTracks()
      .map((jsTrack) => MediaStreamTrack(jsTrack))
      .toList();

  Future<Null> dispose() async {
    jsStream.getAudioTracks().forEach((track) => track.stop());
    jsStream.getVideoTracks().forEach((track) => track.stop());
  }

}
