import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'signaling.dart';
import 'package:webrtc/webrtc.dart';

class CallSample extends StatefulWidget {
  static String tag = 'call_sample';

  final String ip;

  CallSample({Key key, @required this.ip}) : super(key: key);

  @override
  _CallSampleState createState() => new _CallSampleState(serverIP:ip);
}

class _CallSampleState extends State<CallSample> {
  Signaling _signaling;
  String _displayName = Platform.localHostname + '(' + Platform.operatingSystem + ")";
  List<dynamic> _peers;
  var _self_id;
  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  bool _inCalling = false;
  final String serverIP;

  _CallSampleState({Key key, @required this.serverIP});

  @override
  initState() {
    super.initState();
    initRenderers();
    _connect();
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
      _signaling = new Signaling('ws://' + serverIP + ':4442', _displayName)
        ..connect();

      _signaling.onStateChange = (SignalingState state) {
        switch(state){
          case SignalingState.CallStateNew:
            this.setState((){ _inCalling = true; });
            break;
          case SignalingState.CallStateBye:
            this.setState((){ _inCalling = false; });
            break;
        }
      };

      _signaling.onPeersUpdate = ((event){
        this.setState((){
          _self_id = event['self'];
          _peers = event['peers'];
        });
      });

      _signaling.onLocalStream = ((stream) {
        this.setState(() {
          _localRenderer.srcObject = stream;
        });
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        this.setState(() {
          _remoteRenderer.srcObject = null;
        });
      });
    }
  }

  _invitePeer(context, peerId) {
    if (_signaling != null && peerId != _self_id) {
      _signaling.invite(peerId, 'video');
    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  _buildRow(context, peer) {
    var self = (peer['id'] == _self_id);
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(self? peer['name'] + '[Your self]' : peer['name']+'['+peer['user_agent']+']'),
        onTap: () => _invitePeer(context, peer['id']),
        trailing: Icon(Icons.videocam),
        subtitle: Text('id: '+  peer['id']),
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
            onPressed: null,
            tooltip: 'setup',
          ),
        ],
      ),
      floatingActionButton: _inCalling? FloatingActionButton(
        onPressed: _hangUp,
        tooltip: 'Hangup',
        child: new Icon(Icons.call_end),
      ) : null,
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
