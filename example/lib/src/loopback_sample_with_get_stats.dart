import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LoopBackSampleWithGetStats extends StatefulWidget {
  static String tag = 'loopback_sample_with_get_stats';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LoopBackSampleWithGetStats> {
  MediaStream? _localStream;
  RTCPeerConnection? _senderPc, _receiverPc;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    _disconnect();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _connect() async {
    if (_inCalling) {
      return;
    }

    try {
      _senderPc ??=
          await createPeerConnection({'sdpSemantics': 'unified-plan'});

      _receiverPc ??=
          await createPeerConnection({'sdpSemantics': 'unified-plan'});

      _senderPc!.onIceCandidate = (candidate) {
        _receiverPc!.addCandidate(candidate);
      };

      _receiverPc!.onIceCandidate = (candidate) {
        _senderPc!.addCandidate(candidate);
      };

      _receiverPc?.onAddTrack = (stream, track) {
        _remoteRenderer.srcObject = stream;
      };

      // get user media stream
      _localStream = await navigator.mediaDevices
          .getUserMedia({'audio': true, 'video': true});
      _localRenderer.srcObject = _localStream;

      _localStream!.getTracks().forEach((track) {
        _senderPc!.addTrack(track, _localStream!);
      });

      var offer = await _senderPc?.createOffer();

      await _receiverPc?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          init:
              RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly));
      await _receiverPc?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init:
              RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly));

      await _senderPc?.setLocalDescription(offer!);
      await _receiverPc?.setRemoteDescription(offer!);
      var answer = await _receiverPc?.createAnswer({});
      await _receiverPc?.setLocalDescription(answer!);
      await _senderPc?.setRemoteDescription(answer!);
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  void _disconnect() async {
    if (!_inCalling) {
      return;
    }
    try {
      await _localStream?.dispose();
      await _senderPc?.close();
      _senderPc = null;
      await _receiverPc?.close();
      _receiverPc = null;
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _inCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      Expanded(
        child: RTCVideoView(_localRenderer, mirror: true),
      ),
      Expanded(
        child: RTCVideoView(_remoteRenderer),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('LoopBack with getStats'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              decoration: BoxDecoration(color: Colors.black54),
              child: orientation == Orientation.portrait
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widgets)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widgets),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _disconnect : _connect,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
