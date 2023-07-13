import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CaptureFrameSample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CaptureFrameSample();
}

class _CaptureFrameSample extends State<CaptureFrameSample> {
  Uint8List? _data;

  void _captureFrame() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': false,
      'video': true,
    });

    final track = stream.getVideoTracks().first;
    final buffer = await track.captureFrame();

    stream.getTracks().forEach((track) => track.stop());

    setState(() {
      _data = buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Frame'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureFrame,
        child: Icon(Icons.camera_alt_outlined),
      ),
      body: Builder(builder: (context) {
        final data = _data;

        if (data == null) {
          return Container();
        }
        return Center(
          child: Image.memory(
            data,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }),
    );
  }
}
