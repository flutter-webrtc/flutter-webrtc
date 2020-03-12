import 'dart:async';
import 'package:flutter/services.dart';
import 'media_stream_track.dart';
import 'utils.dart';

class MediaStream {
  /// private:
  MethodChannel _channel = WebRTC.methodChannel();
  String _streamId;
  String _ownerTag;
  List<MediaStreamTrack> _audioTracks = new List<MediaStreamTrack>();
  List<MediaStreamTrack> _videoTracks = new List<MediaStreamTrack>();

  /// public:
  factory MediaStream.fromMap(Map<dynamic, dynamic> map) {
    MediaStream stream = new MediaStream(map['streamId'], map['ownerTag']);
    stream._setMediaTracks(map['audioTracks'], map['videoTracks']);
    return stream;
  }

  MediaStream(this._streamId, this._ownerTag);

  String get id => _streamId;

  String get ownerTag => _ownerTag;

  void setMediaTracks(List<dynamic> audioTracks, List<dynamic> videoTracks) {
    List<MediaStreamTrack> newAudioTracks = new List();
    audioTracks.forEach((track) {
      newAudioTracks.add(new MediaStreamTrack(
          track["id"], track["label"], track["kind"], track["enabled"]));
    });
    _audioTracks = newAudioTracks;

    List<MediaStreamTrack> newVideoTracks = new List();
    videoTracks.forEach((track) {
      newVideoTracks.add(new MediaStreamTrack(
          track["id"], track["label"], track["kind"], track["enabled"]));
    });
    _videoTracks = newVideoTracks;
  }

  Future<void> getMediaTracks() async {
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'mediaStreamGetTracks',
      <String, dynamic>{'streamId': _streamId},
    );
    _setMediaTracks(response['audioTracks'], response['videoTracks']);
  }

  Future<void> addTrack(MediaStreamTrack track,
      {bool addToNative = true}) async {
    if (track.kind == 'audio')
      _audioTracks.add(track);
    else
      _videoTracks.add(track);

    if (addToNative) {
      await _channel.invokeMethod('mediaStreamAddTrack',
          <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
    }
  }

  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNaitve = true}) async {
    if (track.kind == 'audio')
      _audioTracks.removeWhere((it) => it.id == track.id);
    else
      _videoTracks.removeWhere((it) => it.id == track.id);

    if (removeFromNaitve)
      await _channel.invokeMethod('mediaStreamRemoveTrack',
          <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
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

  /// private: method.
  void _setMediaTracks(List<dynamic> audioTracks, List<dynamic> videoTracks) {
    List<MediaStreamTrack> newAudioTracks = new List();
    audioTracks.forEach((trackInfo) {
      newAudioTracks.add(MediaStreamTrack.fromMap(trackInfo));
    });
    _audioTracks = newAudioTracks;
    List<MediaStreamTrack> newVideoTracks = new List();
    videoTracks.forEach((trackInfo) {
      newVideoTracks.add(MediaStreamTrack.fromMap(trackInfo));
    });
    _videoTracks = newVideoTracks;
  }
}
