import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'dart:core';
import 'dart:async';

/*
 * getDisplayMedia sample
 */
class GetDisplayMediaSample extends StatefulWidget {
  static String tag = 'get_display_media_sample';

  @override
  _GetDisplayMediaSampleState createState() =>
      new _GetDisplayMediaSampleState();
}

class _GetDisplayMediaSampleState extends State<GetDisplayMediaSample> {
  MediaStream _localStream;
  final _localRenderer = new RTCVideoRenderer();
  bool _inCalling = false;
  Timer _timer;
  var _counter = 0;

  @override
  initState() {
    super.initState();
    initRenderers();
  }

  @override
  deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    if (_timer != null) _timer.cancel();
    _localRenderer.dispose();
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  void handleTimer(Timer timer) async {
    setState(() {
      _counter++;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  _makeCall() async {
    final Map<String, dynamic> mediaConstraints = {
      "audio": false,
      "video": true
    };

    try {
      var stream = await navigator.getDisplayMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });

    _timer = new Timer.periodic(Duration(milliseconds: 100), handleTimer);
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
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GetUserMedia API Test'),
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: new Stack(children: <Widget>[
              new Center(
                child: new Text('counter: ' + _counter.toString()),
              ),
              new Container(
                margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RTCVideoView(_localRenderer),
                decoration: new BoxDecoration(color: Colors.black54),
              )
            ]),
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
