import 'package:flutter/material.dart';
import 'package:webrtc/RTCPeerConnection.dart';
import 'package:webrtc/MediaStream.dart';
import 'package:webrtc/getUserMedia.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MediaStream _localStream;
  RTCPeerConnection _peerConnection;
  String _version = "0.0.1";

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

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion = '';
    /*final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth": 640, // Provide your own width, height and frame rate here
          "minHeight": 360,
          "minFrameRate": 30,
        },
        "facingMode": "user",
        "optional": [],
      }
    };*/
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": false,
    };
    const configuration = {"iceServers": [{"url": "stun:stun.l.google.com:19302"}]};
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _localStream = await getUserMedia(mediaConstraints);
      platformVersion = _localStream.id;
      _peerConnection = new RTCPeerConnection({"iceservers":[]});
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_version\n'),
        ),
      ),
    );
  }
}
