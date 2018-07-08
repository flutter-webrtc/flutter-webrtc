import 'package:flutter/material.dart';
import 'dart:core';
import 'src/basic_sample/basic_sample.dart';
import 'src/call_sample/call_sample.dart';
import 'src/route_item.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

final List<RouteItem> items = <RouteItem>[
  RouteItem(
      title: 'Basic API Tests',
      subtitle: 'Basic API Tests.',
      push: (BuildContext context) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new BasicSample()));
      }),
  RouteItem(
      title: 'P2P Call Sample',
      subtitle: 'P2P Call Sample.',
      push: (BuildContext context) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new CallSample()));
      }),
];

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  _buildRow(context, item) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(item.title),
        onTap: () => item.push(context),
        trailing: Icon(Icons.arrow_right),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Flutter-WebRTC example'),
          ),
          body: new ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: items.length,
              itemBuilder: (context, i) {
                return _buildRow(context, items[i]);
              })),
    );
  }
}
