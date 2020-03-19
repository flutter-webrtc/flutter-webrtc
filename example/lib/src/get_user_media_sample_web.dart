// ignore: uri_does_not_exist
import 'dart:html' as HTML;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc/web/get_user_media.dart' as gum;
import 'dart:core';

/*
 * getUserMedia sample
 */
class GetUserMediaSample extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  @override
  _GetUserMediaSampleState createState() => new _GetUserMediaSampleState();
}

class _GetUserMediaSampleState extends State<GetUserMediaSample> {
  MediaStream _localStream;
  final _localRenderer = new RTCVideoRenderer();
  bool _inCalling = false;
  MediaRecorder _mediaRecorder;
  get _isRec => _mediaRecorder != null;
  List<dynamic> cameras;

  @override
  initState() {
    super.initState();
    initRenderers();
    gum.navigator.getSources().then((md) {
      setState(() {
        cameras = md.where((d) => d['kind'] == 'videoinput');
      });
    });
  }

  @override
  deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  _makeCall() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": true,
      "video": {
        "mandatory": {
          "minWidth":
              '1280', // Provide your own width, height and frame rate here
          "minHeight": '720',
          "minFrameRate": '30',
        },
      }
    };

    try {
      var stream = await navigator.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
      _localRenderer.mirror = true;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  _hangUp() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  _startRecording() async {
    _mediaRecorder = MediaRecorder();
    setState(() {});
    _mediaRecorder.startWeb(_localStream);
  }

  _stopRecording() async {
    final objectUrl = await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
    print(objectUrl);
    HTML.window.open(objectUrl, '_blank');
  }

  _captureFrame() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == "video");
    final frame = await videoTrack.captureFrame();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Image.network(frame, height: 720, width: 1280),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: Navigator.of(context, rootNavigator: true).pop,
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GetUserMedia API Test'),
        actions: _inCalling
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: _captureFrame,
                ),
                IconButton(
                  icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
                  onPressed: _isRec ? _stopRecording : _startRecording,
                ),
              ]
            : null,
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: new Container(
              margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer),
              decoration: new BoxDecoration(color: Colors.black54),
            ),
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: new Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
