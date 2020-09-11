import 'dart:async';
import 'package:flutter/services.dart';
import 'media_stream_track.dart';
import 'utils.dart';

class MediaStream {
  MediaStream(this._streamId, this._ownerTag);
  final MethodChannel _channel = WebRTC.methodChannel();
  final String _streamId;
  final String _ownerTag;
  final _audioTracks = <MediaStreamTrack>[];
  final _videoTracks = <MediaStreamTrack>[];
  String get ownerTag => _ownerTag;
  String get id => _streamId;

  void setMediaTracks(List<dynamic> audioTracks, List<dynamic> videoTracks) {
    _audioTracks.clear();
    audioTracks.forEach((track) {
      _audioTracks.add(MediaStreamTrack(
          track['id'], track['label'], track['kind'], track['enabled']));
    });

    _videoTracks.clear();
    videoTracks.forEach((track) {
      _videoTracks.add(MediaStreamTrack(
          track['id'], track['label'], track['kind'], track['enabled']));
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
