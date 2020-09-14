import 'dart:async';

import 'package:flutter/services.dart';

import 'enums.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_data_channel.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_report.dart';
import 'utils.dart';

/*
 * Delegate for PeerConnection.
 */
typedef SignalingStateCallback = void Function(RTCSignalingState state);
typedef IceGatheringStateCallback = void Function(RTCIceGatheringState state);
typedef IceConnectionStateCallback = void Function(RTCIceConnectionState state);
typedef IceCandidateCallback = void Function(RTCIceCandidate candidate);
typedef AddStreamCallback = void Function(MediaStream stream);
typedef RemoveStreamCallback = void Function(MediaStream stream);
typedef AddTrackCallback = void Function(
    MediaStream stream, MediaStreamTrack track);
typedef RemoveTrackCallback = void Function(
    MediaStream stream, MediaStreamTrack track);
typedef RTCDataChannelCallback = void Function(RTCDataChannel channel);
typedef RenegotiationNeededCallback = void Function();

/*
 *  PeerConnection
 */
class RTCPeerConnection {
  RTCPeerConnection(this._peerConnectionId, this._configuration) {
    _eventSubscription = _eventChannelFor(_peerConnectionId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  // private:
  final String _peerConnectionId;
  final _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;
  final _localStreams = <MediaStream>[];
  final _remoteStreams = <MediaStream>[];
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
  RenegotiationNeededCallback onRenegotiationNeeded;

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

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
        onSignalingState?.call(_signalingState);
        break;
      case 'iceGatheringState':
        _iceGatheringState = iceGatheringStateforString(map['state']);
        onIceGatheringState?.call(_iceGatheringState);
        break;
      case 'iceConnectionState':
        _iceConnectionState = iceConnectionStateForString(map['state']);
        onIceConnectionState?.call(_iceConnectionState);
        break;
      case 'onCandidate':
        Map<dynamic, dynamic> cand = map['candidate'];
        var candidate = RTCIceCandidate(
            cand['candidate'], cand['sdpMid'], cand['sdpMLineIndex']);
        onIceCandidate?.call(candidate);
        break;
      case 'onAddStream':
        String streamId = map['streamId'];

        var stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = MediaStream(streamId, _peerConnectionId);
          newStream.setMediaTracks(map['audioTracks'], map['videoTracks']);
          return newStream;
        });

        onAddStream?.call(stream);
        _remoteStreams.add(stream);
        break;
      case 'onRemoveStream':
        String streamId = map['streamId'];
        var stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          return null;
        });
        onRemoveStream?.call(stream);
        _remoteStreams.removeWhere((it) => it.id == streamId);
        break;
      case 'onAddTrack':
        String streamId = map['streamId'];
        Map<dynamic, dynamic> track = map['track'];

        var newTrack = MediaStreamTrack(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        String kind = track['kind'];

        var stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = MediaStream(streamId, _peerConnectionId);
          _remoteStreams.add(newStream);
          return newStream;
        });

        var oldTracks = (kind == 'audio')
            ? stream.getAudioTracks()
            : stream.getVideoTracks();
        var oldTrack = oldTracks.isNotEmpty ? oldTracks[0] : null;
        if (oldTrack != null) {
          stream.removeTrack(oldTrack, removeFromNative: false);
          onRemoveTrack?.call(stream, oldTrack);
        }

        stream.addTrack(newTrack, addToNative: false);
        onAddTrack?.call(stream, newTrack);
        break;
      case 'onRemoveTrack':
        String streamId = map['streamId'];
        var stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          return null;
        });
        Map<dynamic, dynamic> track = map['track'];
        var oldTrack = MediaStreamTrack(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        onRemoveTrack?.call(stream, oldTrack);
        break;
      case 'didOpenDataChannel':
        int dataChannelId = map['id'];
        String label = map['label'];
        _dataChannel = RTCDataChannel(_peerConnectionId, label, dataChannelId);
        onDataChannel?.call(_dataChannel);
        break;
      case 'onRenegotiationNeeded':
        onRenegotiationNeeded?.call();
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
    return EventChannel('FlutterWebRTC/peerConnectoinEvent$peerConnectionId');
  }

  Map<String, dynamic> get getConfiguration => _configuration;

  Future<void> setConfiguration(Map<String, dynamic> configuration) async {
    _configuration = configuration;
    try {
      await _channel.invokeMethod('setConfiguration', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'configuration': configuration,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setConfiguration: ${e.message}';
    }
  }

  Future<RTCSessionDescription> createOffer(
      [Map<String, dynamic> constraints = const {}]) async {
    try {
      final response = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('createOffer', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'constraints':
            constraints.isEmpty ? defaultSdpConstraints : constraints,
      });

      String sdp = response['sdp'];
      String type = response['type'];
      return RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createOffer: ${e.message}';
    }
  }

  Future<RTCSessionDescription> createAnswer(
      Map<String, dynamic> constraints) async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'createAnswer', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'constraints':
            constraints.isEmpty ? defaultSdpConstraints : constraints,
      });
      String sdp = response['sdp'];
      String type = response['type'];
      return RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createAnswer: ${e.message}';
    }
  }

  Future<void> addStream(MediaStream stream) async {
    _localStreams.add(stream);
    await _channel.invokeMethod('addStream', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'streamId': stream.id,
    });
  }

  Future<void> removeStream(MediaStream stream) async {
    _localStreams.removeWhere((it) => it.id == stream.id);
    await _channel.invokeMethod('removeStream', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'streamId': stream.id,
    });
  }

  Future<void> setLocalDescription(RTCSessionDescription description) async {
    try {
      await _channel.invokeMethod('setLocalDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'description': description.toMap(),
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setLocalDescription: ${e.message}';
    }
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    try {
      await _channel.invokeMethod('setRemoteDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'description': description.toMap(),
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setRemoteDescription: ${e.message}';
    }
  }

  Future<RTCSessionDescription> getLocalDescription() async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getLocalDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
      String sdp = response['sdp'];
      String type = response['type'];
      return RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getLocalDescription: ${e.message}';
    }
  }

  Future<RTCSessionDescription> getRemoteDescription() async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getRemoteDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
      String sdp = response['sdp'];
      String type = response['type'];
      return RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getRemoteDescription: ${e.message}';
    }
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _channel.invokeMethod('addCandidate', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'candidate': candidate.toMap(),
    });
  }

  Future<List<StatsReport>> getStats([MediaStreamTrack track]) async {
    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'getStats', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'track': track != null ? track.id : null
      });
      var stats = <StatsReport>[];
      if (response != null) {
        List<dynamic> reports = response['stats'];
        reports.forEach((report) {
          stats.add(StatsReport(report['id'], report['type'],
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
      await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'createDataChannel', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'label': label,
        'dataChannelDict': dataChannelDict.toMap()
      });
      _dataChannel =
          RTCDataChannel(_peerConnectionId, label, dataChannelDict.id);
      return _dataChannel;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createDataChannel: ${e.message}';
    }
  }

  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    return RTCDTMFSender(_peerConnectionId);
  }

  Future<Null> close() async {
    try {
      await _channel.invokeMethod('peerConnectionClose', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::close: ${e.message}';
    }
  }
}
