import 'package:flutter/material.dart';
import 'dart:core';

class CallSettings extends StatefulWidget {
  static String tag = 'call_settings';

  @override
  _CallSettingsState createState() => new _CallSettingsState();
}

class _CallSettingsState extends State<CallSettings> {
  @override
  initState() {
    super.initState();
  }

  @override
  deactivate() {
    super.deactivate();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
      ),
      body: new OrientationBuilder(
        builder: (context, orientation) {
          return new Center(
            child: Text("settings")
          );
        },
      ),
    );
  }
}
