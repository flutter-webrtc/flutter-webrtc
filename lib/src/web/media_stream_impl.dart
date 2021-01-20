import 'dart:async';
import 'dart:html' as html;

import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import 'media_stream_track_impl.dart';

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
  List<MediaStreamTrack> getAudioTracks() {
    var audioTracks = <MediaStreamTrack>[];
    jsStream
        .getAudioTracks()
        .forEach((jsTrack) => audioTracks.add(MediaStreamTrackWeb(jsTrack)));
    return audioTracks;
  }

  @override
  List<MediaStreamTrack> getVideoTracks() {
    var audioTracks = <MediaStreamTrack>[];
    jsStream
        .getVideoTracks()
        .forEach((jsTrack) => audioTracks.add(MediaStreamTrackWeb(jsTrack)));
    return audioTracks;
  }

  @override
  Future<void> dispose() async {
    getTracks().forEach((element) {
      element.dispose();
    });
    return super.dispose();
  }

  @override
  List<MediaStreamTrack> getTracks() {
    return <MediaStreamTrack>[...getAudioTracks(), ...getVideoTracks()];
  }

  @override
  bool get active => jsStream.active;

  @override
  MediaStream clone() {
    return MediaStreamWeb(jsStream.clone(), ownerTag);
  }
}
