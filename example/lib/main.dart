import 'package:flutter/material.dart';
import 'package:webrtc/rtc_peerconnection.dart';
import 'package:webrtc/rtc_peerconnection_factory.dart';
import 'package:webrtc/media_stream.dart';
import 'package:webrtc/get_user_media.dart';
import 'package:webrtc/rtc_session_description.dart';
import 'package:webrtc/rtc_video_view.dart';
import 'package:webrtc/rtc_ice_candidate.dart';
import 'dart:core';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MediaStream _localStream;
  RTCPeerConnection _peerConnection;
  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  bool incalling = false;

  @override
  initState() {
    super.initState();
    initRenderers();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _onSignalingState(RTCSignalingState state) {
    print(state);
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    print(state);
  }

  _onIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  _onAddStream(MediaStream stream) {
    print('addStream: ' + stream.id);
    _remoteRenderer.srcObject = stream;
  }

  _onRemoveStream(MediaStream stream) {
    _remoteRenderer.srcObject = null;
  }

  _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ' + candidate.candidate);
    _peerConnection.addCandidate(candidate);
  }

  _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  _makeCall() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth":
              '640', // Provide your own width, height and frame rate here
          "minHeight": '480',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
      }
    };

    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offer_sdp_constraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    final Map<String, dynamic> loopback_constraints = {
      "mandatory": {},
      "optional": [
        {"DtlsSrtpKeyAgreement": false},
      ],
    };

    if (_peerConnection != null) return;

    try {
      _localStream = await getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      _peerConnection =
          await createPeerConnection(configuration, loopback_constraints);

      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

      _peerConnection.addStream(_localStream);
      RTCSessionDescription description =
          await _peerConnection.createOffer(offer_sdp_constraints);
      print(description.sdp);
      _peerConnection.setLocalDescription(description);
      //change for loopback.
      description.type = 'answer';
      _peerConnection.setRemoteDescription(description);
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      incalling = true;
    });
  }

  _hangUp() async {
    try {
      await _peerConnection.close();
      _peerConnection = null;
      await _localStream.dispose();
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      incalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter-WebRTC example'),
        ),
        body: new OrientationBuilder(
          builder: (context, orientation) {
            return new Center(
              child: new Container(
                decoration: new BoxDecoration(color: Colors.white),
                child: new Stack(
                  children: <Widget>[
                    new Align(
                      alignment: orientation == Orientation.portrait
                          ? const FractionalOffset(0.5, 0.1)
                          : const FractionalOffset(0.0, 0.5),
                      child: new Container(
                        width: 320.0,
                        height: 240.0,
                        child: new RTCVideoView(_localRenderer),
                        decoration: new BoxDecoration(color: Colors.black54),
                      ),
                    ),
                    new Align(
                      alignment: orientation == Orientation.portrait
                          ? const FractionalOffset(0.5, 0.9)
                          : const FractionalOffset(1.0, 0.5),
                      child: new Container(
                        width: 320.0,
                        height: 240.0,
                        child: new RTCVideoView(_remoteRenderer),
                        decoration: new BoxDecoration(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: incalling ? _hangUp : _makeCall,
          tooltip: incalling ? 'Hangup' : 'Call',
          child: new Icon(incalling ? Icons.call_end : Icons.phone),
        ),
      ),
    );
  }
}
