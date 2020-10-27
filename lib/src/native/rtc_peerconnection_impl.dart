import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/enums.dart';
import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import '../interface/rtc_data_channel.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_ice_candidate.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_rtp_receiver.dart';
import '../interface/rtc_rtp_sender.dart';
import '../interface/rtc_rtp_transceiver.dart';
import '../interface/rtc_session_description.dart';
import '../interface/rtc_stats_report.dart';
import '../interface/rtc_track_event.dart';
import 'media_stream_impl.dart';
import 'media_stream_track_impl.dart';
import 'rtc_data_channel_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';
import 'utils.dart';

/*
 *  PeerConnection
 */
class RTCPeerConnectionNative extends RTCPeerConnection {
  RTCPeerConnectionNative(this._peerConnectionId, this._configuration) {
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
  final List<RTCRtpSender> _senders = <RTCRtpSender>[];
  final List<RTCRtpReceiver> _receivers = <RTCRtpReceiver>[];
  final List<RTCRtpTransceiver> _transceivers = <RTCRtpTransceiver>[];
  RTCDataChannelNative _dataChannel;
  Map<String, dynamic> _configuration;
  RTCSignalingState _signalingState;
  RTCIceGatheringState _iceGatheringState;
  RTCIceConnectionState _iceConnectionState;
  RTCPeerConnectionState _connectionState;

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  @override
  RTCSignalingState get signalingState => _signalingState;

  @override
  RTCIceGatheringState get iceGatheringState => _iceGatheringState;

  @override
  RTCIceConnectionState get iceConnectionState => _iceConnectionState;

  @override
  RTCPeerConnectionState get connectionState => _connectionState;

  Future<RTCSessionDescription> get localDescription => getLocalDescription();

  Future<RTCSessionDescription> get remoteDescription => getRemoteDescription();

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
      case 'peerConnectionState':
        _connectionState = peerConnectionStateForString(map['state']);
        onConnectionState?.call(_connectionState);
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
          var newStream = MediaStreamNative(streamId, _peerConnectionId);
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

        var newTrack = MediaStreamTrackNative(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        String kind = track['kind'];

        var stream =
            _remoteStreams.firstWhere((it) => it.id == streamId, orElse: () {
          var newStream = MediaStreamNative(streamId, _peerConnectionId);
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
        var oldTrack = MediaStreamTrackNative(
            map['trackId'], track['label'], track['kind'], track['enabled']);
        onRemoveTrack?.call(stream, oldTrack);
        break;
      case 'didOpenDataChannel':
        int dataChannelId = map['id'];
        String label = map['label'];
        _dataChannel =
            RTCDataChannelNative(_peerConnectionId, label, dataChannelId);
        onDataChannel?.call(_dataChannel);
        break;
      case 'onRenegotiationNeeded':
        onRenegotiationNeeded?.call();
        break;

      /// Unified-Plan
      case 'onTrack':
        var params = map['streams'] as List<dynamic>;
        var streams = params.map((e) => MediaStreamNative.fromMap(e)).toList();
        var transceiver = map['transceiver'] != null
            ? RTCRtpTransceiverNative.fromMap(map['transceiver'],
                peerConnectionId: _peerConnectionId)
            : null;
        onTrack?.call(RTCTrackEvent(
            receiver: RTCRtpReceiverNative.fromMap(map['receiver']),
            streams: streams,
            track: MediaStreamTrackNative.fromMap(map['track']),
            transceiver: transceiver));
        break;

      /// Other
      case 'onSelectedCandidatePairChanged':

        /// class RTCIceCandidatePair {
        ///   RTCIceCandidatePair(this.local, this.remote, this.lastReceivedMs, this.reason);
        ///   factory RTCIceCandidatePair.fromMap(Map<dynamic, dynamic> map) {
        ///      return RTCIceCandidatePair(
        ///             RTCIceCandidate.fromMap(map['local']),
        ///             RTCIceCandidate.fromMap(map['remote']),
        ///             map['lastReceivedMs'],
        ///             map['reason']);
        ///   }
        ///   RTCIceCandidate local;
        ///   RTCIceCandidate remote;
        ///   int lastReceivedMs;
        ///   String reason;
        /// }
        ///
        /// typedef SelectedCandidatePairChangedCallback = void Function(RTCIceCandidatePair pair);
        /// SelectedCandidatePairChangedCallback onSelectedCandidatePairChanged;
        ///
        /// RTCIceCandidatePair iceCandidatePair = RTCIceCandidatePair.fromMap(map);
        /// onSelectedCandidatePairChanged?.call(iceCandidatePair);

        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  @override
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

  @override
  Map<String, dynamic> get getConfiguration => _configuration;

  @override
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

  @override
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

  @override
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

  @override
  Future<void> addStream(MediaStream stream) async {
    _localStreams.add(stream);
    await _channel.invokeMethod('addStream', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'streamId': stream.id,
    });
  }

  @override
  Future<void> removeStream(MediaStream stream) async {
    _localStreams.removeWhere((it) => it.id == stream.id);
    await _channel.invokeMethod('removeStream', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'streamId': stream.id,
    });
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _channel.invokeMethod('addCandidate', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'candidate': candidate.toMap(),
    });
  }

  @override
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

  @override
  List<MediaStream> getLocalStreams() {
    return _localStreams;
  }

  @override
  List<MediaStream> getRemoteStreams() {
    return _remoteStreams;
  }

  @override
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
          RTCDataChannelNative(_peerConnectionId, label, dataChannelDict.id);
      return _dataChannel;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createDataChannel: ${e.message}';
    }
  }

  @override
  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    return RTCDTMFSenderNative(_peerConnectionId, '');
  }

  @override
  Future<void> close() async {
    try {
      await _channel.invokeMethod('peerConnectionClose', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::close: ${e.message}';
    }
  }

  /// Unified-Plan.
  @override
  List<RTCRtpSender> get senders => _senders;

  @override
  List<RTCRtpReceiver> get receivers => _receivers;

  @override
  List<RTCRtpTransceiver> get transceivers => _transceivers;

  @override
  Future<RTCRtpSender> createSender(String kind, String streamId) async {
    try {
      final response = await _channel.invokeMethod(
          'createSender', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'kind': kind,
        'streamId': streamId
      });
      var sender = RTCRtpSenderNative.fromMap(response);
      _senders.add(sender);
      return sender;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createSender: ${e.message}';
    }
  }

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [List<MediaStream> streams]) async {
    try {
      final response =
          await _channel.invokeMethod('addTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'trackId': track.id,
        'streamIds': streams.map((e) => e.id).toList()
      });
      var sender = RTCRtpSenderNative.fromMap(response);
      _senders.add(sender);
      return sender;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTrack: ${e.message}';
    }
  }

  @override
  Future<bool> removeTrack(RTCRtpSender sender) async {
    try {
      final response = await _channel.invokeMethod(
          'removeTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'senderId': sender.senderId
      });
      bool result = response['result'];
      _senders.removeWhere((item) {
        return sender.senderId == item.senderId;
      });
      return result;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::removeTrack: ${e.message}';
    }
  }

  @override
  Future<bool> closeSender(RTCRtpSender sender) async {
    try {
      final response = await _channel.invokeMethod(
          'closeSender', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'senderId': sender.senderId
      });
      bool result = response['result'];
      _senders.removeWhere((item) {
        return sender.senderId == item.senderId;
      });
      return result;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::removeTrack: ${e.message}';
    }
  }

  @override
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack track,
      RTCRtpMediaType kind,
      RTCRtpTransceiverInit init}) async {
    try {
      final response =
          await _channel.invokeMethod('addTransceiver', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        if (track != null) 'trackId': track.id,
        if (kind != null) 'mediaType': typeRTCRtpMediaTypetoString[kind],
        if (init != null)
          'transceiverInit': RTCRtpTransceiverInit.initToMap(init)
      });
      var transceiver = RTCRtpTransceiverNative.fromMap(response,
          peerConnectionId: _peerConnectionId);
      _transceivers.add(transceiver);
      return transceiver;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTransceiver: ${e.message}';
    }
  }
}
