import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import '../interface/factory.dart';
import '../interface/media_device.dart';
import '../interface/media_recorder.dart';
import '../interface/media_stream.dart';
import '../interface/rtc_peerconnection.dart';
import '../interface/rtc_video_renderer.dart';
import 'media_devices_impl.dart';
import 'media_recorder_impl.dart';
import 'media_stream_impl.dart';
import 'rtc_peerconnection_impl.dart';
import 'rtc_video_view_impl.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    [Map<String, dynamic> constraints]) {
  return _RTCFactoryWeb.instance
      .createPeerConnection(configuration, constraints);
}

Future<MediaStream> createLocalMediaStream(String label) {
  return _RTCFactoryWeb.instance.createLocalMediaStream(label);
}

MediaDevices mediaDevices() {
  return _RTCFactoryWeb.instance.mediaDevices();
}

MediaRecorder mediaRecorder() {
  return _RTCFactoryWeb.instance.mediaRecorder();
}

class _RTCFactoryWeb extends RTCFactory {
  _RTCFactoryWeb._internal();

  static final RTCFactory instance = _RTCFactoryWeb._internal();

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
  MediaDevices mediaDevices() {
    return MediaDevicesWeb();
  }

  @override
  MediaRecorder mediaRecorder() {
    return MediaRecorderWeb();
  }

  @override
  RTCVideoRenderer videoRenderer() {
    return RTCVideoRendererWeb();
  }
}
