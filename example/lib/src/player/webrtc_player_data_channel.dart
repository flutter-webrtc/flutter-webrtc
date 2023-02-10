import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCDataChannel {
  webrtc.RTCPeerConnection? _pc;
  webrtc.RTCDataChannel? _dc;
  Function(webrtc.RTCPeerConnectionState state)? _onConnectionState;
  Function(webrtc.RTCDataChannelState state)? _onDataChannelState;
  Function(Uint8List)? _onDataChannelMessage;

  set onConnectionState(Function(webrtc.RTCPeerConnectionState state) s) =>
      _onConnectionState = s;

  set onDataChannelState(Function(webrtc.RTCDataChannelState state) s) =>
      _onDataChannelState = s;

  set onDataChannelMessage(Function(Uint8List message) m) =>
      _onDataChannelMessage = m;

  /// Initialize the player.
  void initState() {}

  List<webrtc.MediaStream?>? get remoteStreams => _pc?.getRemoteStreams();
  webrtc.MediaStream? getRemoteStream(String streamId) =>
      remoteStreams?.firstWhere((element) => element?.id == streamId);

  Future<List<webrtc.StatsReport>>? getStats(
          [webrtc.MediaStreamTrack? track]) =>
      _pc?.getStats(track);

  /// Start play a url.
  /// [url] must a path parsed by [WebRTCUri.parse] in https://github.com/rtcdn/rtcdn-draft
  Future<void> dataChannel(String url, int bitRate) async {
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

    _dc = await _pc!.createDataChannel('label', RTCDataChannelInit());
    if (_dc == null) {
      _onConnectionState
          ?.call(webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed);
      return;
    }
    print('WebRTC: createDataChannel done');

    _pc!.onConnectionState = (webrtc.RTCPeerConnectionState state) {
      print("==================== RTCPeerConnectionState = $state");
      _onConnectionState?.call(state);
    };

    _pc!.onIceConnectionState = (webrtc.RTCIceConnectionState state) {
      print("==================== RTCIceConnectionState = $state");
    };

    _pc!.onDataChannel = (webrtc.RTCDataChannel event) {
      print("==================== RTCDataChannel = $event");
    };

    _dc!.onDataChannelState = (webrtc.RTCDataChannelState state) {
      print("==================== RTCDataChannelState = $state");
      _onDataChannelState?.call(state);
    };

    _dc!.onMessage = (webrtc.RTCDataChannelMessage event) {
      print('Got Data Channel Message: ${event.type}');
      // info('Got Data Channel Message: ${event.binary}');
      _onDataChannelMessage?.call(event.binary);
    };

    // Start SDP handshake.
    webrtc.RTCSessionDescription offer = await _pc!.createOffer({
      'mandatory': {'OfferToReceiveAudio': false, 'OfferToReceiveVideo': false},
    });
    await _pc!.setLocalDescription(offer);

    webrtc.RTCSessionDescription? answer =
        await _handshake(url, offer.sdp, bitRate);

    if (answer != null) {
      await _pc!.setRemoteDescription(answer);
      print('WebRTC: setRemoteDescription');
      _onConnectionState?.call(
          webrtc.RTCPeerConnectionState.RTCPeerConnectionStateConnecting);
    } else {
      _onConnectionState
          ?.call(webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed);
    }
  }

  /// Handshake to exchange SDP, send offer and got answer.
  Future<webrtc.RTCSessionDescription?> _handshake(
      String url, String? offer, int bitRate) async {
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
      req.add(utf8.encode(json.encode({
        'api': uri.api,
        'streamurl': uri.streamUrl,
        'sdp': offer,
        "bitrate": bitRate
      })));
      print('WebRTC request: ${uri.api} offer=${offer?.length}B');

      HttpClientResponse res = await req.close();
      String reply = await res.transform(utf8.decoder).join();
      print('WebRTC reply: ${reply.length}B, ${res.statusCode}');

      Map<String, dynamic> o = json.decode(reply);
      print('WebRTC reply: ${o.toString()}');
      if (!o.containsKey('code') || !o.containsKey('sdp') || o['code'] != 0) {
        return Future.error(reply);
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
    print('WebRTC Data Channel dispose====================================');
    _onDataChannelMessage = null;
    _onDataChannelState = null;
    _dc?.close();
    _dc = null;
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

    var api = '/rtc/v1/data/';
    if (uri.queryParameters.containsKey('data')) {
      api = uri.queryParameters['data']!;
    }

    var apiParams = [];
    for (var key in uri.queryParameters.keys) {
      if (key != 'api' && key != 'data' && key != 'schema') {
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
