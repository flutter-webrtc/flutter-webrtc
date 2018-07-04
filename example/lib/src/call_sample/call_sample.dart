import 'package:flutter/material.dart';
import 'dart:core';
import 'settings.dart';
import 'signaling.dart';

class CallSample extends StatefulWidget {
  static String tag = 'call_sample';
  @override
  _CallSampleState createState() => new _CallSampleState();
}

class _CallSampleState extends State<CallSample> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Signaling _signaling;
  String _roomId;
  String _displayName = "flutter";
  @override
  initState() {
    super.initState();
  }

  @override
  deactivate() {
    super.deactivate();
  }

  void _connect() {
     if(_signaling == null){
        _signaling = new Signaling('localhost:8088', _displayName);
     }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('P2P Call Sample'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
            Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new CallSettings())),
            tooltip: 'setup',
          ),
        ],
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: new Padding(
                    padding: new EdgeInsets.only(
                        top:100.0, bottom: 0.0, left: 20.0, right: 20.0),
                    child: new Form(
                        key: _formKey,
                        child: new Column(children: <Widget>[
                          new Padding(
                              padding: new EdgeInsets.only(bottom: 24.0),
                              child: new TextField(
                                  decoration: InputDecoration(
                                      labelText: 'Enter room id'),
                                  onChanged: (String value) {
                                    _roomId = value;
                                  })),
                          new Row(children: <Widget>[
                            new RaisedButton(
                                child: new Text('Connect'),
                                onPressed: _connect,
                              )
                          ])
                        ])))

          );
        },
      ),
    );
  }
}
