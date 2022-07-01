import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// ignore: must_be_immutable
class ScreenSelectDialog extends Dialog {
  ScreenSelectDialog() {
    Future.delayed(Duration(milliseconds: 100), () {
      _getSources(SourceType.Screen);
    });
  }
  List<DesktopCapturerSource> _sources = [];
  DesktopCapturerSource? _selected_source;
  StateSetter? _stateSetter;

  void _pop(context) {
    Navigator.pop<DesktopCapturerSource>(context, _selected_source);
  }

  Future<void> _getSources(SourceType type) async {
    try {
      var sources = await desktopCapturer.getSources(types: [type]);
      sources.forEach((element) {
        print(
            'name: ${element.name}, id: ${element.id}, type: ${element.type}');
      });
      _stateSetter?.call(() {
        _sources = sources;
      });
      return;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Container(
        width: 640,
        height: 560,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Choose what to share',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      child: Icon(Icons.close),
                      onTap: () => _pop(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    _stateSetter = setState;
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints.expand(height: 24),
                            child: TabBar(
                                onTap: (value) => Future.delayed(
                                        Duration(milliseconds: 300), () {
                                      _getSources(value == 0
                                          ? SourceType.Screen
                                          : SourceType.Window);
                                    }),
                                tabs: [
                                  Tab(
                                      child: Text(
                                    'Entrire Screen',
                                    style: TextStyle(color: Colors.black54),
                                  )),
                                  Tab(
                                      child: Text(
                                    'Window',
                                    style: TextStyle(color: Colors.black54),
                                  )),
                                ]),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Expanded(
                            child: Container(
                              child: TabBarView(children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      child: GridView.count(
                                        crossAxisSpacing: 8,
                                        crossAxisCount: 2,
                                        children: _sources
                                            .where((element) =>
                                                element.type ==
                                                SourceType.Screen)
                                            .map((e) => Column(
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      decoration: (_selected_source !=
                                                                  null &&
                                                              _selected_source!
                                                                      .id ==
                                                                  e.id)
                                                          ? BoxDecoration(
                                                              border: Border.all(
                                                                  width: 2,
                                                                  color: Colors
                                                                      .blueAccent))
                                                          : null,
                                                      child: InkWell(
                                                        onTap: () {
                                                          print(
                                                              'Selected screen id => ${e.id}');
                                                          setState(() {
                                                            _selected_source =
                                                                e;
                                                          });
                                                        },
                                                        child:
                                                            e.thumbnail != null
                                                                ? Image.memory(
                                                                    e.thumbnail!,
                                                                    scale: 1.0,
                                                                    repeat: ImageRepeat
                                                                        .noRepeat,
                                                                  )
                                                                : Container(),
                                                      ),
                                                    )),
                                                    Text(
                                                      e.name,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black87,
                                                          fontWeight: (_selected_source !=
                                                                      null &&
                                                                  _selected_source!
                                                                          .id ==
                                                                      e.id)
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                    ),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                    )),
                                Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      child: GridView.count(
                                        crossAxisSpacing: 8,
                                        crossAxisCount: 3,
                                        children: _sources
                                            .where((element) =>
                                                element.type ==
                                                SourceType.Window)
                                            .map((e) => Column(
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      decoration: (_selected_source !=
                                                                  null &&
                                                              _selected_source!
                                                                      .id ==
                                                                  e.id)
                                                          ? BoxDecoration(
                                                              border: Border.all(
                                                                  width: 2,
                                                                  color: Colors
                                                                      .blueAccent))
                                                          : null,
                                                      child: InkWell(
                                                        onTap: () {
                                                          print(
                                                              'Selected window id => ${e.id}');
                                                          setState(() {
                                                            _selected_source =
                                                                e;
                                                          });
                                                        },
                                                        child:
                                                            e.thumbnail != null
                                                                ? Image.memory(
                                                                    e.thumbnail!,
                                                                    scale: 1.0,
                                                                    repeat: ImageRepeat
                                                                        .noRepeat,
                                                                  )
                                                                : Container(),
                                                      ),
                                                    )),
                                                    Text(
                                                      e.name,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black87,
                                                          fontWeight: (_selected_source !=
                                                                      null &&
                                                                  _selected_source!
                                                                          .id ==
                                                                      e.id)
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                    ),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                    )),
                              ]),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: ButtonBar(
                children: <Widget>[
                  MaterialButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54),
                    ),
                    onPressed: () {
                      _pop(context);
                    },
                  ),
                  MaterialButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Share',
                    ),
                    onPressed: () {
                      _pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
