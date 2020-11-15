import 'dart:async';
import 'dart:js';
import 'package:dart_webrtc/dart_webrtc.dart' as dart_webrtc;

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
import 'media_stream_impl.dart';
import 'media_stream_track_impl.dart';
import 'rtc_data_channel_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';
import 'rtc_track_event_impl.dart';

dart_webrtc.RTCConfiguration rtcConfigurationFromMap(Map<String, dynamic> map) {
  return dart_webrtc.RTCConfiguration(
      iceServers: (map['iceServers'] as List)
          .map((e) => dart_webrtc.RTCIceServer(
              urls: e['urls'] ?? e['url'],
              username: e['username'],
              credential: e['credential']))
          .toList(),
      iceTransportPolicy: map['iceTransportPolicy'] ?? 'all',
      bundlePolicy: map['bundlePolicy'] ?? 'max-compat',
      peerIdentity: map['peerIdentity'],
      iceCandidatePoolSize: map['iceCandidatePoolSize'],
      sdpSemantics: map['sdpSemantics'] ?? 'unified-plan');
}

Map<String, dynamic> rtcConfigurationToMap(
    dart_webrtc.RTCConfiguration configuration) {
  return {
    'iceServers': configuration.iceServers
        .map((e) => {
              'urls': e.urls,
              'username': e.username,
              'credential': e.credential
            })
        .toList(),
    'iceCandidatePoolSize': configuration.iceCandidatePoolSize,
    'bundlePolicy': configuration.bundlePolicy,
    'peerIdentity': configuration.peerIdentity,
    'iceTransportPolicy': configuration.iceTransportPolicy,
  };
}

dart_webrtc.RTCOfferOptions rtcOfferOptionsFromMap(Map<String, dynamic> map) {
  return dart_webrtc.RTCOfferOptions(
      offerToReceiveAudio:
          map['offerToReceiveAudio'] ?? map['mandatory']['OfferToReceiveAudio'],
      offerToReceiveVideo:
          map['offerToReceiveVideo'] ?? map['mandatory']['OfferToReceiveAudio'],
      iceRestart: map['iceRestart'] ?? map['mandatory']['iceRestart']);
}

dart_webrtc.RTCAnswerOptions rtcAnswerOptionsFromMap(Map<String, dynamic> map) {
  return dart_webrtc.RTCAnswerOptions(
      voiceActivityDetection: map['voiceActivityDetection'] ??
          map['mandatory']['voiceActivityDetection']);
}

/*
 *  PeerConnection
 */
