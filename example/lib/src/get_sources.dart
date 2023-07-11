import 'dart:core';

import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';

class GetSourcesSample extends StatefulWidget {
  static String tag = 'get_sources_sample';

  const GetSourcesSample({Key? key}) : super(key: key);

  @override
  State<GetSourcesSample> createState() => _GetSourcesSampleState();
}

class _GetSourcesSampleState extends State<GetSourcesSample> {
  String text = 'Press call button to enumerate devices';

  @override
  void initState() {
    super.initState();
  }

  void _getSources() async {
    var mediaDeviceInfos = await enumerateDevices();
    var mediaDisplayInfos = await enumerateDisplays();
    setState(() {
      var devicesInfo = '';
      for (var device in mediaDeviceInfos) {
        devicesInfo +=
            'Kind: ${device.kind}\nName: ${device.label}\nId: ${device.deviceId}\n\n';
      }
      for (var display in mediaDisplayInfos) {
        devicesInfo +=
            'Kind(ScreenCapture): ${MediaDeviceKind.videoinput}\nTitle: ${display.title.toString()}\nId: ${display.deviceId}\n\n';
      }
      text = devicesInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('getSources'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _getSources,
        child: const Icon(Icons.phone),
      ),
    );
  }
}
