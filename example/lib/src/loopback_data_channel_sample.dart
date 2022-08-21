import 'dart:async';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DataChannelLoopBackSample extends StatefulWidget {
  static String tag = 'data_channel_sample';

  @override
  _DataChannelLoopBackSampleState createState() =>
      _DataChannelLoopBackSampleState();
}

class _DataChannelLoopBackSampleState extends State<DataChannelLoopBackSample> {
  RTCPeerConnection? _pc1;
  RTCPeerConnection? _pc2;

  bool _inCalling = false;

  RTCDataChannelInit? _initDict;
  RTCDataChannel? _dc1;
  RTCDataChannel? _dc2;

  String _dc1Status = '';
  String _dc2Status = '';

  @override
  void initState() {
    super.initState();
  }

  void _makeCall() async {
    if (_pc1 != null || _pc2 != null) return;

    try {
      _pc1 = await createPeerConnection({'iceServers': []});
      _pc2 = await createPeerConnection({'iceServers': []});

      _pc1!.onIceCandidate = (candidate) {
        print('pc1: onIceCandidate: ${candidate.candidate}');
        _pc2!.addCandidate(candidate);
      };

      _pc2!.onIceCandidate = (candidate) {
        print('pc2: onIceCandidate: ${candidate.candidate}');
        _pc1!.addCandidate(candidate);
      };

      _initDict = RTCDataChannelInit();
      _initDict!.id = 1;
      _initDict!.ordered = true;
      _initDict!.maxRetransmitTime = -1;
      _initDict!.maxRetransmits = -1;
      _initDict!.protocol = 'sctp';
      _initDict!.negotiated = false;

      _dc1 = await _pc1!.createDataChannel('pc1-dc', _initDict!);

      _pc2!.onDataChannel = (channel) {
        _dc2 = channel;
        _dc2!.onDataChannelState = (state) {
          setState(() {
            _dc2Status += '\ndc2: state: ${state.toString()}';
          });
        };
        _dc2!.onMessage = (data) {
          setState(() {
            _dc2Status += '\ndc2: Received message: ${data.text}';
          });
          _dc2!.send(RTCDataChannelMessage('(2) Hello from dc2 echo !!!'));
        };

        _dc1!.send(RTCDataChannelMessage('(1) Hello from dc1!!!'));
      };

      _dc1!.onDataChannelState = (state) {
        setState(() {
          _dc1Status += '\ndc1: state: ${state.toString()}';
        });
      };

      _dc1!.onMessage = (data) => setState(() {
            _dc1Status += '\ndc1: Received message: ${data.text}';
          });

      var offer = await _pc1!.createOffer({});
      print('pc1 offer: ${offer.sdp}');

      await _pc2!.setRemoteDescription(offer);
      var answer = await _pc2!.createAnswer();
      print('pc2 answer: ${answer.sdp}');

      await _pc1!.setLocalDescription(offer);
      await _pc2!.setLocalDescription(answer);

      await _pc1!.setRemoteDescription(answer);
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _hangUp() async {
    try {
      await _dc1?.close();

      setState(() {
        _dc1Status += '\n _dc1.close()';
      });

      await _pc1?.close();
      await _pc2?.close();
      _pc1 = null;
      _pc2 = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });

    Timer(const Duration(seconds: 1), () {
      setState(() {
        _dc1Status = '';
        _dc2Status = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Channel Test'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('(caller)data channel 1:\n'),
              Container(
                child: Text(_dc1Status),
              ),
              Text('\n\n(callee)data channel 2:\n'),
              Container(
                child: Text(_dc2Status),
              ),
            ],
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
