import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;

import 'package:flutter_webrtc/src/web/rtc_rtp_transceiver_impl.dart';

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
import 'rtc_rtp_sender_impl.dart';

/*
 *  PeerConnection
 */
class RTCPeerConnectionWeb extends RTCPeerConnection {
  RTCPeerConnectionWeb(this._peerConnectionId, this._jsPc) {
    _jsPc.onAddStream.listen((mediaStreamEvent) {
      final jsStream = mediaStreamEvent.stream;
      final _remoteStream = _remoteStreams.putIfAbsent(
          jsStream.id, () => MediaStreamWeb(jsStream, _peerConnectionId));

      onAddStream?.call(_remoteStream);

      jsStream.onAddTrack.listen((mediaStreamTrackEvent) {
        final jsTrack =
            (mediaStreamTrackEvent as html.MediaStreamTrackEvent).track;
        final track = MediaStreamTrackWeb(jsTrack);
        _remoteStream.addTrack(track, addToNative: false).then((_) {
          onAddTrack?.call(_remoteStream, track);
        });
      });

      jsStream.onRemoveTrack.listen((mediaStreamTrackEvent) {
        final jsTrack =
            (mediaStreamTrackEvent as html.MediaStreamTrackEvent).track;
        final track = MediaStreamTrackWeb(jsTrack);
        _remoteStream.removeTrack(track, removeFromNative: false).then((_) {
          onRemoveTrack?.call(_remoteStream, track);
        });
      });
    });

    _jsPc.onDataChannel.listen((dataChannelEvent) {
      onDataChannel?.call(RTCDataChannelWeb(dataChannelEvent.channel));
    });

    _jsPc.onIceCandidate.listen((iceEvent) {
      if (iceEvent.candidate != null) {
        onIceCandidate?.call(_iceFromJs(iceEvent.candidate));
      }
    });

    _jsPc.onIceConnectionStateChange.listen((_) {
      _iceConnectionState =
          iceConnectionStateForString(_jsPc.iceConnectionState);
      onIceConnectionState?.call(_iceConnectionState);
    });

    js.JsObject.fromBrowserObject(_jsPc)['onicegatheringstatechange'] =
        js.JsFunction.withThis((_) {
      _iceGatheringState = iceGatheringStateforString(_jsPc.iceGatheringState);
      onIceGatheringState?.call(_iceGatheringState);
    });

    _jsPc.onRemoveStream.listen((mediaStreamEvent) {
      final _remoteStream = _remoteStreams.remove(mediaStreamEvent.stream.id);
      onRemoveStream?.call(_remoteStream);
    });

    _jsPc.onSignalingStateChange.listen((_) {
      _signalingState = signalingStateForString(_jsPc.signalingState);
      onSignalingState?.call(_signalingState);
    });

    js.JsObject.fromBrowserObject(_jsPc)['connectionstatechange'] =
        js.JsFunction.withThis((_, state) {
      _connectionState = peerConnectionStateForString(state);
      onConnectionState?.call(_connectionState);
    });

    js.JsObject.fromBrowserObject(_jsPc)['negotiationneeded'] =
        js.JsFunction.withThis(() {
      onRenegotiationNeeded?.call();
    });

    js.JsObject.fromBrowserObject(_jsPc)['ontrack'] =
        js.JsFunction.withThis((_, trackEvent) {
      // TODO(rostopira):  trackEvent is JsObject conforming to RTCTrackEvent,
      // https://developer.mozilla.org/en-US/docs/Web/API/RTCTrackEvent
      print('ontrack arg: $trackEvent');
    });
  }
  final String _peerConnectionId;
  final html.RtcPeerConnection _jsPc;
  final _localStreams = <String, MediaStream>{};
  final _remoteStreams = <String, MediaStream>{};
  final _configuration = <String, dynamic>{};
  final List<RTCRtpSender> _senders = <RTCRtpSender>[];
  final List<RTCRtpReceiver> _receivers = <RTCRtpReceiver>[];
  final List<RTCRtpTransceiver> _transceivers = <RTCRtpTransceiver>[];

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
  Map<String, dynamic> get getConfiguration => _configuration;

