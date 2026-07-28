import 'dart:core';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoSize {
  VideoSize(this.width, this.height);

  factory VideoSize.fromString(String size) {
    final parts = size.split('x');
    return VideoSize(int.parse(parts[0]), int.parse(parts[1]));
  }
  final int width;
  final int height;

  @override
  String toString() {
    return '$width x $height';
  }
}

/*
 * DeviceEnumerationSample
 */
class DeviceEnumerationSample extends StatefulWidget {
  static String tag = 'DeviceEnumerationSample';

  @override
  _DeviceEnumerationSampleState createState() =>
      _DeviceEnumerationSampleState();
}

class _DeviceEnumerationSampleState extends State<DeviceEnumerationSample> {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  List<MediaDeviceInfo> _devices = [];

  List<MediaDeviceInfo> get audioInputs =>
      _devices.where((device) => device.kind == 'audioinput').toList();

  List<MediaDeviceInfo> get audioOutputs =>
      _devices.where((device) => device.kind == 'audiooutput').toList();

  List<MediaDeviceInfo> get videoInputs =>
      _devices.where((device) => device.kind == 'videoinput').toList();

  String? _selectedVideoInputId;
  String? _selectedAudioInputId;

  MediaDeviceInfo get selectedAudioInput => audioInputs.firstWhere(
      (device) => device.deviceId == _selectedVideoInputId,
      orElse: () => audioInputs.first);

  String? _selectedVideoFPS = '30';

  VideoSize _selectedVideoSize = VideoSize(1280, 720);

  @override
  void initState() {
    super.initState();

    initRenderers();
    loadDevices();
    navigator.mediaDevices.ondevicechange = (event) {
      loadDevices();
    };
  }

  @override
  void deactivate() {
    super.deactivate();
    _stop();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    navigator.mediaDevices.ondevicechange = null;
  }

  RTCPeerConnection? pc1;
  RTCPeerConnection? pc2;
  var senders = <RTCRtpSender>[];

