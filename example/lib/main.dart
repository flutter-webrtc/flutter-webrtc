import 'dart:core';

import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';

import 'src/create_peer_connection.dart';
import 'src/get_display_media.dart';
import 'src/get_sources.dart';
import 'src/get_user_media.dart';
import 'src/loopback.dart';
import 'src/on_device_change.dart';
import 'src/video_codec_info.dart';
import 'src/route_item.dart';

void main() async {
  await initFfiBridge();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<RouteItem> items;

  @override
  void initState() {
    super.initState();
    _initItems();
  }

  ListBody _buildRow(context, item) {
    return ListBody(
      children: <Widget>[
        ListTile(
          title: Text(item.title),
          onTap: () => item.push(context),
          trailing: const Icon(Icons.arrow_right),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter-WebRTC example')),
        body: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(0.0),
          itemCount: items.length,
          itemBuilder: (context, i) {
            return _buildRow(context, items[i]);
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  void _initItems() {
    items = <RouteItem>[
      RouteItem(
        title: 'GetUserMedia',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const GetUserMediaSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'GetDisplayMedia',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const GetDisplayMediaSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'LoopBack Sample',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const Loopback(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'getSources',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const GetSourcesSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'Basic RtcPeerConnection',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const PeerConnectionSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'onDeviceChange notifier',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  const OnDeviceChangeNotifierSample(),
            ),
          );
        },
      ),
      RouteItem(
        title: 'Video Codec Info',
        push: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const VideoCodecInfoSample(),
            ),
          );
        },
      ),
    ];
  }
}
