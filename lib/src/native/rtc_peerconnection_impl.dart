import 'dart:async';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

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
  StreamSubscription<dynamic>? _eventSubscription;
  final _localStreams = <MediaStream>[];
  final _remoteStreams = <MediaStream>[];
  RTCDataChannelNative? _dataChannel;
  Map<String, dynamic> _configuration;
  RTCSignalingState? _signalingState;
  RTCIceGatheringState? _iceGatheringState;
  RTCIceConnectionState? _iceConnectionState;
  RTCPeerConnectionState? _connectionState;

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  @override
  RTCSignalingState? get signalingState => _signalingState;

  @override
  Future<RTCSignalingState?> getSignalingState() async {
    try {
      final response =
          await WebRTC.invokeMethod('getSignalingState', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });

      if (null == response) {
        return null;
      }
      _signalingState = signalingStateForString(response['state']);
      return _signalingState;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getSignalingState: ${e.message}';
    }
  }

  @override
  RTCIceGatheringState? get iceGatheringState => _iceGatheringState;

  @override
  Future<RTCIceGatheringState?> getIceGatheringState() async {
    try {
      final response =
          await WebRTC.invokeMethod('getIceGatheringState', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });

      if (null == response) {
        return null;
      }
      _iceGatheringState = iceGatheringStateforString(response['state']);
      return _iceGatheringState;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getIceGatheringState: ${e.message}';
    }
  }

  @override
  RTCIceConnectionState? get iceConnectionState => _iceConnectionState;

  @override
  Future<RTCIceConnectionState?> getIceConnectionState() async {
    try {
      final response =
          await WebRTC.invokeMethod('getIceConnectionState', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });

      if (null == response) {
        return null;
      }
      _iceConnectionState = iceConnectionStateForString(response['state']);
      return _iceConnectionState;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getIceConnectionState: ${e.message}';
    }
  }

  @override
  RTCPeerConnectionState? get connectionState => _connectionState;

  @override
  Future<RTCPeerConnectionState?> getConnectionState() async {
    try {
      final response =
          await WebRTC.invokeMethod('getConnectionState', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });

      if (null == response) {
        return null;
      }
      _connectionState = peerConnectionStateForString(response['state']);
      return _connectionState;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getConnectionState: ${e.message}';
    }
  }

  Future<RTCSessionDescription?> get localDescription => getLocalDescription();

  Future<RTCSessionDescription?> get remoteDescription =>
      getRemoteDescription();

  /*
   * PeerConnection event listener.
   */
  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;

    switch (map['event']) {
      case 'signalingState':
        _signalingState = signalingStateForString(map['state']);
        onSignalingState?.call(_signalingState!);
        break;
      case 'peerConnectionState':
        _connectionState = peerConnectionStateForString(map['state']);
        onConnectionState?.call(_connectionState!);
        break;
      case 'iceGatheringState':
        _iceGatheringState = iceGatheringStateforString(map['state']);
        onIceGatheringState?.call(_iceGatheringState!);
        break;
      case 'iceConnectionState':
        _iceConnectionState = iceConnectionStateForString(map['state']);
        onIceConnectionState?.call(_iceConnectionState!);
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

        for (var item in _remoteStreams) {
          if (item.id == streamId) {
            onRemoveStream?.call(item);
            break;
          }
        }
        _remoteStreams.removeWhere((it) => it.id == streamId);
        break;
      case 'onAddTrack':
        String streamId = map['streamId'];
        Map<dynamic, dynamic> track = map['track'];

        var newTrack = MediaStreamTrackNative(
            track['id'],
            track['label'],
            track['kind'],
            track['enabled'],
            _peerConnectionId,
            track['settings'] ?? {});
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
        String trackId = map['trackId'];
        for (var stream in _remoteStreams) {
          stream.getTracks().forEach((track) {
            if (track.id == trackId) {
              onRemoveTrack?.call(stream, track);
              stream.removeTrack(track, removeFromNative: false);
              return;
            }
          });
        }
        break;
      case 'didOpenDataChannel':
        int dataChannelId = map['id'];
        String label = map['label'];
        String flutterId = map['flutterId'];
        _dataChannel = RTCDataChannelNative(
            _peerConnectionId, label, dataChannelId, flutterId,
            state: RTCDataChannelState.RTCDataChannelOpen);
        onDataChannel?.call(_dataChannel!);
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
            receiver: RTCRtpReceiverNative.fromMap(map['receiver'],
                peerConnectionId: _peerConnectionId),
            streams: streams,
            track:
                MediaStreamTrackNative.fromMap(map['track'], _peerConnectionId),
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
    if (obj is Exception) throw obj;
  }

  @override
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await WebRTC.invokeMethod(
      'peerConnectionDispose',
      <String, dynamic>{'peerConnectionId': _peerConnectionId},
    );
  }

  EventChannel _eventChannelFor(String peerConnectionId) {
    return EventChannel('FlutterWebRTC/peerConnectionEvent$peerConnectionId');
  }

  @override
  Map<String, dynamic> get getConfiguration => _configuration;

  @override
  Future<void> setConfiguration(Map<String, dynamic> configuration) async {
    _configuration = configuration;
    try {
      await WebRTC.invokeMethod('setConfiguration', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'configuration': configuration,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setConfiguration: ${e.message}';
    }
  }

  @override
  Future<RTCSessionDescription> createOffer(
      [Map<String, dynamic>? constraints]) async {
    try {
      final response =
          await WebRTC.invokeMethod('createOffer', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'constraints': constraints ?? defaultSdpConstraints
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
      [Map<String, dynamic>? constraints]) async {
    try {
      final response =
          await WebRTC.invokeMethod('createAnswer', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'constraints': constraints ?? defaultSdpConstraints
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
    await WebRTC.invokeMethod('addStream', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'streamId': stream.id,
    });
  }

  @override
  Future<void> removeStream(MediaStream stream) async {
    _localStreams.removeWhere((it) => it.id == stream.id);
    await WebRTC.invokeMethod('removeStream', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'streamId': stream.id,
    });
  }

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {
    try {
      await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
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
      await WebRTC.invokeMethod('setRemoteDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'description': description.toMap(),
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::setRemoteDescription: ${e.message}';
    }
  }

  @override
  Future<RTCSessionDescription?> getLocalDescription() async {
    try {
      final response =
          await WebRTC.invokeMethod('getLocalDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });

      if (null == response) {
        return null;
      }
      String sdp = response['sdp'];
      String type = response['type'];
      return RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getLocalDescription: ${e.message}';
    }
  }

  @override
  Future<RTCSessionDescription?> getRemoteDescription() async {
    try {
      final response =
          await WebRTC.invokeMethod('getRemoteDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });

      if (null == response) {
        return null;
      }
      String sdp = response['sdp'];
      String type = response['type'];
      return RTCSessionDescription(sdp, type);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::getRemoteDescription: ${e.message}';
    }
  }

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    try {
      await WebRTC.invokeMethod('addCandidate', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'candidate': candidate.toMap(),
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addCandidate: ${e.message}';
    }
  }

  @override
  Future<List<StatsReport>> getStats([MediaStreamTrack? track]) async {
    try {
      final response = await WebRTC.invokeMethod('getStats', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'trackId': track?.id
      });

      var stats = <StatsReport>[];
      if (response != null) {
        List<dynamic> reports = response['stats'];
        for (var report in reports) {
          stats.add(StatsReport(report['id'], report['type'],
              (report['timestamp'] as num).toDouble(), report['values']));
        }
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
      final response =
          await WebRTC.invokeMethod('createDataChannel', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'label': label,
        'dataChannelDict': dataChannelDict.toMap()
      });

      _dataChannel = RTCDataChannelNative(
          _peerConnectionId, label, response['id'], response['flutterId']);
      return _dataChannel!;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::createDataChannel: ${e.message}';
    }
  }

  @override
  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    return RTCDTMFSenderNative(_peerConnectionId, '');
  }

  @override
  Future<void> restartIce() async {
    try {
      await WebRTC.invokeMethod('restartIce', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::resartIce: ${e.message}';
    }
  }

  @override
  Future<void> close() async {
    try {
      await WebRTC.invokeMethod('peerConnectionClose', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::close: ${e.message}';
    }
  }

  /// Unified-Plan.
  @override
  Future<List<RTCRtpSender>> getSenders() async {
    try {
      final response = await WebRTC.invokeMethod('getSenders',
          <String, dynamic>{'peerConnectionId': _peerConnectionId});
      return RTCRtpSenderNative.fromMaps(response['senders'],
          peerConnectionId: _peerConnectionId);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTrack: ${e.message}';
    }
  }

  @override
  Future<List<RTCRtpReceiver>> getReceivers() async {
    try {
      final response = await WebRTC.invokeMethod('getReceivers',
          <String, dynamic>{'peerConnectionId': _peerConnectionId});
      return RTCRtpReceiverNative.fromMaps(response['receivers'],
          peerConnectionId: _peerConnectionId);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTrack: ${e.message}';
    }
  }

  @override
  Future<List<RTCRtpTransceiver>> getTransceivers() async {
    try {
      final response = await WebRTC.invokeMethod('getTransceivers',
          <String, dynamic>{'peerConnectionId': _peerConnectionId});
      return RTCRtpTransceiverNative.fromMaps(response['transceivers'],
          peerConnectionId: _peerConnectionId);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTrack: ${e.message}';
    }
  }

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [MediaStream? stream]) async {
    try {
      final response = await WebRTC.invokeMethod('addTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'trackId': track.id,
        'streamIds': [stream?.id]
      });
      return RTCRtpSenderNative.fromMap(response,
          peerConnectionId: _peerConnectionId);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTrack: ${e.message}';
    }
  }

  @override
  Future<bool> removeTrack(RTCRtpSender sender) async {
    try {
      final response = await WebRTC.invokeMethod(
          'removeTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'senderId': sender.senderId
      });
      bool result = response['result'];

      if (result && (sender is RTCRtpSenderNative)) {
        sender.removeTrackReference();
      }

      return result;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::removeTrack: ${e.message}';
    }
  }

  @override
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack? track,
      RTCRtpMediaType? kind,
      RTCRtpTransceiverInit? init}) async {
    try {
      final response =
          await WebRTC.invokeMethod('addTransceiver', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        if (track != null) 'trackId': track.id,
        if (kind != null) 'mediaType': typeRTCRtpMediaTypetoString[kind],
        if (init != null)
          'transceiverInit': RTCRtpTransceiverInitNative.initToMap(init)
      });
      return RTCRtpTransceiverNative.fromMap(response,
          peerConnectionId: _peerConnectionId);
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTransceiver: ${e.message}';
    }
  }
}
