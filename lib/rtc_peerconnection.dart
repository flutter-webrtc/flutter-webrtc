import 'dart:async';
import 'package:flutter/services.dart';

import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_data_channel.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_report.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_rtp_transceiver.dart';
import 'utils.dart';

/// Signaling state for Peerconnection .
enum RTCSignalingState {
  RTCSignalingStateStable,
  RTCSignalingStateHaveLocalOffer,
  RTCSignalingStateHaveRemoteOffer,
  RTCSignalingStateHaveLocalPrAnswer,
  RTCSignalingStateHaveRemotePrAnswer,
  RTCSignalingStateClosed
}

/// State for ice candidate gathering.
enum RTCIceGatheringState {
  RTCIceGatheringStateNew,
  RTCIceGatheringStateGathering,
  RTCIceGatheringStateComplete
}

/// State for ice negotiation.
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

///Delegate for PeerConnection.
typedef void SignalingStateCallback(RTCSignalingState state);
typedef void IceGatheringStateCallback(RTCIceGatheringState state);
typedef void IceConnectionStateCallback(RTCIceConnectionState state);
typedef void IceCandidateCallback(RTCIceCandidate candidate);
typedef void AddStreamCallback(MediaStream stream);
typedef void RemoveStreamCallback(MediaStream stream);
typedef void AddTrackCallback(MediaStream stream, MediaStreamTrack track);
typedef void RemoveTrackCallback(MediaStream stream, MediaStreamTrack track);
typedef void RTCDataChannelCallback(RTCDataChannel channel);

/// Unified-Plan
typedef void OnAddTrackCallback(
    RTCRtpReceiver receiver, List<MediaStream> mediaStreams);
typedef void OnTrackCallback(RTCRtpTransceiver transceiver);

/// PeerConnection
class RTCPeerConnection {
  /// private:
  String _peerConnectionId;
  MethodChannel _channel = WebRTC.methodChannel();
  StreamSubscription<dynamic> _eventSubscription;
  List<MediaStream> _localStreams = new List();
  List<MediaStream> _remoteStreams = new List();
  List<RTCRtpSender> _senders = new List();
  List<RTCRtpReceiver> _receivers = new List();
  List<RTCRtpTransceiver> _transceivers = new List();
  RTCDataChannel _dataChannel;
  Map<String, dynamic> _configuration;

  /// public: delegate
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

  /// Unified-Plan
  OnAddTrackCallback onAddTrack2; //TODO:
  OnTrackCallback onTrack;

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
        RTCIceCandidate candidate = RTCIceCandidate.fromMap(map['candidate']);
        if (this.onIceCandidate != null) this.onIceCandidate(candidate);
        break;
      case 'onAddStream':
        String streamId = map['streamId'];
        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = MediaStream.fromMap(map);
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
        Map<dynamic, dynamic> trackInfo = map['track'];

        MediaStreamTrack newTrack = MediaStreamTrack.fromMap(trackInfo);
        String kind = trackInfo["kind"];

        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = new MediaStream(streamId);
          _remoteStreams.add(newStream);
          return newStream;
        });

        List<MediaStreamTrack> oldTracks = (kind == 'audio')
            ? stream.getAudioTracks()
            : stream.getVideoTracks();
        MediaStreamTrack oldTrack = oldTracks.length > 0 ? oldTracks[0] : null;
        if (oldTrack != null) {
          stream.removeTrack(oldTrack, removeFromNaitve: false);
          if (this.onRemoveTrack != null) this.onRemoveTrack(stream, oldTrack);
        }

        stream.addTrack(newTrack, addToNaitve: false);
        if (this.onAddTrack != null) this.onAddTrack(stream, newTrack);
        break;
      case 'onRemoveTrack':
        String streamId = map['streamId'];
        MediaStream stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          return null;
        });
        Map<dynamic, dynamic> trackInfo = map['track'];
        MediaStreamTrack oldTrack = MediaStreamTrack.fromMap(trackInfo);
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

      /// Unified-Plan

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
      return new RTCSessionDescription(response['sdp'], response['type']);
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
      return new RTCSessionDescription(response['sdp'], response['type']);
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
      return new RTCSessionDescription(response['sdp'], response['type']);
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
      return new RTCSessionDescription(response['sdp'], response['type']);
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

  Future<List<StatsReport>> getStats([MediaStreamTrack track]) async {
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
          stats.add(StatsReport.fromMap(report));
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

  /// Unified-Plan.
  Future<RTCRtpSender> createSender(String kind, String streamId) async {
    try {
      final Map<dynamic, dynamic> response = await _channel.invokeMethod(
          'createSender', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'kind': kind,
        'streamId': streamId
      });
      RTCRtpSender sender = RTCRtpSender.fromMap(response);
      _senders.add(sender);
      return sender;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createSender: ${e.message}';
    }
  }

  List<RTCRtpSender> getSenders() {
    return _senders;
  }

  List<RTCRtpReceiver> getReceivers() {
    return _receivers;
  }

  List<RTCRtpTransceiver> getTransceivers() {
    return _transceivers;
  }

  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [List<String> streamIds]) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('addTrack', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'track': track.id,
        'streamId': streamIds
      });
      RTCRtpSender sender = RTCRtpSender.fromMap(response);
      _senders.add(sender);
      return sender;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTrack: ${e.message}';
    }
  }

  Future<void> removeTrack(RTCRtpSender sender) async {
    try {
      await _channel.invokeMethod('removeTrack', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'senderId': sender.senderId
      });
      _senders.removeWhere((item) {
        return sender.senderId == item.senderId;
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::removeTrack: ${e.message}';
    }
  }

  Future<RTCRtpTransceiver> addTransceiver(MediaStreamTrack track,
      [RTCRtpTransceiverInit init]) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('addTransceiver', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'track': track.id,
        'init': init.toMap()
      });
      RTCRtpTransceiver transceiver = RTCRtpTransceiver.fromMap(response);
      _transceivers.add(transceiver);
      return transceiver;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTransceiver: ${e.message}';
    }
  }

  Future<RTCRtpTransceiver> addTransceiverOfType(RTCRtpMediaType mediaType,
      [RTCRtpTransceiverInit init]) async {
    try {
      final Map<dynamic, dynamic> response =
          await _channel.invokeMethod('addTransceiverOfType', <String, dynamic>{
        'peerConnectionId': this._peerConnectionId,
        'mediaType': mediaType,
        'init': init.toMap()
      });
      RTCRtpTransceiver transceiver = RTCRtpTransceiver.fromMap(response);
      _transceivers.add(transceiver);
      return transceiver;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTransceiver: ${e.message}';
    }
  }
}