class RTCPeerConnectionWeb extends RTCPeerConnection {
  RTCPeerConnectionWeb(this._peerConnectionId, this._jsPc) {
    _jsPc.onaddstream = (dart_webrtc.MediaStreamEvent mediaStreamEvent) {
      final jsStream = mediaStreamEvent.stream;
      final _remoteStream = _remoteStreams.putIfAbsent(
          jsStream.id,
          () => MediaStreamWeb(
              dart_webrtc.MediaStream(jsStream), _peerConnectionId));

      onAddStream?.call(_remoteStream);

      jsStream.onaddtrack = allowInterop(
          (dart_webrtc.MediaStreamTrackEvent mediaStreamTrackEvent) {
        final jsTrack = mediaStreamTrackEvent.track;
        final track = MediaStreamTrackWeb(jsTrack);
        _remoteStream.addTrack(track, addToNative: false).then((_) {
          onAddTrack?.call(_remoteStream, track);
        });
      });

      jsStream.onremovetrack = allowInterop(
          (dart_webrtc.MediaStreamTrackEvent mediaStreamTrackEvent) {
        final jsTrack = mediaStreamTrackEvent.track;
        final track = MediaStreamTrackWeb(jsTrack);
        _remoteStream.removeTrack(track, removeFromNative: false).then((_) {
          onRemoveTrack?.call(_remoteStream, track);
        });
      });
    };

    _jsPc.ondatachannel = (dart_webrtc.RTCDataChannelEvent event) {
      onDataChannel?.call(RTCDataChannelWeb(event.channel));
    };

    _jsPc.onicecandidate = (dart_webrtc.RTCPeerConnectionIceEvent event) {
      onIceCandidate?.call(
          event.candidate != null ? _candidateFromJs(event.candidate) : null);
    };

    _jsPc.oniceconnectionstatechange =
        (dart_webrtc.RTCIceConnectionState state) {
      onIceConnectionState?.call(
          iceConnectionStateForString(_iceConnectionStateToString(state)));
    };

    _jsPc.onicegatheringstatechange = (dart_webrtc.RTCIceGatheringState state) {
      onIceGatheringState
          ?.call(iceGatheringStateforString(_iceGatheringStateToString(state)));
    };

    _jsPc.onremovestream = (dart_webrtc.MediaStreamEvent mediaStreamEvent) {
      final _remoteStream = _remoteStreams.remove(mediaStreamEvent.stream.id);
      onRemoveStream?.call(_remoteStream);
    };

    _jsPc.onsignalingstatechange = (dart_webrtc.RTCSignalingState state) {
      onSignalingState
          ?.call(signalingStateForString(_signalingStateToString(state)));
    };

    _jsPc.onconnectionstatechange = (dart_webrtc.RTCPeerConnectionState state) {
      onConnectionState?.call(
          peerConnectionStateForString(_peerConnectionStateToString(state)));
    };

    _jsPc.onnegotiationneeded = (event) {
      onRenegotiationNeeded?.call();
    };

    _jsPc.ontrack = (dart_webrtc.RTCTrackEvent event) {
      onTrack?.call(RTCTrackEventWeb(
        track: MediaStreamTrackWeb(event.track),
        receiver: RTCRtpReceiverWeb(event.receiver),
        streams: event.streams
            .map((e) =>
                MediaStreamWeb(dart_webrtc.MediaStream(e), _peerConnectionId))
            .toList(),
        transceiver: RTCRtpTransceiverWeb(event.transceiver, _peerConnectionId),
      ));
    };
  }

  final String _peerConnectionId;
  final dart_webrtc.RTCPeerConnection _jsPc;
  final _localStreams = <String, MediaStream>{};
  final _remoteStreams = <String, MediaStream>{};

  RTCSignalingState _signalingState;
  RTCIceGatheringState _iceGatheringState;
  RTCIceConnectionState _iceConnectionState;
  RTCPeerConnectionState _connectionState;

  @override
  RTCSignalingState get signalingState => _signalingState;

  @override
  RTCIceGatheringState get iceGatheringState => _iceGatheringState;

  @override
  RTCIceConnectionState get iceConnectionState => _iceConnectionState;

  @override
  RTCPeerConnectionState get connectionState => _connectionState;

  @override
  Future<void> dispose() {
    _jsPc.close();
    return Future.value();
  }

  @override
  Map<String, dynamic> get getConfiguration =>
      rtcConfigurationToMap(_jsPc.getConfiguration());

  @override
  Future<void> setConfiguration(Map<String, dynamic> configuration) async {
    _jsPc.setConfiguration(rtcConfigurationFromMap(configuration));
  }

  @override
  Future<RTCSessionDescription> createOffer(
      [Map<String, dynamic> constraints]) async {
    final offer =
        await _jsPc.createOffer(options: rtcOfferOptionsFromMap(constraints));
    return _sessionFromJs(offer);
  }

  @override
  Future<RTCSessionDescription> createAnswer(
      [Map<String, dynamic> constraints]) async {
    final answer =
        await _jsPc.createAnswer(options: rtcAnswerOptionsFromMap(constraints));
    return _sessionFromJs(answer);
  }

  @override
  Future<void> addStream(MediaStream stream) {
    var _native = stream as MediaStreamWeb;
    _localStreams.putIfAbsent(
        stream.id, () => MediaStreamWeb(_native.jsStream, _peerConnectionId));
    _jsPc.addStream(_native.jsStream);
    return Future.value();
  }

