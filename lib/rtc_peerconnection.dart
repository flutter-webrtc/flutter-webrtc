import 'dart:async';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_data_channel.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_report.dart';
import 'utils.dart';
import 'enums.dart';

/*
 * Delegate for PeerConnection.
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
  List<MediaStream> _localStreams = new List();
  List<MediaStream> _remoteStreams = new List();
  RTCDataChannel _dataChannel;
  Map<String, dynamic> _configuration;
  RTCSignalingState _signalingState;
  RTCIceGatheringState _iceGatheringState;
  RTCIceConnectionState _iceConnectionState;

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

  RTCPeerConnection(this._peerConnectionId, this._configuration) {
    _eventSubscription = _eventChannelFor(_peerConnectionId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  RTCSignalingState get signalingState => _signalingState;

  RTCIceGatheringState get iceGatheringState => _iceGatheringState;

  RTCIceConnectionState get iceConnectionState => _iceConnectionState;

  /*
   * PeerConnection event listener.
   */
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;

    switch (map['event']) {
      case 'signalingState':
        _signalingState = signalingStateForString(map['state']);
        if (this.onSignalingState != null)
          this.onSignalingState(_signalingState);
        break;
      case 'iceGatheringState':
        _iceGatheringState = iceGatheringStateforString(map['state']);
        if (this.onIceGatheringState != null)
          this.onIceGatheringState(_iceGatheringState);
        break;
      case 'iceConnectionState':
        _iceConnectionState = iceConnectionStateForString(map['state']);
        if (this.onIceConnectionState != null)
          this.onIceConnectionState(_iceConnectionState);
        break;
      case 'onCandidate':
        Map<dynamic, dynamic> cand = map['candidate'];
        RTCIceCandidate candidate = new RTCIceCandidate(
            cand['candidate'], cand['sdpMid'], cand['sdpMLineIndex']);
        if (this.onIceCandidate != null) this.onIceCandidate(candidate);
        break;
      case 'onAddStream':
        String streamId = map['streamId'];

        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = new MediaStream(streamId, _peerConnectionId);
          newStream.setMediaTracks(map['audioTracks'], map['videoTracks']);
          _remoteStreams.add(newStream);
          return newStream;
        });
        if (this.onAddStream != null) this.onAddStream(stream);
        _remoteStreams.add(stream);
        break;
      case 'onRemoveStream':
        String streamId = map['streamId'];
        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          return null;
        });
        if (this.onRemoveStream != null) this.onRemoveStream(stream);
        _remoteStreams.removeWhere((it) => it.id == streamId);
        break;
      case 'onAddTrack':
        String streamId = map['streamId'];
        Map<dynamic, dynamic> track = map['track'];

        MediaStreamTrack newTrack = new MediaStreamTrack(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        String kind = track["kind"];

        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = new MediaStream(streamId, _peerConnectionId);
          _remoteStreams.add(newStream);
          return newStream;
        });

        List<MediaStreamTrack> oldTracks = (kind == 'audio')
            ? stream.getAudioTracks()
            : stream.getVideoTracks();
        MediaStreamTrack oldTrack = oldTracks.length > 0 ? oldTracks[0] : null;
        if (oldTrack != null) {
          stream.removeTrack(oldTrack, removeFromNative: false);
          if (this.onRemoveTrack != null) this.onRemoveTrack(stream, oldTrack);
        }

        stream.addTrack(newTrack, addToNative: false);
        if (this.onAddTrack != null) this.onAddTrack(stream, newTrack);
        break;
      case 'onRemoveTrack':
        String streamId = map['streamId'];
        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          return null;
        });
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

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod(
      'peerConnectionDispose',
      <String, dynamic>{'peerConnectionId': _peerConnectionId},
    );
  }

  EventChannel _eventChannelFor(String peerConnectionId) {
    return new EventChannel(
        'FlutterWebRTC/peerConnectoinEvent$peerConnectionId');
  }

  Map<String, dynamic> get getConfiguration => _configuration;

  Future<void> setConfiguration(Map<String, dynamic> configuration) async {
    _configuration = configuration;
    try {
      await _channel.invokeMethod('setConfiguration', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'configuration': configuration,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setConfiguration: ${e.message}';
    }
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

  Future<void> addStream(MediaStream stream) async {
    _localStreams.add(stream);
    await _channel.invokeMethod('addStream', <String, dynamic>{
      'peerConnectionId': this._peerConnectionId,
      'streamId': stream.id,
    });
  }

  Future<void> removeStream(MediaStream stream) async {
    _localStreams.removeWhere((it) => it.id == stream.id);
    await _channel.invokeMethod('removeStream', <String, dynamic>{
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

  Future<RTCSessionDescription> getLocalDescription() async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('getLocalDescription', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
      });
      String sdp = response['sdp'];
      String type = response['type'];
      return new RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getLocalDescription: ${e.message}';
    }
  }

  Future<RTCSessionDescription> getRemoteDescription() async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('getRemoteDescription', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
      });
      String sdp = response['sdp'];
      String type = response['type'];
      return new RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getRemoteDescription: ${e.message}';
    }
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _channel.invokeMethod('addCandidate', <String, dynamic>{
      'peerConnectionId': this._peerConnectionId,
      'candidate': candidate.toMap(),
    });
  }

  Future<List<StatsReport>> getStats([MediaStreamTrack track = null]) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('getStats', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'track': track != null ? track.id : null
      });
      List<StatsReport> stats = new List<StatsReport>();
      if (response != null) {
        List<dynamic> reports = response['stats'];
        reports.forEach((report) {
          stats.add(new StatsReport(report['id'], report['type'],
              report['timestamp'], report['values']));
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
