import 'package:webrtc/MediaStreamTrack.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MediaStream {
  int _streamId;
  MethodChannel _channel;
  StreamSubscription<dynamic> _eventSubscription;
  List<MediaStreamTrack> _audioTracks;
  List<MediaStreamTrack> _videoTracks;
  MediaStream(this._channel, this._streamId);
  int streamId() => _streamId;

    /*
     * MediaStream 事件监听器
    */
    void eventListener(dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'addtrack':
          break;
        case 'removetrack':
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
    }

    void initialize(){
      _eventSubscription = _eventChannelFor(_streamId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    }

  @override
  Future<Null> dispose() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod(
          'dispose',
          <String, dynamic>{'mediaStreamId': _streamId},);
  }

    EventChannel _eventChannelFor(int mediaStreamId) {
      return new EventChannel('cloudwebrtc.com/WebRTC/peerConnectoinEvent$mediaStreamId');
    }

  addTrack(MediaStreamTrack track){
    if(track.kind == 'audio')
      _audioTracks.add(track);
    else
      _videoTracks.add(track);
  }

  removeTrack(MediaStreamTrack track){
    if(track.kind == 'audio')
      _audioTracks.remove(track);
    else
     _videoTracks.remove(track);
  }

  List<MediaStreamTrack> getAudioTracks(){
      return _audioTracks;
  }

  List<MediaStreamTrack> getVideoTracks(){
      return _videoTracks;
  }

}
