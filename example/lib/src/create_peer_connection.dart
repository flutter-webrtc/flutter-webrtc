// ignore_for_file: avoid_print
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnectionSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  const PeerConnectionSample({Key? key}) : super(key: key);

  @override
  State<PeerConnectionSample> createState() => _PeerConnectionSampleState();
}

class _PeerConnectionSampleState extends State<PeerConnectionSample> {
  String text = 'Press call button to test create PeerConnection';
  MediaStreamTrack? _track;
  @override
  void initState() {
    super.initState();
  }

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {},
    'optional': [],
  };

  void _createPeer() async {
    try {
      final caps = DeviceConstraints();
      caps.video.mandatory = DeviceVideoConstraints();
      caps.video.mandatory!.width = 640;
      caps.video.mandatory!.height = 480;
      caps.video.mandatory!.fps = 30;
      caps.video.mandatory!.facingMode = FacingMode.user;

      _track = (await getUserMedia(caps))[0];

      var server = IceServer(['stun:stun.l.google.com:19302']);
      var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
      var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

      pc1.onIceConnectionStateChange((IceConnectionState state) {
        print(state);
      });
      pc2.onIceConnectionStateChange((IceConnectionState state) {
        print(state);
      });

      pc1.onConnectionStateChange((PeerConnectionState state) {
        print(state);
      });
      pc2.onConnectionStateChange((PeerConnectionState state) {
        print(state);
      });

      pc1.onIceCandidateError((err) {
        print(err.errorText);
      });
      pc2.onIceCandidateError((err) {
        print(err.errorText);
      });

      var trans = await pc1.addTransceiver(
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

      await trans.sender.replaceTrack(_track!);

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer();
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);

      pc1.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await pc2.addIceCandidate(candidate);
      });

      pc2.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await pc1.addIceCandidate(candidate);
      });

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
        title: const Text('PeerConnection'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPeer,
        child: const Icon(Icons.phone),
      ),
    );
  }
}
