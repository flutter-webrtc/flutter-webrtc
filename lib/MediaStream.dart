import 'package:webrtc/MediaStreamTrack.dart';
import 'package:webrtc/WebRTC.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MediaStream {
  MethodChannel _channel = WebRTC.methodChannel();
  String _streamId;
  List<MediaStreamTrack> _audioTracks;
  List<MediaStreamTrack> _videoTracks;
  MediaStream(this._streamId) {
    initialize();
  }

  void initialize() async {
    _channel = WebRTC.methodChannel();
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'mediaStreamGetTracks',
      <String, dynamic>{'streamId': _streamId},
    );
    //dynamic audioTracks = response['audioTracks'];
    //dynamic videoTracks = response['videoTracks'];
  }

  String get id => _streamId;

  @override
  Future<Null> dispose() async {
    await _channel.invokeMethod(
      'dispose',
      <String, dynamic>{'streamId': _streamId},
    );
  }

  addTrack(MediaStreamTrack track) {
    if (track.kind == 'audio')
      _audioTracks.add(track);
    else
      _videoTracks.add(track);

    _channel.invokeMethod('mediaStreamAddTrack',
        <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
  }

  removeTrack(MediaStreamTrack track) {
    if (track.kind == 'audio')
      _audioTracks.remove(track);
    else
      _videoTracks.remove(track);

    _channel.invokeMethod('mediaStreamRemoveTrack',
        <String, dynamic>{'streamId': _streamId, 'trackId': track.id});
  }

  List<MediaStreamTrack> getAudioTracks() {
    return _audioTracks;
  }

  List<MediaStreamTrack> getVideoTracks() {
    return _videoTracks;
  }
}
