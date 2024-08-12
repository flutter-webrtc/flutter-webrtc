// ignore_for_file: avoid_print
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';

/*
 * getDisplayMedia sample
 */
class GetDisplayMediaSample extends StatefulWidget {
  static String tag = 'get_display_media_sample';

  const GetDisplayMediaSample({super.key});

  @override
  State<GetDisplayMediaSample> createState() => _GetDisplayMediaSampleState();
}

class _GetDisplayMediaSampleState extends State<GetDisplayMediaSample> {
  final List<MediaStreamTrack> _tracks = List.empty(growable: true);
  final List<VideoRenderer> _renderers = List.empty(growable: true);

  bool _inCalling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _stop();
    }
    for (var r in _renderers) {
      r.dispose();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    var displays = await enumerateDisplays();

    for (var display in displays) {
      var caps = DisplayConstraints();
      caps.audio.mandatory = AudioConstraints();
      caps.video.mandatory = DeviceVideoConstraints();
      caps.video.mandatory!.width = 1920;
      caps.video.mandatory!.height = 1080;
      caps.video.mandatory!.fps = 30;
      caps.video.mandatory!.deviceId = display.deviceId;
      var track = (await getDisplayMedia(caps))[0];
      _tracks.add(track);

      var renderer = createVideoRenderer();
      await renderer.initialize();
      await renderer.setSrcObject(track);
      _renderers.add(renderer);
    }

    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  Future<void> _stop() async {
    try {
      for (var t in _tracks) {
        await t.stop();
        await t.dispose();
      }
      _tracks.clear();
      for (var r in _renderers) {
        r.setSrcObject(null);
      }
      _renderers.clear();
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

  Row renderers() {
    final List<Widget> children = [];

    for (var r in _renderers) {
      children.add(Expanded(child: VideoView(r)));
    }

    return Row(
      children: children,
    );
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
                child: renderers(),
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
