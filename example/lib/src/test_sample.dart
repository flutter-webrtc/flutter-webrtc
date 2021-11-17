import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class TestSample extends StatefulWidget {
  static String tag = 'test_sample';

  @override
  _TestSampleState createState() => _TestSampleState();
}

class _TestSampleState extends State<TestSample> {
  String text = 'Press call button';

  @override
  void initState() {
    super.initState();
  }

  void _getSystemTime() async {
    var a = await WebRTC.invokeMethod('getSystemTime', text);
    setState(() {
      text = 'System time: ' + a;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _getSystemTime,
        child: Icon(Icons.phone),
      ),
    );
  }
}
