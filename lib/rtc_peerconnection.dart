import 'dart:async';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_data_channel.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_report.dart';
import 'utils.dart';


enum RTCSignalingState {
  RTCSignalingStateStable,
  RTCSignalingStateHaveLocalOffer,
  RTCSignalingStateHaveRemoteOffer,
  RTCSignalingStateHaveLocalPrAnswer,
  RTCSignalingStateHaveRemotePrAnswer,
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
  RTCIceConnectionStateConnected,
  RTCIceConnectionStateCount,
  RTCIceConnectionStateFailed,
  RTCIceConnectionStateDisconnected,
  RTCIceConnectionStateClosed,
}

/*
 * 回调类型定义.
 */
typedef void SignalingStateCallback(RTCSignalingState state);
typedef void IceGatheringStateCallback(RTCIceGatheringState state);
typedef void IceConnectionStateCallback(RTCIceConnectionState state);
typedef void IceCandidateCallback(RTCIceCandidate candidate);
typedef void AddStreamCallback(MediaStream stream);
typedef void RemoveStreamCallback(MediaStream stream);
typedef void AddTrackCallback(MediaStream stream, MediaStreamTrack track);
typedef void RemoveTrackCallback(MediaStream stream, MediaStreamTrack track);
typedef void RTCDataChannelCallback(RTCDataChannel channel);

/*
 *  PeerConnection
 */
class RTCPeerConnection {
  // private:
  String _peerConnectionId;
  MethodChannel _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;
  List<MediaStream> _localStreams;
  List<MediaStream> _remoteStreams;
  RTCDataChannel _dataChannel;

  // public: delegate
  SignalingStateCallback onSignalingState;
  IceGatheringStateCallback onIceGatheringState;
  IceConnectionStateCallback onIceConnectionState;
  IceCandidateCallback onIceCandidate;
  AddStreamCallback onAddStream;
  RemoveStreamCallback onRemoveStream;
  AddTrackCallback onAddTrack;
  RemoveTrackCallback onRemoveTrack;
  RTCDataChannelCallback onDataChannel;
  dynamic onRenegotiationNeeded;

