import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'media_stream.dart';
import 'rtc_peerconnection.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    Map<String, dynamic> constraints) async {
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
  return RTCPeerConnection(_peerConnectionId, jsRtcPc);
}

Future<MediaStream> createLocalMediaStream(String label) async {
  final jsMs = html.MediaStream();
  return MediaStream(jsMs, 'local');
}
