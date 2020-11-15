import 'dart:async';
import 'package:dart_webrtc/dart_webrtc.dart' as js;

import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import 'media_stream_track_impl.dart';

class MediaStreamWeb extends MediaStream {
  MediaStreamWeb(this.jsStream, String ownerTag) : super(jsStream.id, ownerTag);
  final js.MediaStream jsStream;

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

  final _audioTracks = <MediaStreamTrack>[];
  final _videoTracks = <MediaStreamTrack>[];

  @override
  List<MediaStreamTrack> getAudioTracks() {
    _audioTracks.clear();
    jsStream.getAudioTracks().forEach((track) {
      _audioTracks.add(MediaStreamTrackWeb(track));
    });
    return _audioTracks;
  }

  @override
  List<MediaStreamTrack> getVideoTracks() {
    _videoTracks.clear();
    jsStream.getVideoTracks().forEach((track) {
      _videoTracks.add(MediaStreamTrackWeb(track));
    });
    return _videoTracks;
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
}
