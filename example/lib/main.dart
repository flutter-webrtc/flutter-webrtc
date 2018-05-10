import 'package:flutter/material.dart';
import 'package:webrtc/RTCPeerConnection.dart';
import 'package:webrtc/RTCPeerConnectionFactory.dart';
import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/getUserMedia.dart';
import 'package:webrtc/RTCSessionDescrption.dart';
import 'package:webrtc/RTCVideoView.dart';
import 'package:webrtc/RTCIceCandidate.dart';
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
  final _localVideoView = new RTCVideoViewController();
  final _remoteVideoView = new RTCVideoViewController();
  final _width = 200.0;
  final _height = 200.0;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  _onAddStream(MediaStream stream)
  {
      _remoteVideoView.srcObject = stream;
  }

  _onRemoveStream(MediaStream stream){
     _remoteVideoView.srcObject = null;
  }

  _onCandidate(RTCIceCandidate candidate){
    _peerConnection.addCandidate(candidate);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth": '640', // Provide your own width, height and frame rate here
          "minHeight": '360',
          "minFrameRate": '30',
        },
        "facingMode": "user",
        "optional": [],
      }
    };
    /*
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": true,
    };*/
    Map<String, dynamic> configuration = { 
      "iceServers": [
          { "url" : "stun:stun.l.google.com:19302"},
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
        {"DtlsSrtpKeyAgreement": false },
      ],
    };

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _localStream = await getUserMedia(mediaConstraints);
      await _localVideoView.initialize(_width, _height);
      await _remoteVideoView.initialize(_width, _height);

      _peerConnection = await createPeerConnection(configuration, LOOPBACK_CONSTRAINTS);
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.addStream(_localStream);
      RTCSessionDescrption description = await _peerConnection.createOffer(OFFER_SDP_CONSTRAINTS);
      _peerConnection.setLocalDescription(description);
      //change for loopback.
      description.type = 'answer';
      _peerConnection.setRemoteDescription(description);
    } catch(e) {
       //'Failed to get platform version.';
    }
    if (!mounted)
      return;

    setState(() {
      _localVideoView.srcObject = _localStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter-WebRTC example'),
        ),
        body: new Center( child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text('WebRTC loopback demo.'),
                        new Container(
                            width: _width,
                            height: _height,
                            child: _localVideoView.isInitialized
                                ? new Texture(textureId: _localVideoView.renderId)
                                : null,
                        ),
                        new Text('Local video'),
                        new Container(
                            width: _width,
                            height: _height,
                            child: _remoteVideoView.isInitialized
                                ? new Texture(textureId: _remoteVideoView.renderId)
                                : null,
                        ),
                        new Text('Remote video'),
        ])
        ),
      ),
    );
  }
}
