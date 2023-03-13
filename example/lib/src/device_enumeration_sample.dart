import 'dart:core';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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

  MediaDeviceInfo get selectedAudioInput => audioInputs.firstWhere(
      (device) => device.deviceId == _selectedAudioInputId,
      orElse: () => audioInputs.first);
  String? _selectedAudioInputId;

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
    final devices = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _selectVideoInput(String deviceId) async {
    _selectedAudioInputId = deviceId;
    /*
    1) restart PCs.
    await _stop();
    await _start(); 
    */

    // 2) replace track.
    // stop old track.
    _localRenderer.srcObject = null;
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    var newLocalStream = await navigator.mediaDevices.getUserMedia({
      'audio': false,
      'video': {
        if (_selectedAudioInputId != null && kIsWeb)
          'deviceId': _selectedAudioInputId,
        if (_selectedAudioInputId != null && !kIsWeb)
          'optional': [
            {'sourceId': _selectedAudioInputId}
          ],
        'width': {'ideal': 640},
        'height': {'ideal': 480}
      },
    });
    _localRenderer.srcObject = newLocalStream;
    // replace track.
    var newTrack = newLocalStream.getVideoTracks().first;
    var sender =
        senders.firstWhereOrNull((sender) => sender.track?.kind == 'video');
    await sender?.replaceTrack(newTrack);
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _start() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': {
          if (_selectedAudioInputId != null && kIsWeb)
            'deviceId': _selectedAudioInputId,
          if (_selectedAudioInputId != null && !kIsWeb)
            'optional': [
              {'sourceId': _selectedAudioInputId}
            ],
          'width': {'ideal': 640},
          'height': {'ideal': 480}
        },
      });
      _localRenderer.srcObject = _localStream;
      _inCalling = true;

      await initPCs();

      _localStream?.getTracks().forEach((track) async {
        var rtpSender = await pc1?.addTrack(track, _localStream!);
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
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
      _inCalling = false;
      await stopPCs();
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
