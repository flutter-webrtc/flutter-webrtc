import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;

import '../enums.dart';
import '../rtc_stats_report.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_data_channel.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_session_description.dart';

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
  RTCPeerConnection(this._peerConnectionId, this._jsPc) {
    _jsPc.onAddStream.listen((mediaStreamEvent) {
      final jsStream = mediaStreamEvent.stream;
      final _remoteStream = _remoteStreams.putIfAbsent(
          jsStream.id, () => MediaStream(jsStream, _peerConnectionId));

      onAddStream?.call(_remoteStream);

      jsStream.onAddTrack.listen((mediaStreamTrackEvent) {
        final jsTrack =
            (mediaStreamTrackEvent as html.MediaStreamTrackEvent).track;
        final track = MediaStreamTrack(jsTrack);
        _remoteStream.addTrack(track, addToNative: false).then((_) {
          onAddTrack?.call(_remoteStream, track);
        });
      });

      jsStream.onRemoveTrack.listen((mediaStreamTrackEvent) {
        final jsTrack =
            (mediaStreamTrackEvent as html.MediaStreamTrackEvent).track;
        final track = MediaStreamTrack(jsTrack);
        _remoteStream.removeTrack(track, removeFromNative: false).then((_) {
          onRemoveTrack?.call(_remoteStream, track);
        });
      });
    });

    _jsPc.onDataChannel.listen((dataChannelEvent) {
      onDataChannel?.call(RTCDataChannel(dataChannelEvent.channel));
    });

    _jsPc.onIceCandidate.listen((iceEvent) {
      if (iceEvent.candidate != null) {
        onIceCandidate?.call(RTCIceCandidate.fromJs(iceEvent.candidate));
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

  RTCSignalingState get signalingState => _signalingState;

  RTCIceGatheringState get iceGatheringState => _iceGatheringState;

  RTCIceConnectionState get iceConnectionState => _iceConnectionState;

  Future<void> dispose() {
    _jsPc.close();
    return Future.value();
  }

  Map<String, dynamic> get getConfiguration => _configuration;

  Future<void> setConfiguration(Map<String, dynamic> configuration) {
    _configuration.addAll(configuration);

    _jsPc.setConfiguration(configuration);
    return Future.value();
  }

  Future<RTCSessionDescription> createOffer(
      Map<String, dynamic> constraints) async {
    final offer = await _jsPc.createOffer(constraints);
    return RTCSessionDescription.fromJs(offer);
  }

  Future<RTCSessionDescription> createAnswer(
      Map<String, dynamic> constraints) async {
    final answer = await _jsPc.createAnswer(constraints);
    return RTCSessionDescription.fromJs(answer);
  }

  Future<void> addStream(MediaStream stream) {
    _localStreams.putIfAbsent(stream.jsStream.id,
        () => MediaStream(stream.jsStream, _peerConnectionId));
    _jsPc.addStream(stream.jsStream);
    return Future.value();
  }

  Future<void> removeStream(MediaStream stream) async {
    _localStreams.remove(stream.jsStream.id);
    _jsPc.removeStream(stream.jsStream);
    return Future.value();
  }

  Future<void> setLocalDescription(RTCSessionDescription description) async {
    await _jsPc.setLocalDescription(description.toMap());
  }

  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _jsPc.setRemoteDescription(description.toMap());
  }

  Future<RTCSessionDescription> getLocalDescription() async {
    return RTCSessionDescription.fromJs(_jsPc.localDescription);
  }

  Future<RTCSessionDescription> getRemoteDescription() async {
    return RTCSessionDescription.fromJs(_jsPc.remoteDescription);
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await jsutil.promiseToFuture(
        jsutil.callMethod(_jsPc, 'addIceCandidate', [candidate.toJs()]));
  }

  Future<List<StatsReport>> getStats([MediaStreamTrack track]) async {
    final stats = await _jsPc.getStats();
    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  List<MediaStream> getLocalStreams() => _jsPc
      .getLocalStreams()
      .map((jsStream) => _localStreams[jsStream.id])
      .toList();

  List<MediaStream> getRemoteStreams() => _jsPc
      .getRemoteStreams()
      .map((jsStream) => _remoteStreams[jsStream.id])
      .toList();

  Future<RTCDataChannel> createDataChannel(
      String label, RTCDataChannelInit dataChannelDict) {
    final map = dataChannelDict.toMap();
    if (dataChannelDict.binaryType == 'binary') {
      map['binaryType'] = 'arraybuffer'; // Avoid Blob in data channel
    }

    final jsDc = _jsPc.createDataChannel(label, map);
    return Future.value(RTCDataChannel(jsDc));
  }

  Future<Null> close() async {
    _jsPc.close();
    return Future.value();
  }

  //'audio|video', { 'direction': 'recvonly|sendonly|sendrecv' }
  void addTransceiver(String type, Map<String, String> options) {
    if (jsutil.hasProperty(_jsPc, 'addTransceiver')) {
      final jsOptions = js.JsObject.jsify(options);
      jsutil.callMethod(_jsPc, 'addTransceiver', [type, jsOptions]);
    }
  }

  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    var jsDtmfSender = _jsPc.createDtmfSender(track.jsTrack);
    return RTCDTMFSender(jsDtmfSender);
  }
}
