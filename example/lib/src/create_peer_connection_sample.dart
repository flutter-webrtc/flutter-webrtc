import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnectionSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _PeerConnectionSampleState createState() => _PeerConnectionSampleState();
}

class _PeerConnectionSampleState extends State<PeerConnectionSample> {
  String text = 'Press call button to test create PeerConnection';
  MediaStream? _stream;
  @override
  void initState() {
    super.initState();
  }

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {},
    'optional': [],
  };

  void _create_peer() async {
    try {
      final mediaConstraints = <String, dynamic>{
        'audio': false,
        'video': {
          'mandatory': {
            'minWidth':
                '640', // Provide your own width, height and frame rate here
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      _stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      var pc1 = await createPeerConnection({
        'iceTransportPolicy': 'all',
        'bundlePolicy': 'maxbundle',
        'servers': [
          {
            'urls': ['stun:stun.l.google.com:19302'],
            'username': 'username',
            'password': 'password'
          }
        ]
      });
      var pc2 = await createPeerConnection({});

      final icecb = (RTCIceConnectionState state) {
        print(state.toString());
      };

      final pccb = (RTCPeerConnectionState state) {
        print(state.toString());
      };

      pc1.onIceConnectionState = pc2.onIceConnectionState = icecb;
      pc1.onConnectionState = pc2.onConnectionState = pccb;

      var init = RTCRtpTransceiverInit();
      init.direction = TransceiverDirection.SendOnly;
      var trans = await pc1.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

      await trans.sender.replaceTrack(_stream!.getVideoTracks()[0]);

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer({});
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);

      pc1.onIceCandidate = (RTCIceCandidate candidate) async {
        print(candidate.candidate.toString());
        await pc2.addCandidate(candidate);
      };

      pc2.onIceCandidate = (RTCIceCandidate candidate) async {
        print(candidate.candidate.toString());
        await pc1.addCandidate(candidate);
      };

      setState(() {
        text = 'test is success';
      });
    } catch (e) {
      setState(() {
        text = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PeerConnection'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _create_peer,
        child: Icon(Icons.phone),
      ),
    );
  }
}