  Future<void> initPCs() async {
    pc2 ??= await createPeerConnection({});
    pc1 ??= await createPeerConnection({});

    pc2?.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
        setState(() {});
      }
    };

    pc2?.onConnectionState = (state) {
      print('connectionState $state');
    };

    pc2?.onIceConnectionState = (state) {
      print('iceConnectionState $state');
    };

    await pc2?.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly));
    await pc2?.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly));

    pc1!.onIceCandidate = (candidate) => pc2!.addCandidate(candidate);
    pc2!.onIceCandidate = (candidate) => pc1!.addCandidate(candidate);
  }

  Future<void> _negotiate() async {
    var offer = await pc1?.createOffer();
    await pc1?.setLocalDescription(offer!);
    await pc2?.setRemoteDescription(offer!);
    var answer = await pc2?.createAnswer();
    await pc2?.setLocalDescription(answer!);
    await pc1?.setRemoteDescription(answer!);
  }

  Future<void> stopPCs() async {
    await pc1?.close();
    await pc2?.close();
    pc1 = null;
    pc2 = null;
  }

  Future<void> loadDevices() async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      //Ask for runtime permissions if necessary.
      var status = await Permission.bluetooth.request();
      if (status.isPermanentlyDenied) {
        print('BLEpermdisabled');
      }

      status = await Permission.bluetoothConnect.request();
      if (status.isPermanentlyDenied) {
        print('ConnectPermdisabled');
      }
    }
    final devices = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _selectVideoFps(String fps) async {
    _selectedVideoFPS = fps;
    if (!_inCalling) {
      return;
    }
    await _selectVideoInput(_selectedVideoInputId);
    setState(() {});
  }

  Future<void> _selectVideoSize(String size) async {
    _selectedVideoSize = VideoSize.fromString(size);
    if (!_inCalling) {
      return;
    }
    await _selectVideoInput(_selectedVideoInputId);
    setState(() {});
  }

  Future<void> _selectAudioInput(String? deviceId) async {
    _selectedAudioInputId = deviceId;
    if (!_inCalling) {
      return;
    }

    var newLocalStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        if (_selectedAudioInputId != null && kIsWeb)
          'deviceId': _selectedAudioInputId,
        if (_selectedAudioInputId != null && !kIsWeb)
          'optional': [
            {'sourceId': _selectedAudioInputId}
          ],
      },
      'video': false,
    });

    // replace track.
    var newTrack = newLocalStream.getAudioTracks().first;
    print('track.settings ' + newTrack.getSettings().toString());
    var sender =
        senders.firstWhereOrNull((sender) => sender.track?.kind == 'audio');
    await sender?.replaceTrack(newTrack);
  }

  Future<void> _selectAudioOutput(String? deviceId) async {
    if (!_inCalling) {
      return;
    }
    await _localRenderer.audioOutput(deviceId!);
  }

  var _speakerphoneOn = false;

  Future<void> _setSpeakerphoneOn() async {
    _speakerphoneOn = !_speakerphoneOn;
    await Helper.setSpeakerphoneOn(_speakerphoneOn);
    setState(() {});
  }

  Future<void> _selectVideoInput(String? deviceId) async {
    _selectedVideoInputId = deviceId;
    if (!_inCalling) {
      return;
    }
    // 2) replace track.
    // stop old track.
    _localRenderer.srcObject = null;

    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });
    await _localStream?.dispose();

    var newLocalStream = await navigator.mediaDevices.getUserMedia({
      'audio': false,
      'video': {
        if (_selectedVideoInputId != null && kIsWeb)
          'deviceId': _selectedVideoInputId,
        if (_selectedVideoInputId != null && !kIsWeb)
          'optional': [
            {'sourceId': _selectedVideoInputId}
          ],
        'width': _selectedVideoSize.width,
        'height': _selectedVideoSize.height,
        'frameRate': _selectedVideoFPS,
      },
    });
    _localStream = newLocalStream;
    _localRenderer.srcObject = _localStream;
    // replace track.
    var newTrack = _localStream?.getVideoTracks().first;
    print('track.settings ' + newTrack!.getSettings().toString());
    var sender =
        senders.firstWhereOrNull((sender) => sender.track?.kind == 'video');
    var params = sender!.parameters;
    print('params degradationPreference' +
        params.degradationPreference.toString());
    params.degradationPreference = RTCDegradationPreference.MAINTAIN_RESOLUTION;
    await sender.setParameters(params);
    await sender.replaceTrack(newTrack);
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _start() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          if (_selectedVideoInputId != null && kIsWeb)
            'deviceId': _selectedVideoInputId,
          if (_selectedVideoInputId != null && !kIsWeb)
            'optional': [
              {'sourceId': _selectedVideoInputId}
            ],
          'width': _selectedVideoSize.width,
          'height': _selectedVideoSize.height,
          'frameRate': _selectedVideoFPS,
        },
      });
      _localRenderer.srcObject = _localStream;
      _inCalling = true;

      await initPCs();

      _localStream?.getTracks().forEach((track) async {
        var rtpSender = await pc1?.addTrack(track, _localStream!);
        print('track.settings ' + track.getSettings().toString());
        senders.add(rtpSender!);
      });

      await _negotiate();
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _stop() async {
    try {
      _localStream?.getTracks().forEach((track) async {
        await track.stop();
      });
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      senders.clear();
      _inCalling = false;
      await stopPCs();
      _speakerphoneOn = false;
      await Helper.setSpeakerphoneOn(_speakerphoneOn);
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DeviceEnumerationSample'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _selectAudioInput,
            icon: Icon(Icons.settings_voice),
            itemBuilder: (BuildContext context) {
              return _devices
                  .where((device) => device.kind == 'audioinput')
                  .map((device) {
                return PopupMenuItem<String>(
                  value: device.deviceId,
                  child: Text(device.label),
                );
              }).toList();
            },
          ),
          if (!WebRTC.platformIsMobile)
            PopupMenuButton<String>(
              onSelected: _selectAudioOutput,
              icon: Icon(Icons.volume_down_alt),
              itemBuilder: (BuildContext context) {
                return _devices
                    .where((device) => device.kind == 'audiooutput')
                    .map((device) {
                  return PopupMenuItem<String>(
                    value: device.deviceId,
                    child: Text(device.label),
                  );
                }).toList();
              },
            ),
          if (!kIsWeb && WebRTC.platformIsMobile)
            IconButton(
              disabledColor: Colors.grey,
              onPressed: _setSpeakerphoneOn,
              icon: Icon(
                  _speakerphoneOn ? Icons.speaker_phone : Icons.phone_android),
              tooltip: 'Switch SpeakerPhone',
            ),
          PopupMenuButton<String>(
            onSelected: _selectVideoInput,
            icon: Icon(Icons.switch_camera),
            itemBuilder: (BuildContext context) {
              return _devices
                  .where((device) => device.kind == 'videoinput')
                  .map((device) {
                return PopupMenuItem<String>(
                  value: device.deviceId,
                  child: Text(device.label),
                );
              }).toList();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _selectVideoFps,
            icon: Icon(Icons.menu),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: _selectedVideoFPS,
                  child: Text('Select FPS ($_selectedVideoFPS)'),
                ),
                PopupMenuDivider(),
                ...['8', '15', '30', '60']
                    .map((fps) => PopupMenuItem<String>(
                          value: fps,
                          child: Text(fps),
                        ))
                    .toList()
              ];
            },
          ),
          PopupMenuButton<String>(
            onSelected: _selectVideoSize,
            icon: Icon(Icons.screenshot_monitor),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: _selectedVideoSize.toString(),
                  child: Text('Select Video Size ($_selectedVideoSize)'),
                ),
                PopupMenuDivider(),
                ...['320x180', '640x360', '1280x720', '1920x1080']
                    .map((fps) => PopupMenuItem<String>(
                          value: fps,
                          child: Text(fps),
                        ))
                    .toList()
              ];
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white10,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        decoration: BoxDecoration(color: Colors.black54),
                        child: RTCVideoView(_localRenderer),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        decoration: BoxDecoration(color: Colors.black54),
                        child: RTCVideoView(_remoteRenderer),
                      ),
                    ),
                  ],
                )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _inCalling ? _stop() : _start();
        },
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
