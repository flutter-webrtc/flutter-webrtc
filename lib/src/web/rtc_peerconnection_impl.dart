import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;

import '../interface/enums.dart';
import '../interface/media_stream.dart';
import '../interface/media_stream_track.dart';
import '../interface/rtc_data_channel.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_ice_candidate.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_session_description.dart';
import '../interface/rtc_stats_report.dart';
import 'media_stream_impl.dart';
import 'media_stream_track_impl.dart';
import 'rtc_data_channel_impl.dart';
import 'rtc_dtmf_sender_impl.dart';

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

  RTCSignalingState _signalingState;
  RTCIceGatheringState _iceGatheringState;
  RTCIceConnectionState _iceConnectionState;

  @override
  RTCSignalingState get signalingState => _signalingState;

  @override
  RTCIceGatheringState get iceGatheringState => _iceGatheringState;

  @override
  RTCIceConnectionState get iceConnectionState => _iceConnectionState;

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
      Map<String, dynamic> constraints) async {
    final offer = await _jsPc.createOffer(constraints);
    return _sessionFromJs(offer);
  }

  @override
  Future<RTCSessionDescription> createAnswer(
      Map<String, dynamic> constraints) async {
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

  //'audio|video', { 'direction': 'recvonly|sendonly|sendrecv' }
  @override
  void addTransceiver(String type, Map<String, String> options) {
    if (jsutil.hasProperty(_jsPc, 'addTransceiver')) {
      final jsOptions = js.JsObject.jsify(options);
      jsutil.callMethod(_jsPc, 'addTransceiver', [type, jsOptions]);
    }
  }

  @override
  IRTCDTMFSender createDtmfSender(MediaStreamTrack track) {
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
}
