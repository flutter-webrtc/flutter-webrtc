import 'dart:async';

import 'package:dart_webrtc/dart_webrtc.dart' as js;

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

js.RTCConfiguration rtcConfigurationFromMap(Map<String, dynamic> map) {
  // TODO:
  return js.RTCConfiguration();
}

Map<String, dynamic> rtcConfigurationToMap(js.RTCConfiguration configuration) {
  // TODO:
  return {};
}

js.RTCOfferOptions rtcOfferOptionsFromMap(Map<String, dynamic> map) {
  return js.RTCOfferOptions();
}

js.RTCAnswerOptions rtcAnswerOptionsFromMap(Map<String, dynamic> map) {
  return js.RTCAnswerOptions();
}

/*
 *  PeerConnection
 */
class RTCPeerConnectionWeb extends RTCPeerConnection {
  RTCPeerConnectionWeb(this._peerConnectionId, this._jsPc) {
    _jsPc.onaddstream = (js.MediaStreamEvent mediaStreamEvent) {
      final jsStream = mediaStreamEvent.stream;
      final _remoteStream = _remoteStreams.putIfAbsent(
          jsStream.id, () => MediaStreamWeb(jsStream, _peerConnectionId));

      onAddStream?.call(_remoteStream);

      jsStream.onaddtrack = (js.MediaStreamTrackEvent mediaStreamTrackEvent) {
        final jsTrack = mediaStreamTrackEvent.track;
        final track = MediaStreamTrackWeb(jsTrack);
        _remoteStream.addTrack(track, addToNative: false).then((_) {
          onAddTrack?.call(_remoteStream, track);
        });
      };

      jsStream.onremovetrack =
          (js.MediaStreamTrackEvent mediaStreamTrackEvent) {
        final jsTrack = mediaStreamTrackEvent.track;
        final track = MediaStreamTrackWeb(jsTrack);
        _remoteStream.removeTrack(track, removeFromNative: false).then((_) {
          onRemoveTrack?.call(_remoteStream, track);
        });
      };
    };

    _jsPc.ondatachannel = (js.RTCDataChannelEvent event) {
      onDataChannel?.call(RTCDataChannelWeb(event.channel));
    };

    _jsPc.onicecandidate = (js.RTCPeerConnectionIceEvent event) {
      onIceCandidate?.call(_candidateFromJs(event.candidate));
    };

    _jsPc.oniceconnectionstatechange = (js.RTCIceConnectionState state) {
      onIceConnectionState?.call(state as RTCIceConnectionState);
    };

    _jsPc.onicegatheringstatechange = (js.RTCIceGatheringState state) {
      onIceGatheringState?.call(state as RTCIceGatheringState);
    };

    _jsPc.onremovestream = (js.MediaStreamEvent mediaStreamEvent) {
      final _remoteStream = _remoteStreams.remove(mediaStreamEvent.stream.id);
      onRemoveStream?.call(_remoteStream);
    };

    _jsPc.onsignalingstatechange = (js.RTCSignalingState state) {
      onSignalingState?.call(state as RTCSignalingState);
    };

    _jsPc.onconnectionstatechange = (js.RTCPeerConnectionState state) {
      onConnectionState?.call(state as RTCPeerConnectionState);
    };

    _jsPc.onnegotiationneeded = (event) {
      onRenegotiationNeeded?.call();
    };

    _jsPc.ontrack = (js.RTCTrackEvent event) {
      print('ontrack arg: $event');
    };
  }

  final String _peerConnectionId;
  final js.RTCPeerConnection _jsPc;
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
    await _jsPc.setLocalDescription(description.toMap());
  }

  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _jsPc.setRemoteDescription(description.toMap());
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
    final stats = _jsPc.getStats();
    var report = <StatsReport>[];
    stats.forEach((String key, js.RTCStats value) {
      var map = value as Map<String, dynamic>;
      report.add(StatsReport(map['id'], map['type'], map['timestamp'], map));
    });
    return report;
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
        label: label, init: js.RTCDataChannelInit());
    return Future.value(RTCDataChannelWeb(jsDc));
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

  RTCSessionDescription _sessionFromJs(js.RTCSessionDescription sd) =>
      RTCSessionDescription(sd.sdp, sd.type);

  RTCIceCandidate _candidateFromJs(js.RTCIceCandidate cand) =>
      RTCIceCandidate(cand.candidate, cand.sdpMid, cand.sdpMLineIndex);

  js.RTCIceCandidate _candidateToJs(RTCIceCandidate cand) => js.RTCIceCandidate(
      candidate: cand.candidate,
      sdpMid: cand.sdpMid,
      sdpMLineIndex: cand.sdpMlineIndex);

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [List<MediaStream> streams]) async {
    var _native = track as MediaStreamTrackWeb;
    var jsRtpSender = await _jsPc.addTrack(track: _native.jsTrack, streams: []);
    return RTCRtpSenderWeb.fromJsSender(jsRtpSender);
  }

  @override
  Future<bool> closeSender(RTCRtpSender sender) async {
    //_jsPc.closeSender((sender as RTCRtpSenderWeb).jsSender);
    return true;
  }

  @override
  Future<RTCRtpSender> createSender(String kind, String streamId) async {
    var jsRtpSender = await _jsPc.addTrack(
        //kind: typeRTCRtpMediaTypetoString[kind],
        );
    return RTCRtpSenderWeb.fromJsSender(jsRtpSender);
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
  Future<bool> removeTrack(RTCRtpSender sender) {
    var _native = sender as RTCRtpSenderWeb;
    _jsPc.removeTrack(_native.jsSender);
    return Future.value(true);
  }

  @override
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack track,
      RTCRtpMediaType kind,
      RTCRtpTransceiverInit init}) async {
    var _nativeTrack = track as MediaStreamTrackWeb;
    var _jsTransceiver = await _jsPc.addTransceiver(
        init: js.RTCRtpTransceiverInit(),
        kind: typeRTCRtpMediaTypetoString[kind],
        track: _nativeTrack.jsTrack);
    return RTCRtpTransceiverWeb(_jsTransceiver, _peerConnectionId);
  }
}
