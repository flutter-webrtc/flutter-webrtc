// ignore_for_file: avoid_print
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/*
 * getDisplayMedia sample
 */
class GetDisplayMediaSample extends StatefulWidget {
  static String tag = 'get_display_media_sample';

  const GetDisplayMediaSample({Key? key}) : super(key: key);

  @override
  State<GetDisplayMediaSample> createState() => _GetDisplayMediaSampleState();
}

class _GetDisplayMediaSampleState extends State<GetDisplayMediaSample> {
  MediaStreamTrack? _track;
  final _localRenderer = createVideoRenderer();
  bool _inCalling = false;

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
    _localRenderer.dispose();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    var caps = DisplayConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 1920;
    caps.video.mandatory!.height = 1080;
    caps.video.mandatory!.fps = 30;

    try {
      var track = (await getDisplayMedia(caps))[0];

      _track = track;
      await _localRenderer.setSrcObject(track);
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  Future<void> _stop() async {
    try {
      await _track?.stop();
      await _track?.dispose();
      _track = null;
      await _localRenderer.setSrcObject(_track);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _hangUp() async {
    await _stop();
    setState(() {
      _inCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetDisplayMedia API Test'),
        actions: const [],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Stack(children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(color: Colors.black54),
                child: VideoView(_localRenderer),
              )
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
