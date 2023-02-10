import 'dart:convert';
import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

class WebRTCPublisher {
  webrtc.RTCPeerConnection? _pc;
  Function(webrtc.RTCPeerConnectionState state)? _onConnectionState;

  set onConnectionState(Function(webrtc.RTCPeerConnectionState state) s) =>
      _onConnectionState = s;

  void initState() {}

  Future<void> publish(String url, webrtc.MediaStream stream) async {
    try {
      await _pc?.close();
      _pc = null;

      // Create the peer connection.
      _pc = await webrtc.createPeerConnection({
        // AddTransceiver is only available with Unified Plan SdpSemantics
        'sdpSemantics': "unified-plan"
      });

      if (_pc == null) {
        _onConnectionState
            ?.call(webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed);
        return;
      }
      print('WebRTC: createPeerConnection done');

      _pc!.onConnectionState = (webrtc.RTCPeerConnectionState state) {
        print("==================== RTCPeerConnectionState = $state");
        _onConnectionState?.call(state);
      };

      _pc!.onIceConnectionState = (webrtc.RTCIceConnectionState state) {
        print("==================== RTCIceConnectionState = $state");
      };

      _pc!.addTransceiver(
        track: stream.getAudioTracks()[0],
        kind: webrtc.RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: webrtc.RTCRtpTransceiverInit(
            direction: webrtc.TransceiverDirection.SendOnly),
      );

      print('WebRTC: Setup PC done, Audio SendOnly');

      // Start SDP handshake.
      webrtc.RTCSessionDescription offer = await _pc!.createOffer({
        'mandatory': {
          'OfferToReceiveAudio': false,
          'OfferToReceiveVideo': false
        },
      });
      await _pc!.setLocalDescription(offer);
      final sdpList = offer.sdp!.split('\r\n');
      final index = sdpList.indexWhere((e) => e.contains('a=rtpmap'));
      sdpList[index] = 'a=rtpmap:0 PCMU/8000';
      final sdp = sdpList.join('\r\n').replaceAll('SAVPF', 'SAVPF 0');
      // info(
      //     'WebRTC: createOffer, ${offer.type} is ${offer.sdp?.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}');

      webrtc.RTCSessionDescription? answer = await _handshake(url, sdp);

      // info(
      //     'WebRTC: got ${answer?.type} is ${answer?.sdp?.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}');

      if (answer != null) {
        _pc!.setRemoteDescription(answer);
        // info('WebRTC: setRemoteDescription');
        _onConnectionState?.call(
            webrtc.RTCPeerConnectionState.RTCPeerConnectionStateConnecting);
      } else {
        _onConnectionState
            ?.call(webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed);
      }
    } catch (e) {
      _onConnectionState
          ?.call(webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed);
    }
  }

  /// Handshake to exchange SDP, send offer and got answer.
  Future<webrtc.RTCSessionDescription?> _handshake(
      String url, String? offer) async {
    // Setup the client for HTTP or HTTPS.
    HttpClient client = HttpClient();

    try {
      // Allow self-sign certificate, see https://api.flutter.dev/flutter/dart-io/HttpClient/badCertificateCallback.html
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      // Parsing the WebRTC uri form url.
      _WebRTCUri uri = _WebRTCUri.parse(url);

      // Do signaling for WebRTC.
      // @see https://github.com/rtcdn/rtcdn-draft
      //
      // POST http://d.ossrs.net:11985/rtc/v1/play/
      //    {api: "xxx", sdp: "offer", streamurl: "webrtc://d.ossrs.net:11985/live/livestream"}
      // Response:
      //    {code: 0, sdp: "answer", sessionid: "007r51l7:X2Lv"}
      HttpClientRequest req = await client.postUrl(Uri.parse(uri.api));
      req.headers.set('Content-Type', 'application/json');
      req.add(utf8.encode(json
          .encode({'api': uri.api, 'streamurl': uri.streamUrl, 'sdp': offer})));
      // info('WebRTC request: ${uri.api} offer=${offer?.length}B');

      HttpClientResponse res = await req.close();
      String reply = await res.transform(utf8.decoder).join();
      // info('WebRTC reply: ${reply.length}B, ${res.statusCode}');

      Map<String, dynamic> o = json.decode(reply);
      // info('WebRTC reply: ${o.toString()}');
      if (!o.containsKey('code') || !o.containsKey('sdp') || o['code'] != 0) {
        throw Future.error(reply);
      }

      return Future.value(webrtc.RTCSessionDescription(o['sdp'], 'answer'));
    } catch (error) {
      return null;
    } finally {
      client.close();
    }
  }

  /// Dispose the player.
  void dispose() {
    _onConnectionState = null;
    _pc?.close();
    _pc = null;
  }
}

class _WebRTCUri {
  /// The api server url for WebRTC streaming.
  String api;

  /// The stream url to play or publish.
  String streamUrl;

  _WebRTCUri({
    required this.api,
    required this.streamUrl,
  });

  /// Parse the url to WebRTC uri.
  static _WebRTCUri parse(String url) {
    Uri uri = Uri.parse(url);

    var schema = 'https'; // For native, default to HTTPS
    if (uri.queryParameters.containsKey('schema')) {
      schema = uri.queryParameters['schema']!;
    }

    var port = (uri.port > 0) ? uri.port : 443;
    if (schema == 'https') {
      port = (uri.port > 0) ? uri.port : 443;
    } else if (schema == 'http') {
      port = (uri.port > 0) ? uri.port : 1985;
    }

    var api = '/rtc/v1/publish/';
    if (uri.queryParameters.containsKey('publish')) {
      api = uri.queryParameters['publish']!;
    }

    var apiParams = [];
    for (var key in uri.queryParameters.keys) {
      if (key != 'api' && key != 'publish' && key != 'schema') {
        apiParams.add('$key=${uri.queryParameters[key]}');
      }
    }

    var apiUrl = '$schema://${uri.host}:$port$api';
    if (apiParams.isNotEmpty) {
      apiUrl += '?${apiParams.join('&')}';
    }

    _WebRTCUri r = _WebRTCUri(api: apiUrl, streamUrl: url);
    print('Url:$url\napi:${r.api}\nstream:${r.streamUrl}');
    return r;
  }
}