  final Map<String, dynamic> defaultSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  RTCPeerConnection(this._peerConnectionId) {
    _eventSubscription = _eventChannelFor(_peerConnectionId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  /*
   * PeerConnection event listener.
   */
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;

    switch (map['event']) {
      case 'signalingState':
        String state = map['state'];
        if (this.onSignalingState != null)
          this.onSignalingState(signalingStateForString(state));
        break;
      case 'iceGatheringState':
        String state = map['state'];
        if (this.onIceGatheringState != null)
          this.onIceGatheringState(iceGatheringStateforString(state));
        break;
      case 'iceConnectionState':
        String state = map['state'];
        if (this.onIceConnectionState != null)
          this.onIceConnectionState(iceConnectionStateForString(state));
        break;
      case 'onCandidate':
        Map<dynamic, dynamic> cand = map['candidate'];
        RTCIceCandidate candidate = new RTCIceCandidate(
            cand['candidate'], cand['sdpMid'], cand['sdpMLineIndex']);
        if (this.onIceCandidate != null) this.onIceCandidate(candidate);
        break;
      case 'onAddStream':
        String streamId = map['streamId'];
        MediaStream stream = new MediaStream(streamId);
        stream.setMediaTracks(map['audioTracks'], map['videoTracks']);
        if (this.onAddStream != null) this.onAddStream(stream);
        break;
      case 'onRemoveStream':
        String streamId = map['streamId'];
        MediaStream stream = new MediaStream(streamId);
        if (this.onRemoveStream != null) this.onRemoveStream(stream);
        break;
      case 'onAddTrack':
        String streamId = map['streamId'];
        MediaStream stream = new MediaStream(streamId);
        Map<dynamic, dynamic> track = map['track'];
        MediaStreamTrack newTrack = new MediaStreamTrack(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        if (this.onAddTrack != null) this.onAddTrack(stream, newTrack);
        break;
      case 'onRemoveTrack':
        String streamId = map['streamId'];
        MediaStream stream = new MediaStream(streamId);
        Map<dynamic, dynamic> track = map['track'];
        MediaStreamTrack oldTrack = new MediaStreamTrack(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        if (this.onRemoveTrack != null) this.onRemoveTrack(stream, oldTrack);
        break;
      case 'didOpenDataChannel':
        int dataChannelId = map['id'];
        String label = map['label'];
        _dataChannel =
            new RTCDataChannel(this._peerConnectionId, label, dataChannelId);
        if (this.onDataChannel != null) this.onDataChannel(_dataChannel);
        break;
      case 'onRenegotiationNeeded':
        if (this.onRenegotiationNeeded != null) this.onRenegotiationNeeded();
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  Future<Null> dispose() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod(
      'peerConnectionDispose',
      <String, dynamic>{'peerConnectionId': _peerConnectionId},
    );
  }

  EventChannel _eventChannelFor(String peerConnectionId) {
    return new EventChannel(
        'cloudwebrtc.com/WebRTC/peerConnectoinEvent$peerConnectionId');
  }

  Future<RTCSessionDescription> createOffer(
      Map<String, dynamic> constraints) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('createOffer', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'constraints':
            constraints.length == 0 ? defaultSdpConstraints : constraints,
      });

      String sdp = response['sdp'];
      String type = response['type'];
      return new RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createOffer: ${e.message}';
    }
  }

  Future<RTCSessionDescription> createAnswer(
      Map<String, dynamic> constraints) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('createAnswer', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'constraints':
            constraints.length == 0 ? defaultSdpConstraints : constraints,
      });
      String sdp = response['sdp'];
      String type = response['type'];
      return new RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createAnswer: ${e.message}';
    }
  }

  void addStream(MediaStream stream) {
    _channel.invokeMethod('addStream', <String, dynamic>{
      'peerConnectionId': this._peerConnectionId,
      'streamId': stream.id,
    });
  }

  void removeStream(MediaStream stream) {
    _channel.invokeMethod('removeStream', <String, dynamic>{
      'peerConnectionId': this._peerConnectionId,
      'streamId': stream.id,
    });
  }

  Future<void> setLocalDescription(RTCSessionDescription description) async {
    try {
      await _channel.invokeMethod('setLocalDescription', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'description': description.toMap(),
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setLocalDescription: ${e.message}';
    }
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    try {
      await _channel.invokeMethod('setRemoteDescription', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'description': description.toMap(),
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setRemoteDescription: ${e.message}';
    }
  }

  void addCandidate(RTCIceCandidate candidate) {
    _channel.invokeMethod('addCandidate', <String, dynamic>{
      'peerConnectionId': this._peerConnectionId,
      'candidate': candidate.toMap(),
    });
  }

  Future<List<StatsReport>> getStats(MediaStreamTrack track) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('getStats', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'track': track != null ? track.id : null
      });
      List<StatsReport> stats = new List<StatsReport>();
      if(response != null){
        List<dynamic> reports = response['stats'];
        reports.forEach((report){
         stats.add(new StatsReport(report['id'], report['type'], report['timestamp'], report['values']));
       });
      }
      return stats;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getStats: ${e.message}';
    }
  }

  List<MediaStream> getLocalStreams() {
    return _localStreams;
  }

  List<MediaStream> getRemoteStreams() {
    return _remoteStreams;
  }

  Future<RTCDataChannel> createDataChannel(
      String label, RTCDataChannelInit dataChannelDict) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('createDataChannel', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'label': label,
        'dataChannelDict': dataChannelDict.toMap()
      });
      _dataChannel =
          new RTCDataChannel(this._peerConnectionId, label, dataChannelDict.id);
      return _dataChannel;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createDataChannel: ${e.message}';
    }
  }

  Future<Null> close() async {
    try {
      await _channel.invokeMethod('peerConnectionClose', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::close: ${e.message}';
    }
  }
}
