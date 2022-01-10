import 'dart:async';

import 'package:flutter/services.dart';

import '../interface/enums.dart';
import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
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
  Map<String, dynamic> _configuration;
  RTCSignalingState? _signalingState;
  RTCIceGatheringState? _iceGatheringState;
  RTCIceConnectionState? _iceConnectionState;
  RTCPeerConnectionState? _connectionState;
  final List<RTCRtpTransceiver> _transceivers = [];

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
  RTCIceGatheringState? get iceGatheringState => _iceGatheringState;

  @override
  RTCIceConnectionState? get iceConnectionState => _iceConnectionState;

  @override
  RTCPeerConnectionState? get connectionState => _connectionState;

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
      case 'onRenegotiationNeeded':
        onRenegotiationNeeded?.call();
        break;
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
            track: MediaStreamTrackNative.fromMap(map['track']),
            transceiver: transceiver));
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
  Future<void> setLocalDescription(RTCSessionDescription description) async {
    try {
      await WebRTC.invokeMethod('setLocalDescription', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'description': description.toMap(),
      });
      for (var transceiver in _transceivers) {
        await transceiver.sync();
      }
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
      for (var transceiver in _transceivers) {
        await transceiver.sync();
      }
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
    await WebRTC.invokeMethod('addCandidate', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'candidate': candidate.toMap(),
    });
  }

  @override
  Future<List<StatsReport>> getStats([MediaStreamTrack? track]) async {
    try {
      final response = await WebRTC.invokeMethod('getStats', <String, dynamic>{
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
  Future<void> close() async {
    try {
      await WebRTC.invokeMethod('peerConnectionClose', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::close: ${e.message}';
    }
  }

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
      var transceivers = RTCRtpTransceiverNative.fromMaps(
          response['transceivers'],
          peerConnectionId: _peerConnectionId);
      _transceivers.addAll(transceivers);
      return transceivers;
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
      var transceiver = RTCRtpTransceiverNative.fromMap(response,
          peerConnectionId: _peerConnectionId);
      _transceivers.add(transceiver);
      return transceiver;
    } on PlatformException catch (e) {
      throw 'Unable to RTCPeerConnection::addTransceiver: ${e.message}';
    }
  }
}
