import 'package:flutter/material.dart';
import 'dart:core';
import 'loopback_sample.dart';
import 'get_user_media_sample.dart';
import 'data_channel_sample.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class Item {
  Item({
    @required this.title,
    @required this.subtitle,
    @required this.route,
  });

  final String title;
  final String subtitle;
  final String route;
}

final List<Item> items = <Item>[
  Item(
    title: 'getUserMedia',
    subtitle: 'GetUserMedia.',
    route: GetUserMediaSample.tag,
  ),
  Item(
    title: 'Loopback Sample',
    subtitle: 'Loopback Sample.',
    route: LoopBackSample.tag,
  ),
  Item(
    title: 'Data Channel Sample',
    subtitle: 'Data Channel Sample.',
    route: DataChannelSample.tag,
  ),
];

class _MyAppState extends State<MyApp> {
  final routes = <String, WidgetBuilder>{
    LoopBackSample.tag: (context) => new LoopBackSample(),
    GetUserMediaSample.tag: (context) => new GetUserMediaSample(),
    DataChannelSample.tag: (context) => new DataChannelSample(),
  };

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter-WebRTC example'),
        ),
        body: new OrientationBuilder(builder: (context, orientation) {
          return ListView(
              children: items.map((item) {
            return ListTile(
              title: Text(item.title),
              onTap: () {
                Navigator.of(context).pushNamed(item.route);
              },
            );
          }).toList());
        }),
      ),
      routes: routes,
    );
  }
}
