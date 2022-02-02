import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RendererSample extends StatefulWidget {
  const RendererSample({Key? key}) : super(key: key);

  @override
  _RendererSampleState createState() => _RendererSampleState();
}

class _RendererSampleState extends State<RendererSample> {
  MediaStream? _stream;
  final _renderer = RTCVideoRenderer();
  bool _isRendering = false;

  @override
  void initState() {
    super.initState();
    initRenderer();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_isRendering) {
      _stop();
    }
    _renderer.dispose();
  }

  void initRenderer() async {
    await _renderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _start() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {},
      }
    };

    try {
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _stream = stream;
      _renderer.srcObject = _stream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isRendering = true;
    });
  }

  void _stop() async {
    try {
      await _stream?.dispose();
      _renderer.srcObject = null;
      setState(() {
        _isRendering = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renderer'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: Colors.black54),
              child: RTCVideoView(_renderer, mirror: true),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRendering ? _stop : _start,
        tooltip: _isRendering ? 'Stop' : 'Start',
        child: Icon(_isRendering ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
