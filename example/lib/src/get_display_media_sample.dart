import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/*
 * getDisplayMedia sample
 */
class GetDisplayMediaSample extends StatefulWidget {
  static String tag = 'get_display_media_sample';

  @override
  _GetDisplayMediaSampleState createState() => _GetDisplayMediaSampleState();
}

class _GetDisplayMediaSampleState extends State<GetDisplayMediaSample> {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Timer? _timer;
  var _counter = 0;
  List<DesktopCapturerSource> _sources = [];
  DesktopCapturerSource? selected_source_;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _stop();
    }
    _timer?.cancel();
    _localRenderer.dispose();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
  }

  void handleTimer(Timer timer) async {
    setState(() {
      _counter++;
    });
  }

  Future<void> _getSources() async {
    try {
      var sources = await desktopCapturer
          .getSources(types: [SourceType.kScreen, SourceType.kWindow]);
      sources.forEach((element) {
        print(
            'name: ${element.name}, id: ${element.id}, type: ${element.type}');
      });
      setState(() {
        _sources = sources;
      });
      return;
    } catch (e) {
      print(e.toString());
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall(DesktopCapturerSource source) async {
    setState(() {
      selected_source_ = source;
    });

    try {
      var stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': selected_source_ == null
            ? true
            : {
                'deviceId': {'exact': selected_source_!.id},
                'mandatory': {
                  'minWidth': 1280,
                  'minHeight': 720,
                  'frameRate': 30.0
                }
              }
      });
      stream.getVideoTracks()[0].onEnded = () {
        print(
            'By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };

      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), handleTimer);
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _hangUp() async {
    await _stop();
    setState(() {
      _inCalling = false;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GetDisplayMedia source: ' +
            (selected_source_ != null ? selected_source_!.name : '')),
        actions: [],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
              child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white10,
            child: Stack(children: <Widget>[
              if (!_inCalling)
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 4,
                  // Generate 100 widgets that display their index in the List.
                  children: _sources
                      .map((e) => Column(
                            children: [
                              Text(
                                e.name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    print('id => ${e.id}');
                                    _makeCall(e);
                                  }, // Handle your callback
                                  child: e.thumbnail != null
                                      ? Image.memory(
                                          e.thumbnail!,
                                          scale: 1.0,
                                          repeat: ImageRepeat.noRepeat,
                                        )
                                      : Container(),
                                ),
                              )
                            ],
                          ))
                      .toList(),
                ),
              if (_inCalling)
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.black54),
                  child: RTCVideoView(_localRenderer),
                )
            ]),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _getSources,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
