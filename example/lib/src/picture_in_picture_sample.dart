import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/*
 * Picture-in-picture sample
 */
class PictureInPictureSample extends StatefulWidget {
  static String tag = 'picture_in_picture_sample';

  @override
  _PictureInPictureSampleState createState() => _PictureInPictureSampleState();
}

class _PictureInPictureSampleState extends State<PictureInPictureSample> {
  final _renderer = RTCVideoRenderer();
  final _pip = RTCPictureInPictureController();
  final _videoKey = GlobalKey();
  MediaStream? _localStream;
  bool _supported = false;
  bool _inCalling = false;
  String _lastEvent = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _pip.dispose();
    _renderer.dispose();
  }

  void _init() async {
    await _renderer.initialize();
    _supported = await RTCPictureInPictureController.isSupported();
    _pip.events.listen((event) {
      setState(() {
        _lastEvent = event.error == null
            ? event.state.name
            : '${event.state.name}: ${event.error}';
      });
    });
    if (mounted) setState(() {});
  }

  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {'facingMode': 'user'},
    };
    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _renderer.srcObject = _localStream;
      _renderer.onResize = _configurePip;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _inCalling = true;
    });
    await _configurePip();
  }

  Future<void> _configurePip() async {
    if (_localStream == null) return;
    await _pip.configure(
      stream: _localStream,
      sourceRect: RTCPictureInPictureController.globalRectOf(_videoKey),
      aspectRatio:
          _renderer.value.aspectRatio > 0 ? _renderer.value.aspectRatio : null,
    );
  }

  void _hangUp() async {
    try {
      _renderer.onResize = null;
      await _localStream?.dispose();
      _localStream = null;
      _renderer.srcObject = null;
      setState(() {
        _inCalling = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = RTCVideoView(_renderer, key: _videoKey, mirror: true);
    return RTCPictureInPictureBuilder(
      controller: _pip,
      child: video,
      builder: (context, isInPictureInPicture, child) {
        if (isInPictureInPicture) {
          return Scaffold(body: child);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Picture in Picture'),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black54),
                  child: child,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                    'supported: $_supported${_lastEvent.isEmpty ? '' : ' | $_lastEvent'}'),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _inCalling ? _hangUp : _makeCall,
                      child: Text(_inCalling ? 'Hang up' : 'Start camera'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _inCalling && _supported ? _pip.start : null,
                      child: Text('Enter PiP'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
