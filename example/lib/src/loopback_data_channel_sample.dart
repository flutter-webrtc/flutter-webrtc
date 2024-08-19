import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DataChannelLoopBackSample extends StatefulWidget {
  static String tag = 'data_channel_sample';

  @override
  _DataChannelLoopBackSampleState createState() =>
      _DataChannelLoopBackSampleState();
}

class _DataChannelLoopBackSampleState extends State<DataChannelLoopBackSample> {
  RTCPeerConnection? _peerConnection1;
  RTCPeerConnection? _peerConnection2;
  RTCDataChannel? _dataChannel1;
  RTCDataChannel? _dataChannel2;
  String _dataChannel1Status = '';
  String _dataChannel2Status = '';

  bool _inCalling = false;

  void _makeCall() async {
    if (_peerConnection1 != null || _peerConnection2 != null) return;

    try {
      _peerConnection1 = await createPeerConnection({'iceServers': []});
      _peerConnection2 = await createPeerConnection({'iceServers': []});

      _peerConnection1!.onIceCandidate = (candidate) {
        print('peerConnection1: onIceCandidate: ${candidate.candidate}');
        _peerConnection2!.addCandidate(candidate);
      };

      _peerConnection2!.onIceCandidate = (candidate) {
        print('peerConnection2: onIceCandidate: ${candidate.candidate}');
        _peerConnection1!.addCandidate(candidate);
      };

      _dataChannel1 = await _peerConnection1!.createDataChannel(
          'peerConnection1-dc', RTCDataChannelInit()..id = 1);

      _peerConnection2!.onDataChannel = (channel) {
        _dataChannel2 = channel;
        _dataChannel2!.onDataChannelState = (state) {
          setState(() {
            _dataChannel2Status += '\ndataChannel2: state: ${state.toString()}';
          });
        };
        _dataChannel2!.onMessage = (data) {
          setState(() {
            _dataChannel2Status +=
                '\ndataChannel2: Received message: ${data.text}';
          });
          _dataChannel2!.send(RTCDataChannelMessage(
              '(dataChannel2 ==> dataChannel1) Hello from dataChannel2 echo !!!'));
        };
      };

      _dataChannel1!.onDataChannelState = (state) {
        setState(() {
          _dataChannel1Status += '\ndataChannel1: state: ${state.toString()}';
        });
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          _dataChannel1!.send(RTCDataChannelMessage(
              '(dataChannel1 ==> dataChannel2) Hello from dataChannel1 !!!'));
        }
      };

      _dataChannel1!.onMessage = (data) => setState(() {
            _dataChannel1Status +=
                '\ndataChannel1: Received message: ${data.text}';
          });

      var offer = await _peerConnection1!.createOffer({});
      print('peerConnection1 offer: ${offer.sdp}');

      await _peerConnection2!.setRemoteDescription(offer);
      var answer = await _peerConnection2!.createAnswer();
      print('peerConnection2 answer: ${answer.sdp}');

      await _peerConnection1!.setLocalDescription(offer);
      await _peerConnection2!.setLocalDescription(answer);

      await _peerConnection1!.setRemoteDescription(answer);
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
      await _dataChannel1?.close();
      setState(() {
        _dataChannel1Status += '\n _dataChannel1.close()';
      });
      await _dataChannel2?.close();
      await _peerConnection1?.close();
      await _peerConnection2?.close();
      _peerConnection1 = null;
      _peerConnection2 = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _dataChannel1Status = '';
          _dataChannel2Status = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Channel Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('(caller)data channel 1:\n'),
            Container(
              child: Text(_dataChannel1Status),
            ),
            Text('\n\n(callee)data channel 2:\n'),
            Container(
              child: Text(_dataChannel2Status),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
