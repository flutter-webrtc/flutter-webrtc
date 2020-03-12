import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'dart:core';

class DataChannelSample extends StatefulWidget {
  static String tag = 'data_channel_sample';

  @override
  _DataChannelSampleState createState() => new _DataChannelSampleState();
}

class _DataChannelSampleState extends State<DataChannelSample> {
  RTCPeerConnection _peerConnection;
  bool _inCalling = false;

  RTCDataChannelInit _dataChannelDict;
  RTCDataChannel _dataChannel;

  String _sdp;

  @override
  initState() {
    super.initState();
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

  _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ' + candidate.candidate);
    _peerConnection.addCandidate(candidate);
    setState(() {
      _sdp += '\n';
      _sdp += candidate.candidate;
    });
  }

  _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }

  /// Send some sample messages and handle incoming messages.
  _onDataChannel(RTCDataChannel dataChannel) {
    dataChannel.onMessage = (message) {
      if (message.type == MessageType.text) {
        print(message.text);
      } else {
        // do something with message.binary
      }
    };
    // or alternatively:
    dataChannel.messageStream.listen((message) {
      if (message.type == MessageType.text) {
        print(message.text);
      } else {
        // do something with message.binary
      }
    });

    dataChannel.send(RTCDataChannelMessage("Hello!"));
    dataChannel.send(RTCDataChannelMessage.fromBinary(Uint8List(5)));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  _makeCall() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": false,
        "OfferToReceiveVideo": false,
      },
      "optional": [],
    };

    final Map<String, dynamic> loopbackConstraints = {
      "mandatory": {},
      "optional": [
        {"DtlsSrtpKeyAgreement": true},
      ],
    };

    if (_peerConnection != null) return;

    try {
      _peerConnection =
          await createPeerConnection(configuration, loopbackConstraints);

      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

      _dataChannelDict = new RTCDataChannelInit();
      _dataChannelDict.id = 1;
      _dataChannelDict.ordered = true;
      _dataChannelDict.maxRetransmitTime = -1;
      _dataChannelDict.maxRetransmits = -1;
      _dataChannelDict.protocol = "sctp";
      _dataChannelDict.negotiated = false;

      _dataChannel = await _peerConnection.createDataChannel(
          'dataChannel', _dataChannelDict);
      _peerConnection.onDataChannel = _onDataChannel;

      RTCSessionDescription description =
          await _peerConnection.createOffer(offerSdpConstraints);
      print(description.sdp);
      _peerConnection.setLocalDescription(description);

      _sdp = description.sdp;
      //change for loopback.
      //description.type = 'answer';
      //_peerConnection.setRemoteDescription(description);
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
      await _dataChannel.close();
      await _peerConnection.close();
      _peerConnection = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Data Channel Test'),
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: new Container(
              child: _inCalling ? Text(_sdp) : Text('data channel test'),
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
