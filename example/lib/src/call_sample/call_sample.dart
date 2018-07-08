import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:async';
import 'signaling.dart';
import 'calling_screen.dart';
import 'package:webrtc/webrtc.dart';

class CallSample extends StatefulWidget {
  static String tag = 'call_sample';
  @override
  _CallSampleState createState() => new _CallSampleState();
}

class _CallSampleState extends State<CallSample> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Signaling _signaling;
  String _roomId;
  String _displayName = "flutter";
  List<dynamic> _peers;

  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  bool _inCalling = false;
  Timer _timer;

  @override
  initState() {
    super.initState();
    initRenderers();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();
    if (_signaling != null) _signaling.close();
  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = new Signaling('ws://192.168.31.152:4442', _displayName);
      await _signaling.connect();

      _signaling.onPeers.listen((message) {
        Map<String, dynamic> mapData = message;
        List<dynamic> peers = mapData['data'];
        this.setState(() {
          _peers = peers;
        });
      });

      _signaling.onLocalStream.listen((message) {
        Map<String, dynamic> mapData = message;
        _localRenderer.srcObject = mapData['stream'];
      });

      _signaling.onRemoteStreamAdd.listen((message) {
        Map<String, dynamic> mapData = message;
        _remoteRenderer.srcObject = mapData['stream'];
      });

      _signaling.onRemoteStreamRemoved.listen((message) {
        this.setState(() {
          _inCalling = false;
          _remoteRenderer.srcObject = null;
        });
      });
    }
  }

  _invitePeer(context, peerId) {
    this.setState(() {
      _inCalling = true;
    });
    if (_signaling != null) {
      _signaling.invite(peerId, 'video');
    }
  }

  _hangUp() {
    this.setState(() {
      _inCalling = false;
    });
    if (_signaling != null) {
      _signaling.leave();
    }
  }

  _buildRow(context, peer) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(peer['name']),
        onTap: () => _invitePeer(context, peer['id']),
        trailing: Icon(Icons.video_call),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('P2P Call Sample'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _connect,
            tooltip: 'setup',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hangUp,
        tooltip: 'Hangup',
        child: new Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
      body: _inCalling
          ? new OrientationBuilder(
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
                            decoration:
                                new BoxDecoration(color: Colors.black54),
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
                            decoration:
                                new BoxDecoration(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : new ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: (_peers != null ? _peers.length : 0),
              itemBuilder: (context, i) {
                return _buildRow(context, _peers[i]);
              }),
    );
  }
}
