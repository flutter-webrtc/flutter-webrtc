import 'package:flutter/material.dart';
import 'dart:core';
import 'loopback_sample.dart';
import 'get_user_media_sample.dart';
import 'data_channel_sample.dart';
import '../route_item.dart';

typedef void RouteCallback(BuildContext context);

final List<RouteItem> items = <RouteItem>[
  RouteItem(
      title: 'GetUserMediaSample',
      push: (BuildContext context) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new GetUserMediaSample()));
      }),
  RouteItem(
      title: 'LoopBackSample',
      push: (BuildContext context) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new LoopBackSample()));
      }),
  RouteItem(
      title: 'DataChannelSample',
      push: (BuildContext context) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new DataChannelSample()));
      }),
];

class BasicSample extends StatefulWidget {
  static String tag = 'basic_sample';
  @override
  _BasicSampleState createState() => new _BasicSampleState();
}

class _BasicSampleState extends State<BasicSample> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  initState() {
    super.initState();
  }

  @override
  deactivate() {
    super.deactivate();
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
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Basic Sample'),
        ),
        body: new ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            itemCount: items.length,
            itemBuilder: (context, i) {
              return _buildRow(context, items[i]);
            }));
  }
}
