import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import '../interface/factory.dart';
import '../interface/media_recorder.dart';
import '../interface/media_stream.dart';
import '../interface/navigator.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_video_renderer.dart';
import 'media_recorder_impl.dart';
import 'media_stream_impl.dart';
import 'navigator_impl.dart';
import 'rtc_peerconnection_impl.dart';
import 'rtc_video_renderer_impl.dart';

class RTCFactoryWeb extends RTCFactory {
  RTCFactoryWeb._internal();
  static final instance = RTCFactoryWeb._internal();

  @override
  Future<RTCPeerConnection> createPeerConnection(
      Map<String, dynamic> configuration,
      [Map<String, dynamic> constraints]) async {
    final constr = (constraints != null && constraints.isNotEmpty)
        ? constraints
        : {
            'mandatory': {},
            'optional': [
              {'DtlsSrtpKeyAgreement': true},
            ],
          };
    final jsRtcPc = html.RtcPeerConnection(configuration, constr);
    final _peerConnectionId = base64Encode(jsRtcPc.toString().codeUnits);
    return RTCPeerConnectionWeb(_peerConnectionId, jsRtcPc);
  }

  @override
  Future<MediaStream> createLocalMediaStream(String label) async {
    final jsMs = html.MediaStream();
    return MediaStreamWeb(jsMs, 'local');
  }

  @override
  MediaRecorder mediaRecorder() {
    return MediaRecorderWeb();
  }

  @override
  VideoRenderer videoRenderer() {
    return RTCVideoRendererWeb();
  }

  @override
  Navigator get navigator => NavigatorWeb();
}