  @override
  Future<void> removeStream(MediaStream stream) async {
    var _native = stream as MediaStreamWeb;
    _localStreams.remove(stream.id);
    _jsPc.removeStream(_native.jsStream);
    return Future.value();
  }

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {
    await _jsPc.setLocalDescription(dart_webrtc.RTCSessionDescription(
        sdp: description.sdp, type: description.type));
  }

  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _jsPc.setRemoteDescription(dart_webrtc.RTCSessionDescription(
        sdp: description.sdp, type: description.type));
  }

  @override
  Future<RTCSessionDescription> getLocalDescription() async {
    return _sessionFromJs(_jsPc.localDescription);
  }

  @override
  Future<RTCSessionDescription> getRemoteDescription() async {
    return _sessionFromJs(_jsPc.remoteDescription);
  }

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _jsPc.addIceCandidate(_candidateToJs(candidate));
  }

  @override
  Future<List<StatsReport>> getStats([MediaStreamTrack track]) async {
    final stats = await _jsPc.getStats();
    var reports = <StatsReport>[];
    stats.values.forEach((String key, dart_webrtc.RTCStats value) {
      reports.add(StatsReport.fromMap(value.values));
    });
    return reports;
  }

  @override
  List<MediaStream> getLocalStreams() => _jsPc
      .getLocalStreams()
      .map((jsStream) => _localStreams[jsStream.id])
      .toList();

  @override
  List<MediaStream> getRemoteStreams() => _jsPc
      .getRemoteStreams()
      .map((jsStream) => _remoteStreams[jsStream.id])
      .toList();

  @override
  Future<RTCDataChannel> createDataChannel(
      String label, RTCDataChannelInit dataChannelDict) async {
    final map = dataChannelDict.toMap();
    if (dataChannelDict.binaryType == 'binary') {
      map['binaryType'] = 'arraybuffer'; // Avoid Blob in data channel
    }
    final jsDc = await _jsPc.createDataChannel(
        label: label, init: _convertToJsInit(dataChannelDict));
    return Future.value(RTCDataChannelWeb(jsDc));
  }

  dart_webrtc.RTCDataChannelInit _convertToJsInit(RTCDataChannelInit init) {
    return dart_webrtc.RTCDataChannelInit(
        id: init.id,
        ordered: init.ordered,
        maxRetransmits: init.maxRetransmits,
        negotiated: init.negotiated,
        protocol: init.protocol);
  }

  @override
  Future<void> close() async {
    _jsPc.close();
    return Future.value();
  }

  @override
  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    return RTCDTMFSenderWeb(_jsPc.createDTMFSender());
  }

  RTCSessionDescription _sessionFromJs(dart_webrtc.RTCSessionDescription sd) =>
      RTCSessionDescription(sd.sdp, sd.type);

  RTCIceCandidate _candidateFromJs(dart_webrtc.RTCIceCandidate cand) =>
      RTCIceCandidate(cand.candidate, cand.sdpMid, cand.sdpMLineIndex);

  dart_webrtc.RTCIceCandidate _candidateToJs(RTCIceCandidate cand) =>
      dart_webrtc.RTCIceCandidate(
          candidate: cand.candidate,
          sdpMid: cand.sdpMid,
          sdpMLineIndex: cand.sdpMlineIndex);

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [MediaStream stream]) async {
    var _native = track as MediaStreamTrackWeb;
    var jsRtpSender = await _jsPc.addTrack(
        track: _native.jsTrack, stream: (stream as MediaStreamWeb).jsStream.js);
    return RTCRtpSenderWeb.fromJsSender(jsRtpSender);
  }

  @override
  Future<bool> removeTrack(RTCRtpSender sender) {
    var _native = sender as RTCRtpSenderWeb;
    _jsPc.removeTrack(_native.jsSender);
    return Future.value(true);
  }

  @override
  List<RTCRtpReceiver> get receivers =>
      _jsPc.receivers.map((e) => RTCRtpReceiverWeb(e)).toList();

  @override
  List<RTCRtpSender> get senders =>
      _jsPc.senders.map((e) => RTCRtpSenderWeb.fromJsSender(e)).toList();

  @override
  List<RTCRtpTransceiver> get transceivers => _jsPc.transceivers
      .map((e) => RTCRtpTransceiverWeb.fromJsObject(e))
      .toList();

  @override
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack track,
      RTCRtpMediaType kind,
      RTCRtpTransceiverInit init}) async {
    var _jsTransceiver;
    if (track != null) {
      var _nativeTrack = track as MediaStreamTrackWeb;
      _jsTransceiver = await _jsPc.addTransceiver(
          init: _convertToJsTtpTransceiverInit(init),
          track: _nativeTrack.jsTrack);
    } else if (kind != null) {
      _jsTransceiver = await _jsPc.addTransceiver(
          init: _convertToJsTtpTransceiverInit(init),
          kind: typeRTCRtpMediaTypetoString[kind]);
    }
    return RTCRtpTransceiverWeb(_jsTransceiver, _peerConnectionId);
  }

  dart_webrtc.RTCRtpTransceiverInit _convertToJsTtpTransceiverInit(
      RTCRtpTransceiverInit init) {
    return dart_webrtc.RTCRtpTransceiverInit(
        direction: typeRtpTransceiverDirectionToString[init.direction],
        streams: init.streams != null
            ? init.streams
                .map((e) => (e as MediaStreamWeb).jsStream.js)
                .toList()
            : [],
        sendEncodings: init.sendEncodings != null
            ? init.sendEncodings
                .map((e) => dart_webrtc.rtpEncodingParametersFromMap(e.toMap()))
                .toList()
            : []);
  }

  String _iceConnectionStateToString(dart_webrtc.RTCIceConnectionState state) {
    switch (state) {
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateNew:
        return 'new';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateChecking:
        return 'checking';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateConnected:
        return 'connected';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateCompleted:
        return 'completed';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateFailed:
        return 'failed';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        return 'disconnected';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateClosed:
        return 'closed';
      case dart_webrtc.RTCIceConnectionState.RTCIceConnectionStateCount:
        return 'count';
    }
    return 'closed';
  }

  String _iceGatheringStateToString(dart_webrtc.RTCIceGatheringState state) {
    switch (state) {
      case dart_webrtc.RTCIceGatheringState.RTCIceGatheringStateNew:
        return 'new';
      case dart_webrtc.RTCIceGatheringState.RTCIceGatheringStateGathering:
        return 'gathering';
      case dart_webrtc.RTCIceGatheringState.RTCIceGatheringStateComplete:
        return 'complete';
    }
    return 'new';
  }

  String _signalingStateToString(dart_webrtc.RTCSignalingState state) {
    switch (state) {
      case dart_webrtc.RTCSignalingState.RTCSignalingStateStable:
        return 'stable';
      case dart_webrtc.RTCSignalingState.RTCSignalingStateHaveLocalOffer:
        return 'have-local-offer';
      case dart_webrtc.RTCSignalingState.RTCSignalingStateHaveLocalPrAnswer:
        return 'have-local-pranswer';
      case dart_webrtc.RTCSignalingState.RTCSignalingStateHaveRemoteOffer:
        return 'have-remote-offer';
      case dart_webrtc.RTCSignalingState.RTCSignalingStateHaveRemotePrAnswer:
        return 'have-remote-pranswer';
      case dart_webrtc.RTCSignalingState.RTCSignalingStateClosed:
        return 'closed';
    }
    return 'closed';
  }

  String _peerConnectionStateToString(
      dart_webrtc.RTCPeerConnectionState state) {
    switch (state) {
      case dart_webrtc.RTCPeerConnectionState.RTCPeerConnectionStateNew:
        return 'new';
      case dart_webrtc.RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        return 'connecting';
      case dart_webrtc.RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        return 'connected';
      case dart_webrtc.RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        return 'closed';
      case dart_webrtc
          .RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        return 'disconnected';
      case dart_webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        return 'failed';
    }

    return 'closed';
  }
}
