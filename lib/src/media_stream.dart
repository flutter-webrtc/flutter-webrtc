import 'dart:async';

import 'media_stream_track.dart';
import 'utils.dart';

typedef MediaTrackCallback = void Function(MediaStreamTrack track);

class MediaStream {
  MediaStream(this._streamId, this._ownerTag);
  factory MediaStream.fromMap(Map<dynamic, dynamic> map) {
    return MediaStream(map['streamId'], map['ownerTag'])
      ..setMediaTracks(map['audioTracks'], map['videoTracks']);
  }
  final _channel = WebRTC.methodChannel();
  final String _streamId;
  final String _ownerTag;
  final _audioTracks = <MediaStreamTrack>[];
  final _videoTracks = <MediaStreamTrack>[];
  String get ownerTag => _ownerTag;
  String get id => _streamId;
  MediaTrackCallback onAddTrack;
  MediaTrackCallback onRemoveTrack;

  void setMediaTracks(List<dynamic> audioTracks, List<dynamic> videoTracks) {
    _audioTracks.clear();
    audioTracks.forEach((track) {
      _audioTracks.add(MediaStreamTrack.fromMap(track));
    });

    _videoTracks.clear();
    videoTracks.forEach((track) {
      _videoTracks.add(MediaStreamTrack.fromMap(track));
    });
  }

  Future<void> getMediaTracks() async {
    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'mediaStreamGetTracks',
      <String, dynamic>{'streamId': _streamId},
    );

    setMediaTracks(response['audioTracks'], response['videoTracks']);
  }

  Future<void> addTrack(MediaStreamTrack track,
      {bool addToNative = true}) async {
    if (track.kind == 'audio') {
      _audioTracks.add(track);
    } else {
      _videoTracks.add(track);
    }

    if (addToNative) {
      await _channel.invokeMethod('mediaStreamAddTrack',
          <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
    }
  }

  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNative = true}) async {
    if (track.kind == 'audio') {
      _audioTracks.removeWhere((it) => it.id == track.id);
    } else {
      _videoTracks.removeWhere((it) => it.id == track.id);
    }

    if (removeFromNative) {
      await _channel.invokeMethod('mediaStreamRemoveTrack',
          <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
    }
  }

  List<MediaStreamTrack> getTracks() {
    return <MediaStreamTrack>[..._audioTracks, ..._videoTracks];
  }

  List<MediaStreamTrack> getAudioTracks() {
    return _audioTracks;
  }

  List<MediaStreamTrack> getVideoTracks() {
    return _videoTracks;
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod(
      'streamDispose',
      <String, dynamic>{'streamId': _streamId},
    );
  }
}
