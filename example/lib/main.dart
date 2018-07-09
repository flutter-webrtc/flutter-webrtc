import 'package:flutter/material.dart';
import 'dart:core';
import 'src/basic_sample/basic_sample.dart';
import 'src/call_sample/call_sample.dart';
import 'src/route_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}



class _MyAppState extends State<MyApp> {

  List<RouteItem> items;
  String _ip = '192.168.31.152';
  SharedPreferences prefs;

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


  _initData() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _ip = prefs.getString('ip') ?? '';
    });
  }

  _initItems(){

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

            showDialog<Null>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Please input server ip'),
                    children: <Widget>[
                      TextField(
                        onChanged: (String text){
                          setState(() {
                            _ip = text;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: _ip,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SimpleDialogOption(
                        onPressed: () {},
                        child: RaisedButton(
                          onPressed: () {

                            prefs.setString('ip', _ip);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => CallSample(ip:_ip)
                                ));
                          },
                          child: const Text('connect server'),
                        ),
                      ),
                    ],
                  );
                });
          }),
    ];

  }




}
