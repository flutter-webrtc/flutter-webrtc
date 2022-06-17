import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter_webrtc/src/native/media_stream_impl.dart';

class GetScreenCapture extends StatefulWidget {
  static String tag = 'get_screen_capture';

  @override
  _GetScreenCaptureState createState() => _GetScreenCaptureState();
}

class _GetScreenCaptureState extends State<GetScreenCapture> {
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  List<MediaDeviceInfo>? _mediaDevicesList;
  List<DesktopCapturerSource>? _sources;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();

    _sources = await navigator.desktopCapturer.getSources(
        types: [SourceType.kScreen, SourceType.kWindow],
        thumbnailSize: ThumbnailSize(320, 180)
    );
  }

  void _makeCall() =>
    showDialog(
      context: context,
      builder: (BuildContext context) => Container(
        width: MediaQuery.of(context).size.width - 40,
        height: MediaQuery.of(context).size.height - 60,
        child: Dialog(
          child: ListView.builder(
            itemCount: _sources!.length,
            itemBuilder: (context, index) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, _sources![index].id),
              child: ListTile(
                title: Text('$index. ${_sources![index].name} ${_sources![index].id}'),
              ),
            ),
          ),
        ),
      ),
    ).then((value) async {
      print('selected source: $value');

      try {
        final mediaConstraintsForSelectedSource = <String, dynamic>{
          'video': {
            'deviceId': {
              'exact': value
            },
            'mandatory': {
              'minWidth': 1280,
              'minHeight': 720,
              'frameRate': 30.0
            }
          }
        };

        var stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraintsForSelectedSource);

        _localStream = stream;
        _localRenderer.srcObject = _localStream;
      } catch (e) {
        print(e.toString());
      }
      if (!mounted) return;

      setState(() {
        _inCalling = true;
      });
    });

  void _hangUp() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localRenderer.srcObject = null;
      setState(() {
        _inCalling = false;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GetScreenCapture API Test'),
        actions: _inCalling
            ? <Widget>[
                PopupMenuButton<String>(
                  onSelected: _selectAudioOutput,
                  itemBuilder: (BuildContext context) {
                    if (_mediaDevicesList != null) {
                      return _mediaDevicesList!
                          .where((device) => device.kind == 'audiooutput')
                          .map((device) {
                        return PopupMenuItem<String>(
                          value: device.deviceId,
                          child: Text(device.label),
                        );
                      }).toList();
                    }
                    return [];
                  },
                ),
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: Colors.black54),
              child: RTCVideoView(_localRenderer),
            ),
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

  void _selectAudioOutput(String deviceId) {
    _localRenderer.audioOutput(deviceId);
  }
}
