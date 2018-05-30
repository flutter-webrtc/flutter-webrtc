import 'package:flutter/material.dart';
import 'package:webrtc/rtc_peerconnection.dart';
import 'package:webrtc/rtc_peerconnection_factory.dart';
import 'package:webrtc/media_stream.dart';
import 'package:webrtc/get_user_media.dart';
import 'package:webrtc/rtc_session_descrption.dart';
import 'package:webrtc/rtc_video_view.dart';
import 'package:webrtc/rtc_ice_candidate.dart';
import 'dart:async';
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

  @override
  initState() {
    super.initState();
    initPlatformState();
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
  initPlatformState() async {
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

    final Map<String, dynamic> OFFER_SDP_CONSTRAINTS = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    final Map<String, dynamic> LOOPBACK_CONSTRAINTS = {
      "mandatory": {},
      "optional": [
        {"DtlsSrtpKeyAgreement": false},
      ],
    };

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _localStream = await getUserMedia(mediaConstraints);
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _localRenderer.srcObject = _localStream;

      _peerConnection =
          await createPeerConnection(configuration, LOOPBACK_CONSTRAINTS);

      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

      _peerConnection.addStream(_localStream);
      RTCSessionDescrption description =
          await _peerConnection.createOffer(OFFER_SDP_CONSTRAINTS);
      print(description.sdp);
      _peerConnection.setLocalDescription(description);
      //change for loopback.
      description.type = 'answer';
      _peerConnection.setRemoteDescription(description);
    } catch (e) {
      //'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {});
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
                decoration: new BoxDecoration(color: Colors.black),

                child: new Stack(
                  children: <Widget>[
                    new Align(
                      alignment: orientation == Orientation.portrait ? const FractionalOffset(0.5, 0.1):const FractionalOffset(0.0, 0.5),
                      child: new Container(
                        width: 320.0,
                        height: 240.0,
                        child: new RTCVideoView(_localRenderer),
                        decoration: new BoxDecoration(color: Colors.black54),
                      ),
                    ),
                    new Align(
                      alignment: orientation == Orientation.portrait ? const FractionalOffset(0.5, 0.9):const FractionalOffset(1.0, 0.5),
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
      ),
    );
  }
}
