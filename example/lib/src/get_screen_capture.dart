import 'dart:core';
import 'dart:io';

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
  }

  Future<void> getScreenList() async {
    final response = await WebRTC.invokeMethod(
      'getScreenList',
    );
    print(response);
  }

  Future<void> getWindowList() async {
    final response = await WebRTC.invokeMethod(
      'getWindowList',
    );
    print(response);
  }

  Future<MediaStream> getWindowCapture(
      int windowId,
      Map<String, dynamic> mediaConstraints) async {
    try {
      final response = await WebRTC.invokeMethod(
        'getWindowCapture',
        <String, dynamic>{'constraints': mediaConstraints, 'windowId': windowId},
      );
      if (response == null) {
        throw Exception('getWindowCapture return null, something wrong');
      }
      String streamId = response['streamId'];
      var stream = MediaStreamNative(streamId, 'local');
      stream.setMediaTracks(response['audioTracks'], response['videoTracks']);
      return stream;
    } on PlatformException catch (e) {
      throw 'Unable to getWindowCapture: ${e.message}';
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    try {
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      debugPrint('_mediaDevicesList = $_mediaDevicesList');

      // await getScreenList();
      await getWindowList();

      // var stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      var stream = await getWindowCapture(3607232, mediaConstraints); // TODO(dkubrakov): paste id from getWindowList() result
      // var stream = await getWindowCapture(3346646, mediaConstraints);
      // var stream = await getWindowCapture(4458914, mediaConstraints);

      _localStream = stream;
      _localRenderer.srcObject = _localStream;

      // await stream.getMediaTracks();
      stream.getTracks().forEach((track) {
        print(track);
      });

    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

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
