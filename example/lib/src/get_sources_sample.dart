import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GetSourcesSample extends StatefulWidget {
  static String tag = 'get_sources_sample';

  @override
  _GetSourcesSampleState createState() => _GetSourcesSampleState();
}

class _GetSourcesSampleState extends State<GetSourcesSample> {
  String text = 'Press call button to enumerate devices';

  @override
  void initState() {
    super.initState();
  }

  void _getSources() async {
    var mediaDeviceInfos = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      var devicesInfo = '';
      mediaDeviceInfos.forEach((device) { devicesInfo = devicesInfo + 'Kind: ${device.kind}\nName: ${device.label}\nId: ${device.deviceId}\n\n'; });
      text = devicesInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('getSources'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _getSources,
        child: Icon(Icons.phone),
      ),
    );
  }
}
