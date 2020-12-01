import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';

/*
 * getUserMedia sample
 */
class GetUserMediaSample extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  @override
  _GetUserMediaSampleState createState() => _GetUserMediaSampleState();
}

class _GetUserMediaSampleState extends State<GetUserMediaSample> {
  MediaStream _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;
  MediaRecorder _mediaRecorder;
  bool get _isRec => _mediaRecorder != null;

  List<MediaDeviceInfo> _mediaDevicesList;

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

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      var stream = await navigator.getUserMedia(mediaConstraints);
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
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
      await _localStream.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  void _startRecording() async {
    if (Platform.isIOS) {
      print('Recording is not available on iOS');
      return;
    }
    // TODO(rostopira): request write storage permission
    final storagePath = await getExternalStorageDirectory();
    final filePath = storagePath.path + '/webrtc_sample/test.mp4';
    _mediaRecorder = MediaRecorder();
    setState(() {});
    await _localStream.getMediaTracks();
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await _mediaRecorder.start(
      filePath,
      videoTrack: videoTrack,
    );
  }

  void _stopRecording() async {
    await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
  }

  void _toggleTorch() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final has = await videoTrack.hasTorch();
    if (has) {
      print('[TORCH] Current camera supports torch mode');
      setState(() => _isTorchOn = !_isTorchOn);
      await videoTrack.setTorch(_isTorchOn);
      print('[TORCH] Torch state is now ${_isTorchOn ? 'on' : 'off'}');
    } else {
      print('[TORCH] Current camera does not support torch mode');
    }
  }

  void _toggleCamera() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await videoTrack.switchCamera();
  }

  void _captureFrame() async {
    String filePath;
    if (Platform.isAndroid) {
      final storagePath = await getExternalStorageDirectory();
      filePath = storagePath.path + '/webrtc_sample/test.jpg';
    } else {
      final storagePath = await getApplicationDocumentsDirectory();
      filePath = storagePath.path + '/test${DateTime.now()}.jpg';
    }

    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await videoTrack.captureFrame(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GetUserMedia API Test'),
        actions: _inCalling
            ? <Widget>[
                IconButton(
                  icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
                  onPressed: _toggleTorch,
                ),
                IconButton(
                  icon: Icon(Icons.switch_video),
                  onPressed: _toggleCamera,
                ),
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: _captureFrame,
                ),
                IconButton(
                  icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
                  onPressed: _isRec ? _stopRecording : _startRecording,
                ),
                PopupMenuButton<String>(
                  onSelected: _selectAudioOutput,
                  itemBuilder: (BuildContext context) {
                    return _mediaDevicesList
                        .where((device) => device.kind == 'audiooutput')
                        .map((device) {
                      if (device.kind == 'audiooutput') {
                        return PopupMenuItem<String>(
                          value: device.deviceId,
                          child: Text(device.label),
                        );
                      }
                    }).toList();
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
              child: RTCVideoView(_localRenderer, mirror: true),
              decoration: BoxDecoration(color: Colors.black54),
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
    _localRenderer.audioOutput = deviceId;
  }
}
