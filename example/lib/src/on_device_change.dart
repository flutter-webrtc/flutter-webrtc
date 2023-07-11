import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';

class OnDeviceChangeNotifierSample extends StatefulWidget {
  const OnDeviceChangeNotifierSample({Key? key}) : super(key: key);

  @override
  State<OnDeviceChangeNotifierSample> createState() => _State();
}

class _State extends State<OnDeviceChangeNotifierSample> {
  int count = 0;
  String text = 'Add devices!!!';
  String counterText = 'Events count: 0.';

  @override
  void initState() {
    super.initState();

    onDeviceChange(() {
      _handleOnDeviceChange();
    });
  }

  void _handleOnDeviceChange() async {
    count++;
    var mediaDeviceInfos = await enumerateDevices();
    var mediaDisplayInfos = await enumerateDisplays();

    setState(() {
      counterText = 'Events count: $count.';

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
  void dispose() {
    onDeviceChange(null);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(counterText),
      ),
      body: Center(child: Text(text)),
    );
  }
}
