import 'package:webrtc/WebRTC.dart';
import 'package:webrtc/RTCDataChannel.dart';
import 'package:webrtc/RTCSessionDescrption.dart';
import 'package:webrtc/MediaStream.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum RTCSignalingState {
    RTCSignalingStateStable,
    RTCSignalingStateHaveLocalOffer,
    RTCSignalingStateHaveRemoteOffer,
    RTCSignalingStateHaveLocalPranswer,
    RTCSignalingStateHaveRemotePranswer,
    RTCSignalingStateClosed
}

enum RTCIceGatheringState {
    RTCIceGatheringStateNew,
    RTCIceGatheringStateGathering,
    RTCIceGatheringStateComplete
}

enum RTCIceConnectionState {
    RTCIceConnectionStateNew,
    RTCIceConnectionStateChecking,
    RTCIceConnectionStateCompleted,
    RTCIceConnectionStateFailed,
    RTCIceConnectionStateDisconnected,
    RTCIceConnectionStateClosed
}

class Constraints {
    String key;
    String value;
    Constraints(String key, String value){
      this.key = key;
      this.value = value;
    }
}

class MediaConstraints {
  List<Constraints> mandatorys;
  List<Constraints> constraints;
}

enum IceTransportsType {
    kNone,
    kRelay,
    kNoHost,
    kAll
  }

class IceServer {
    String uri;
    List<String> urls;
    String username;
    String password;
    String hostname;
}

class RTCConfiguration {
  List<IceServer> servers;
  IceTransportsType type;
  String toString(){
    return '';
  }
}

class RTCOfferAnswerOptions {
    bool offerToReceiveVideo;
    bool offerToReceiveAudio;
}

/*
 *  PeerConnection
 */
class PeerConnection {
    int _textureId;
    MethodChannel _channel;
    StreamSubscription<dynamic> _eventSubscription;
    RTCConfiguration _configuration;
    List<MediaStream> localStreams;
    List<MediaStream> remoteStreams;
    RTCDataChannel dataChannel;

    PeerConnection(this._configuration){
      initialize();
    }

    /*
     * PeerConnection 事件监听器
     */
    void eventListener(dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'signalingState':
          break;
        case 'iceGatheringState':
          break;
        case 'iceConnectionState':
          break;
        case 'onCandidate':
          break;
        case 'onAddStream':
          break;
        case 'onRemoveStream':
          break;
        case 'onAddTrack':
          break;
        case 'onRemoveTrack':
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
    }

    void initialize() async {
      _channel = WebRTC.methodChannel();
      MediaConstraints mediaConstraints;
      final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'createPeerConnection',
      <String, dynamic>{
        'configuration': _configuration,
        'constraints': mediaConstraints
        },
      );
      _textureId = response['textureId'];
      _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    }

    Future<Null> dispose() async {
      await _eventSubscription?.cancel();
      await _channel.invokeMethod(
            'dispose',
            <String, dynamic>{'textureId': _textureId},);
    }

    EventChannel _eventChannelFor(int textureId) {
      return new EventChannel('cloudwebrtc.com/WebRTC/peerConnectoinEvent$textureId');
    }

    dynamic createOffer(MediaConstraints options) async {
      final Map<dynamic, dynamic> response = await _channel.invokeMethod('createOffer',<String, dynamic>{
        'textureId': this._textureId,
        'options': options,
        });
         if(response['error']) {
            throw response['error'];
        }
        String sdp = response['sdp'];
        String type = response['type'];
        return new RTCSessionDescrption(sdp, type);
    }

    dynamic createAnswer(MediaConstraints options) async {
        final Map<dynamic, dynamic> response = await _channel.invokeMethod('createAnswer',<String, dynamic>{
        'textureId': this._textureId,
        'options': options,
        });
        if(response['error']) {
            throw response['error'];
        }
        String sdp = response['sdp'];
        String type = response['type'];
        return new RTCSessionDescrption(sdp, type);
    }

    void addStream(MediaStream stream){
      _channel.invokeMethod('addStream',<String, dynamic>{
        'textureId': this._textureId,
        'streamId': stream.textureId(),
        });
    }

    void removeStream(MediaStream stream){
      _channel.invokeMethod('removeStream',<String, dynamic>{
        'textureId': this._textureId,
        'streamId': stream.textureId(),
        });
    }

    void setLocalDescription(RTCSessionDescrption description){
      _channel.invokeMethod('setLocalDescription',<String, dynamic>{
        'textureId': this._textureId,
        'description': description.toJSON(),
        });
    }

    void setRemoteDescription(RTCSessionDescrption description){
      _channel.invokeMethod('setRemoteDescription',<String, dynamic>{
        'textureId': this._textureId,
        'description': description.toJSON(),
        });
    }

    void getStats(track){

    }

    List<MediaStream> getLocalStreams(){
      return localStreams;
    }

    List<MediaStream> getRemoteStreams(){
      return remoteStreams;
    }

    RTCDataChannel createDataChannel(){
      return dataChannel;
    }
}
