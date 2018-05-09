import 'package:flutter/material.dart';
import 'package:webrtc/RTCPeerConnection.dart';
import 'package:webrtc/RTCPeerConnectionFactory.dart';
import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/getUserMedia.dart';
import 'package:webrtc/RTCSessionDescrption.dart';
import 'package:webrtc/RTCVideoView.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MediaStream _localStream;
  RTCPeerConnection _peerConnection;
  String _version = "0.0.1";
  final _controller = new RTCVideoViewController();
  final _width = 200.0;
  final _height = 200.0;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  _onAddStream(MediaStream stream)
  {

  }

  _onRemoveStream(MediaStream stream){

  }

  AddStreamCallback onAddStream;
  RemoveStreamCallback onRemoveStream;
  AddTrackCallback onAddTrack;
  RemoveTrackCallback onRemoveTrack;

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion = '';
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth": 640, // Provide your own width, height and frame rate here
          "minHeight": 360,
          "maxWidth": 640, // Provide your own width, height and frame rate here
          "maxHeight": 360,
          "minFrameRate": 30,
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

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _localStream = await getUserMedia(mediaConstraints);
      await _controller.initialize(_width, _height);
      platformVersion = _localStream.id;
      _peerConnection = await createPeerConnection(configuration);
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
      RTCSessionDescrption description = await _peerConnection.createOffer(Map<String, dynamic>());
      _peerConnection.setLocalDescription(description);
    } catch(e) {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _version = platformVersion;
      _controller.srcObject = _localStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Container(
            width: _width,
            height: _height,
            child: _controller.isInitialized
                ? new Texture(textureId: _controller.renderId)
                : null,
          //child: new Text('Running on: $_version\n'),
        ),
      ),
    );
  }
}
