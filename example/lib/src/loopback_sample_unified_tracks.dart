import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LoopBackSampleUnifiedTracks extends StatefulWidget {
  static String tag = 'loopback_sample_unified_tracks';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LoopBackSampleUnifiedTracks> {
  MediaStream? _localStream;
  RTCPeerConnection? _localPeerConnection;
  RTCPeerConnection? _remotePeerConnection;
  RTCRtpSender? _videoSender;
  RTCRtpSender? _audioSender;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _micOn = false;
  bool _cameraOn = false;
  bool _speakerOn = false;
  List<MediaDeviceInfo>? _mediaDevicesList;
  Timer? _timer;
  final _configuration = <String, dynamic>{
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan'
  };

  final _constraints = <String, dynamic>{
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': false},
    ],
  };

  @override
  void initState() {
    print('Init State');
    super.initState();

    _refreshMediaDevices();
    navigator.mediaDevices.ondevicechange = (event) async {
      print('++++++ ondevicechange ++++++');
      var devices = await navigator.mediaDevices.enumerateDevices();
      setState(() {
        _mediaDevicesList = devices;
      });
    };
  }

  @override
  void deactivate() {
    super.deactivate();
    navigator.mediaDevices.ondevicechange = null;
    _cleanUp();
  }

  Future<void> _refreshMediaDevices() async {
    var devices = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      _mediaDevicesList = devices;
    });
  }

  void _selectAudioOutput(String deviceId) async {
    await _localRenderer.audioOutput(deviceId);
  }

  void _selectAudioInput(String deviceId) async {
    await Helper.selectAudioInput(deviceId);
  }

  void _cleanUp() async {
    try {
      await _localStream?.dispose();
      await _remotePeerConnection?.close();
      await _remotePeerConnection?.dispose();
      _remotePeerConnection = null;
      await _localPeerConnection?.close();
      await _localPeerConnection?.dispose();
      _localPeerConnection = null;
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _inCalling = false;
      _cameraOn = false;
      _micOn = false;
    });
  }

  void initRenderers() async {
    print('Init Renderers');
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void initLocalConnection() async {
    if (_localPeerConnection != null) return;
    try {
      _localPeerConnection =
          await createPeerConnection(_configuration, _constraints);

      _localPeerConnection!.onSignalingState = _onLocalSignalingState;
      _localPeerConnection!.onIceGatheringState = _onLocalIceGatheringState;
      _localPeerConnection!.onIceConnectionState = _onLocalIceConnectionState;
      _localPeerConnection!.onConnectionState = _onLocalPeerConnectionState;
      _localPeerConnection!.onIceCandidate = _onLocalCandidate;
      _localPeerConnection!.onRenegotiationNeeded = _onLocalRenegotiationNeeded;
    } catch (e) {
      print(e.toString());
    }
  }

  void _onLocalSignalingState(RTCSignalingState state) {
    print('localSignalingState: $state');
  }

  void _onRemoteSignalingState(RTCSignalingState state) {
    print('remoteSignalingState: $state');
  }

  void _onLocalIceGatheringState(RTCIceGatheringState state) {
    print('localIceGatheringState: $state');
  }

  void _onRemoteIceGatheringState(RTCIceGatheringState state) {
    print('remoteIceGatheringState: $state');
  }

  void _onLocalIceConnectionState(RTCIceConnectionState state) {
    print('localIceConnectionState: $state');
  }

  void _onRemoteIceConnectionState(RTCIceConnectionState state) {
    print('remoteIceConnectionState: $state');
  }

  void _onLocalPeerConnectionState(RTCPeerConnectionState state) {
    print('localPeerConnectionState: $state');
  }

  void _onRemotePeerConnectionState(RTCPeerConnectionState state) {
    print('remotePeerConnectionState: $state');
  }

  void _onLocalCandidate(RTCIceCandidate localCandidate) async {
    print('onLocalCandidate: ${localCandidate.candidate}');
    try {
      var candidate = RTCIceCandidate(
        localCandidate.candidate!,
        localCandidate.sdpMid!,
        localCandidate.sdpMLineIndex!,
      );
      await _remotePeerConnection!.addCandidate(candidate);
    } catch (e) {
      print(
          'Unable to add candidate ${localCandidate.candidate} to remote connection');
    }
  }

  void _onRemoteCandidate(RTCIceCandidate remoteCandidate) async {
    print('onRemoteCandidate: ${remoteCandidate.candidate}');
    try {
      var candidate = RTCIceCandidate(
        remoteCandidate.candidate!,
        remoteCandidate.sdpMid!,
        remoteCandidate.sdpMLineIndex!,
      );
      await _localPeerConnection!.addCandidate(candidate);
    } catch (e) {
      print(
          'Unable to add candidate ${remoteCandidate.candidate} to local connection');
    }
  }

  void _onTrack(RTCTrackEvent event) async {
    print('onTrack ${event.track.id}');
    if (event.track.kind == 'video') {
      // onMute/onEnded/onUnMute are not wired up
      // event.track.onEnded = () {
      //   print("Ended");
      //   setState(() {
      //     _remoteRenderer.srcObject = null;
      //   });
      // };
      // event.track.onUnMute = () async {
      //   print("UnMute");
      //   var stream = await createLocalMediaStream(event.track.id!);
      //   await stream.addTrack(event.track);
      //   setState(() {
      //     _remoteRenderer.srcObject = stream;
      //   });
      // };
      // event.track.onMute = () {
      //   print("OnMute");
      //   setState(() {
      //     _remoteRenderer.srcObject = null;
      //   });
      // };

      var stream = await createLocalMediaStream(event.track.id!);
      await stream.addTrack(event.track);
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    }
  }

  void _onLocalRenegotiationNeeded() {
    print('LocalRenegotiationNeeded');
  }

  void _onRemoteRenegotiationNeeded() {
    print('RemoteRenegotiationNeeded');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    initRenderers();
    initLocalConnection();

    var acaps = await getRtpSenderCapabilities('audio');
    print('sender audio capabilities: ${acaps.toMap()}');

    var vcaps = await getRtpSenderCapabilities('video');
    print('sender video capabilities: ${vcaps.toMap()}');

    if (_remotePeerConnection != null) return;

    try {
      _remotePeerConnection =
          await createPeerConnection(_configuration, _constraints);

      _remotePeerConnection!.onTrack = _onTrack;
      _remotePeerConnection!.onSignalingState = _onRemoteSignalingState;
      _remotePeerConnection!.onIceGatheringState = _onRemoteIceGatheringState;
      _remotePeerConnection!.onIceConnectionState = _onRemoteIceConnectionState;
      _remotePeerConnection!.onConnectionState = _onRemotePeerConnectionState;
      _remotePeerConnection!.onIceCandidate = _onRemoteCandidate;
      _remotePeerConnection!.onRenegotiationNeeded =
          _onRemoteRenegotiationNeeded;

      await _negotiate();
    } catch (e) {
      print(e.toString());
    }

    if (!mounted) return;
    setState(() {
      _inCalling = true;
    });
  }

  Future<void> _negotiate() async {
    final oaConstraints = <String, dynamic>{
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    if (_remotePeerConnection == null) return;

    var offer = await _localPeerConnection!.createOffer(oaConstraints);
    await _localPeerConnection!.setLocalDescription(offer);
    var localDescription = await _localPeerConnection!.getLocalDescription();

    await _remotePeerConnection!.setRemoteDescription(localDescription!);
    var answer = await _remotePeerConnection!.createAnswer(oaConstraints);
    await _remotePeerConnection!.setLocalDescription(answer);
    var remoteDescription = await _remotePeerConnection!.getLocalDescription();

    await _localPeerConnection!.setRemoteDescription(remoteDescription!);
  }

  void _hangUp() async {
    try {
      await _remotePeerConnection?.close();
      await _remotePeerConnection?.dispose();
      _remotePeerConnection = null;
      _remoteRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _inCalling = false;
    });
  }

  Map<String, dynamic> _getMediaConstraints({audio = true, video = true}) {
    return {
      'audio': audio ? true : false,
      'video': video
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };
  }

  void _sendDtmf() async {
    var dtmfSender = _audioSender?.dtmfSender;
    await dtmfSender?.insertDTMF('123#');
  }

  void _startVideo() async {
    var newStream = await navigator.mediaDevices
        .getUserMedia(_getMediaConstraints(audio: false, video: true));
    if (_localStream != null) {
      await _removeExistingVideoTrack();
      var tracks = newStream.getVideoTracks();
      for (var newTrack in tracks) {
        await _localStream!.addTrack(newTrack);
      }
    } else {
      _localStream = newStream;
    }

    await _addOrReplaceVideoTracks();

    var transceivers = await _localPeerConnection?.getTransceivers();
    transceivers?.forEach((transceiver) {
      if (transceiver.sender.track == null) return;
      print('transceiver: ${transceiver.sender.track!.kind!}');
      transceiver.setCodecPreferences([
        /*RTCRtpCodecCapability(
          mimeType: 'video/H264',
          clockRate: 90000,
          sdpFmtpLine:
              'level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42e01f',
        ),*/
        RTCRtpCodecCapability(
          mimeType: 'video/AV1',
          clockRate: 90000,
        )
      ]);
    });

    await _negotiate();

    setState(() {
      _localRenderer.srcObject = _localStream;
      _cameraOn = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      handleStatsReport(timer);
    });
  }

  void _stopVideo() async {
    await _removeExistingVideoTrack(fromConnection: true);
    await _negotiate();
    setState(() {
      _localRenderer.srcObject = null;
      // onMute/onEnded/onUnmute are not wired up so having to force this here
      _remoteRenderer.srcObject = null;
      _cameraOn = false;
    });
    _timer?.cancel();
    _timer = null;
  }

  void _startAudio() async {
    var newStream = await navigator.mediaDevices
        .getUserMedia(_getMediaConstraints(audio: true, video: false));

    if (_localStream != null) {
      await _removeExistingAudioTrack();
      for (var newTrack in newStream.getAudioTracks()) {
        await _localStream!.addTrack(newTrack);
      }
    } else {
      _localStream = newStream;
    }

    await _addOrReplaceAudioTracks();
    var transceivers = await _localPeerConnection?.getTransceivers();
    transceivers?.forEach((transceiver) {
      if (transceiver.sender.track == null) return;
      transceiver.setCodecPreferences([
        RTCRtpCodecCapability(
          mimeType: 'audio/PCMA',
          clockRate: 8000,
          channels: 1,
        )
      ]);
    });
    await _negotiate();

    setState(() {
      _micOn = true;
    });
  }

  void _stopAudio() async {
    await _removeExistingAudioTrack(fromConnection: true);
    await _negotiate();
    setState(() {
      _micOn = false;
    });
  }

  void _switchSpeaker() async {
    setState(() {
      _speakerOn = !_speakerOn;
      Helper.setSpeakerphoneOn(_speakerOn);
    });
  }

  void handleStatsReport(Timer timer) async {
    if (_remotePeerConnection != null && _remoteRenderer.srcObject != null) {
      var reports = await _remotePeerConnection
          ?.getStats(_remoteRenderer.srcObject!.getVideoTracks().first);
      reports?.forEach((report) {
        print('report => { ');
        print('    id: ' + report.id + ',');
        print('    type: ' + report.type + ',');
        print('    timestamp: ${report.timestamp},');
        print('    values => {');
        report.values.forEach((key, value) {
          print('        ' + key + ' : ' + value.toString() + ', ');
        });
        print('    }');
        print('}');
      });

      /*
      var senders = await _peerConnection.getSenders();
      var canInsertDTMF = await senders[0].dtmfSender.canInsertDtmf();
      print(canInsertDTMF);
      await senders[0].dtmfSender.insertDTMF('1');
      var receivers = await _peerConnection.getReceivers();
      print(receivers[0].track.id);
      var transceivers = await _peerConnection.getTransceivers();
      print(transceivers[0].sender.parameters);
      print(transceivers[0].receiver.parameters);
      */
    }
  }

  Future<void> _removeExistingVideoTrack({bool fromConnection = false}) async {
    var tracks = _localStream!.getVideoTracks();
    for (var i = tracks.length - 1; i >= 0; i--) {
      var track = tracks[i];
      if (fromConnection) {
        await _connectionRemoveTrack(track);
      }
      await _localStream!.removeTrack(track);
      await track.stop();
    }
  }

  Future<void> _removeExistingAudioTrack({bool fromConnection = false}) async {
    var tracks = _localStream!.getAudioTracks();
    for (var i = tracks.length - 1; i >= 0; i--) {
      var track = tracks[i];
      if (fromConnection) {
        await _connectionRemoveTrack(track);
      }
      await _localStream!.removeTrack(track);
      await track.stop();
    }
  }

  Future<void> _addOrReplaceVideoTracks() async {
    for (var track in _localStream!.getVideoTracks()) {
      await _connectionAddTrack(track, _localStream!);
    }
  }

  Future<void> _addOrReplaceAudioTracks() async {
    for (var track in _localStream!.getAudioTracks()) {
      await _connectionAddTrack(track, _localStream!);
    }
  }

  Future<void> _connectionAddTrack(
      MediaStreamTrack track, MediaStream stream) async {
    var sender = track.kind == 'video' ? _videoSender : _audioSender;
    if (sender != null) {
      print('Have a Sender of kind:${track.kind}');
      var trans = await _getSendersTransceiver(sender.senderId);
      if (trans != null) {
        print('Setting direction and replacing track with new track');
        await trans.setDirection(TransceiverDirection.SendOnly);
        await trans.sender.replaceTrack(track);
      }
    } else {
      if (track.kind == 'video') {
        _videoSender = await _localPeerConnection!.addTrack(track, stream);
      } else {
        _audioSender = await _localPeerConnection!.addTrack(track, stream);
      }
    }
  }

  Future<void> _connectionRemoveTrack(MediaStreamTrack track) async {
    var sender = track.kind == 'video' ? _videoSender : _audioSender;
    if (sender != null) {
      print('Have a Sender of kind:${track.kind}');
      var trans = await _getSendersTransceiver(sender.senderId);
      if (trans != null) {
        print('Setting direction and replacing track with null');
        await trans.setDirection(TransceiverDirection.Inactive);
        await trans.sender.replaceTrack(null);
      }
    }
  }

  Future<RTCRtpTransceiver?> _getSendersTransceiver(String senderId) async {
    RTCRtpTransceiver? foundTrans;
    var trans = await _localPeerConnection!.getTransceivers();
    for (var tran in trans) {
      if (tran.sender.senderId == senderId) {
        foundTrans = tran;
        break;
      }
    }
    return foundTrans;
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      Expanded(
        child: RTCVideoView(_localRenderer, mirror: true),
      ),
      Expanded(
        child: RTCVideoView(_remoteRenderer),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('LoopBack Unified Tracks example'),
        actions: [
          IconButton(
            icon: Icon(Icons.keyboard),
            onPressed: _sendDtmf,
          ),
          PopupMenuButton<String>(
            onSelected: _selectAudioInput,
            icon: Icon(Icons.settings_voice),
            itemBuilder: (BuildContext context) {
              if (_mediaDevicesList != null) {
                return _mediaDevicesList!
                    .where((device) => device.kind == 'audioinput')
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
          PopupMenuButton<String>(
            onSelected: _selectAudioOutput,
            icon: Icon(Icons.volume_down_alt),
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
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.black54),
                child: orientation == Orientation.portrait
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widgets)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widgets),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ButtonBar(
                  children: [
                    FloatingActionButton(
                        heroTag: null,
                        backgroundColor:
                            _micOn ? null : Theme.of(context).disabledColor,
                        tooltip: _micOn ? 'Stop mic' : 'Start mic',
                        onPressed: _micOn ? _stopAudio : _startAudio,
                        child: Icon(_micOn ? Icons.mic : Icons.mic_off)),
                    FloatingActionButton(
                        heroTag: null,
                        backgroundColor:
                            _speakerOn ? null : Theme.of(context).disabledColor,
                        tooltip: _speakerOn ? 'Stop speaker' : 'Start speaker',
                        onPressed: _switchSpeaker,
                        child: Icon(_speakerOn
                            ? Icons.speaker_phone
                            : Icons.phone_in_talk)),
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor:
                          _cameraOn ? null : Theme.of(context).disabledColor,
                      tooltip: _cameraOn ? 'Stop camera' : 'Start camera',
                      onPressed: _cameraOn ? _stopVideo : _startVideo,
                      child:
                          Icon(_cameraOn ? Icons.videocam : Icons.videocam_off),
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      backgroundColor:
                          _inCalling ? null : Theme.of(context).disabledColor,
                      onPressed: _inCalling ? _hangUp : _makeCall,
                      tooltip: _inCalling ? 'Hangup' : 'Call',
                      child: Icon(_inCalling ? Icons.call_end : Icons.phone),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
