import 'dart:async';
import 'dart:html' as HTML;

import 'rtc_peerconnection.dart';

Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration,
    Map<String, dynamic> constraints) async {
  final constr = (constraints != null && constraints.isNotEmpty)
      ? constraints
      : {
          "mandatory": {},
          "optional": [
            {"DtlsSrtpKeyAgreement": true},
          ],
        };
  final jsRtcPc = HTML.RtcPeerConnection(configuration, constr);
  return RTCPeerConnection(jsRtcPc);
}
