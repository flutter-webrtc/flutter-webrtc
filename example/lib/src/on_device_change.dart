import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class OnDeviceChangeNotifierSample extends StatefulWidget {
  const OnDeviceChangeNotifierSample({Key? key}) : super(key: key);

  @override
  State<OnDeviceChangeNotifierSample> createState() => _State();
}

class _State extends State<OnDeviceChangeNotifierSample> {
  int count = 0;
  String text = 'Add devices!!!';

  @override
  void initState() {
    super.initState();

    onDeviceChange(() {
      count++;

      setState(() {
        text = 'Events: $count.';
      });
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
        title: const Text('Notifier'),
      ),
      body: Center(child: Text(text)),
    );
  }
}
