import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/basic_sample/basic_sample.dart';
import 'src/call_sample/call_sample.dart';
import 'src/call_sample/data_channel_sample.dart';
import 'src/route_item.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

enum DialogDemoAction {
  cancel,
  connect,
}

class _MyAppState extends State<MyApp> {
  List<RouteItem> items;
  Uri _server;
  SharedPreferences _prefs;

  bool _datachannel = false;
  @override
  initState() {
    super.initState();
    _initData();
    _initItems();
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

  _initData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _server = Uri.parse(_prefs.getString('server') ?? 'https://demo.cloudwebrtc.com:8086');
    });
  }

  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        if (value == DialogDemoAction.connect) {
          _prefs.setString('server', _server.toString());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => _datachannel
                      ? DataChannelSample(uri: _server)
                      : CallSample(uri: _server)));
        }
      }
    });
  }

  _showAddressDialog(context) {
    showDemoDialog<DialogDemoAction>(
        context: context,
        child: new AlertDialog(
            title: const Text('Enter server address:'),
            content: TextField(
              onChanged: (String text) {
                setState(() {
                  _server = Uri.parse(text) ;
                });
              },
              decoration: InputDecoration(
                hintText: _server.toString(),
              ),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.cancel);
                  }),
              new FlatButton(
                  child: const Text('CONNECT'),
                  onPressed: () {
                    Navigator.pop(context, DialogDemoAction.connect);
                  })
            ]));
  }

  _initItems() {
    items = <RouteItem>[
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
            _datachannel = false;
            _showAddressDialog(context);
          }),
      RouteItem(
          title: 'Data Channel Sample',
          subtitle: 'P2P Data Channel.',
          push: (BuildContext context) {
            _datachannel = true;
            _showAddressDialog(context);
          }),
    ];
  }
}