  @override
  Future<void> setConfiguration(Map<String, dynamic> configuration) {
    _configuration.addAll(configuration);

    _jsPc.setConfiguration(configuration);
    return Future.value();
  }

  @override
  Future<RTCSessionDescription> createOffer(
      [Map<String, dynamic> constraints]) async {
    final offer = await _jsPc.createOffer(constraints);
    return _sessionFromJs(offer);
  }

  @override
  Future<RTCSessionDescription> createAnswer(
      [Map<String, dynamic> constraints]) async {
    final answer = await _jsPc.createAnswer(constraints);
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
    await jsutil.promiseToFuture(
        jsutil.callMethod(_jsPc, 'addIceCandidate', [_iceToJs(candidate)]));
  }

  @override
  Future<List<StatsReport>> getStats([MediaStreamTrack track]) async {
    final stats = await _jsPc.getStats();
    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
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
      String label, RTCDataChannelInit dataChannelDict) {
    final map = dataChannelDict.toMap();
    if (dataChannelDict.binaryType == 'binary') {
      map['binaryType'] = 'arraybuffer'; // Avoid Blob in data channel
    }

    final jsDc = _jsPc.createDataChannel(label, map);
    return Future.value(RTCDataChannelWeb(jsDc));
  }

  @override
  Future<void> close() async {
    _jsPc.close();
    return Future.value();
  }

  @override
  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    var _native = track as MediaStreamTrackWeb;
    var jsDtmfSender = _jsPc.createDtmfSender(_native.jsTrack);
    return RTCDTMFSenderWeb(jsDtmfSender);
  }

  //
  // utility section
  //

  RTCIceCandidate _iceFromJs(html.RtcIceCandidate candidate) => RTCIceCandidate(
        candidate.candidate,
        candidate.sdpMid,
        candidate.sdpMLineIndex,
      );

  html.RtcIceCandidate _iceToJs(RTCIceCandidate c) =>
      html.RtcIceCandidate(c.toMap());

  RTCSessionDescription _sessionFromJs(html.RtcSessionDescription sd) =>
      RTCSessionDescription(sd.sdp, sd.type);

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [List<MediaStream> streams]) async {
    var _track = track as MediaStreamTrackWeb;
    var _stream = streams[0] as MediaStreamWeb;
    var sender = _jsPc.addTrack(_track.jsTrack, _stream.jsStream);
    return RTCRtpSenderWeb.fromJsObject(sender);
  }

  @override
  Future<bool> closeSender(RTCRtpSender sender) async {
    var webSender = sender as RTCRtpSenderWeb;
    await webSender.dispose();
    return true;
  }

  @override
  Future<RTCRtpSender> createSender(String kind, String streamId) {
    throw UnimplementedError();
  }

  @override
  List<RTCRtpReceiver> get receivers => _receivers;

  @override
  Future<bool> removeTrack(RTCRtpSender sender) async {
    var webSender = sender as RTCRtpSenderWeb;
    _jsPc.removeTrack(webSender.jsSender);
    return true;
  }

  @override
  List<RTCRtpSender> get senders => _senders;

  @override
  List<RTCRtpTransceiver> get transceivers => _transceivers;

  @override
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack track,
      RTCRtpMediaType kind,
      RTCRtpTransceiverInit init}) async {
    var kindType = (kind != null) ? typeRTCRtpMediaTypetoString[kind] : null;
    var jsTrack =
        (track != null) ? (track as MediaStreamTrackWeb).jsTrack : null;

    if (jsutil.hasProperty(_jsPc, 'addTransceiver')) {
      final jsOptions =
          js.JsObject.jsify(RTCRtpTransceiverInit.initToMap(init));
      // trackOrKind
      Object jsTransceiver = jsutil.callMethod(
          _jsPc, 'addTransceiver', [kindType ?? jsTrack, jsOptions]);
      return RTCRtpTransceiverWeb.fromJsObject(jsTransceiver,
          peerConnectionId: _peerConnectionId);
    }
    return null;
  }
}
