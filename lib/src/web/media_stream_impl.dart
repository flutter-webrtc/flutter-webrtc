import 'dart:async';

import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import 'package:dart_webrtc/dart_webrtc.dart' as js;
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

  final Map<String, MediaStreamTrack> _audioTracks = {};
  final Map<String, MediaStreamTrack> _videoTracks = {};

  @override
  List<MediaStreamTrack> getAudioTracks() {
    jsStream.getAudioTracks().forEach((jsTrack) => _audioTracks.putIfAbsent(
          jsTrack.id,
          () => MediaStreamTrackWeb(jsTrack),
        ));

    return _audioTracks.values.toList();
  }

  @override
  List<MediaStreamTrack> getVideoTracks() {
    jsStream.getVideoTracks().forEach((jsTrack) => _videoTracks.putIfAbsent(
          jsTrack.id,
          () => MediaStreamTrackWeb(jsTrack),
        ));

    return _videoTracks.values.toList();
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
