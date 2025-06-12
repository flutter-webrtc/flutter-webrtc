import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// Import the CallQualityManager
import 'package:flutter_webrtc/src/call_quality_manager.dart';

class LoopBackSampleUnifiedTracks extends StatefulWidget {
  static String tag = 'loopback_sample_unified_tracks';

  @override
  _MyAppState createState() => _MyAppState();
}

const List<String> audioCodecList = <String>[
  'OPUS',
  'ISAC',
  'PCMA',
  'PCMU',
  'G729'
];
const List<String> videoCodecList = <String>['VP8', 'VP9', 'H264', 'AV1'];

class _MyAppState extends State<LoopBackSampleUnifiedTracks> {
  String audioDropdownValue = audioCodecList.first;
  String videoDropdownValue = videoCodecList.first;
  RTCRtpCapabilities? acaps;
  RTCRtpCapabilities? vcaps;
  MediaStream? _localStream;
  RTCPeerConnection? _localPeerConnection;
  RTCPeerConnection? _remotePeerConnection;
  RTCRtpSender? _videoSender;
  RTCRtpSender? _audioSender;
  CallQualityManager? _callQualityManager; // Add CallQualityManager field
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _micOn = false;
  bool _cameraOn = false;
  bool _speakerOn = false;
  bool _audioEncrypt = false;
  bool _videoEncrypt = false;
  bool _audioDecrypt = false;
  bool _videoDecrypt = false;
  List<MediaDeviceInfo>? _mediaDevicesList;
  final FrameCryptorFactory _frameCyrptorFactory = frameCryptorFactory;
  KeyProvider? _keySharedProvider;
  final Map<String, FrameCryptor> _frameCyrptors = {};
  Timer? _timer;
  final _configuration = <String, dynamic>{
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
    'encodedInsertableStreams': true,
  };

  final _constraints = <String, dynamic>{
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': false},
    ],
  };

  final demoRatchetSalt = 'flutter-webrtc-ratchet-salt';

  final aesKey = Uint8List.fromList([
    200,
    244,
    58,
    72,
    214,
    245,
    86,
    82,
    192,
    127,
    23,
    153,
    167,
    172,
    122,
    234,
    140,
    70,
    175,
    74,
    61,
    11,
    134,
    58,
    185,
    102,
    172,
    17,
    11,
    6,
    119,
    253
  ]);

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
    if (!WebRTC.platformIsWeb) {
      await Helper.selectAudioInput(deviceId);
    }
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

      // Dispose CallQualityManager
      await _callQualityManager?.dispose();
      _callQualityManager = null;
      print('CallQualityManager disposed in _cleanUp.');
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
      var pc = await createPeerConnection(_configuration, _constraints);

      pc.onSignalingState = (state) async {
        var state2 = await pc.getSignalingState();
        print('local pc: onSignalingState($state), state2($state2)');
      };

      pc.onIceGatheringState = (state) async {
        var state2 = await pc.getIceGatheringState();
        print('local pc: onIceGatheringState($state), state2($state2)');
      };
      pc.onIceConnectionState = (state) async {
        var state2 = await pc.getIceConnectionState();
        print('local pc: onIceConnectionState($state), state2($state2)');
      };
      pc.onConnectionState = (state) async {
        var state2 = await pc.getConnectionState();
        print('local pc: onConnectionState($state), state2($state2)');
      };

      pc.onIceCandidate = _onLocalCandidate;
      pc.onRenegotiationNeeded = _onLocalRenegotiationNeeded;

      _localPeerConnection = pc;

      // Instantiate CallQualityManager for the local peer connection
      if (_localPeerConnection != null) {
        final customCQMSettings = CallQualityManagerSettings(
          packetLossThresholdPercent: 15.0, // Be more tolerant to packet loss
          rttThresholdSeconds: 0.7,        // Be more tolerant to RTT
          minSensibleBitrateBps: 75000,    // Set a higher minimum bitrate
          autoRestartLocallyEndedTracks: true, // Enable auto-restart
          defaultVideoRestartConstraints: { // Constraints for video restart
            'audio': false, // Ensure we only request video
            'video': {'width': 640, 'height': 480, 'frameRate': 30}
          },
          defaultAudioRestartConstraints: { // Constraints for audio restart
             'video': false, // Ensure we only request audio
             'audio': true
          }
        );
        _callQualityManager = CallQualityManager(_localPeerConnection!, customCQMSettings);
        print('CallQualityManager instantiated for localPeerConnection with custom settings.');

        _callQualityManager!.onTrackRestarted.listen((MediaStreamTrack newTrack) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('CallQualityManager automatically restarted track: ${newTrack.id} (${newTrack.kind})'),
          ));
          // If UI needs to update based on the new track, handle here.
          // For example, if localRenderer.srcObject was using the old track's stream,
          // it might need to be updated if the stream itself was recreated.
          // However, replaceTrack should handle this transparently for the stream.
        });
      }
    } catch (e) {
      print(e.toString());
    }
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
      setState(() {
        _remoteRenderer.srcObject = event.streams[0];
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
    initRenderers(); // This also disposes previous CQM if any.
    initLocalConnection(); // This now instantiates CQM with new PC.

    // Setup listeners for local stream and track events
    _localStream?.onActiveStateChanged.listen((isActive) {
      print('Local stream active state changed: $isActive');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Local stream active state: ${isActive ? "Active" : "Inactive"}'),
        duration: Duration(seconds: 1),
      ));
    });

    // Example of listening to a specific track's onEnded (e.g., first video track)
    // This needs to be done after the track is available in _localStream
    // For demonstration, we'll assume _startVideo or _startAudio will set this up
    // if they successfully add a track. See _startVideo/_startAudio modifications.

    var keyProviderOptions = KeyProviderOptions(
      sharedKey: true,
      ratchetSalt: Uint8List.fromList(demoRatchetSalt.codeUnits),
      ratchetWindowSize: 16,
      failureTolerance: -1,
    );

    _keySharedProvider ??=
        await _frameCyrptorFactory.createDefaultKeyProvider(keyProviderOptions);
    await _keySharedProvider?.setSharedKey(key: aesKey);
    acaps = await getRtpSenderCapabilities('audio');
    print('sender audio capabilities: ${acaps!.toMap()}');

    vcaps = await getRtpSenderCapabilities('video');
    print('sender video capabilities: ${vcaps!.toMap()}');

    if (_remotePeerConnection != null) return;

    try {
      var pc = await createPeerConnection(_configuration, _constraints);

      pc.onTrack = _onTrack;

      pc.onSignalingState = (state) async {
        var state2 = await pc.getSignalingState();
        print('remote pc: onSignalingState($state), state2($state2)');
      };

      pc.onIceGatheringState = (state) async {
        var state2 = await pc.getIceGatheringState();
        print('remote pc: onIceGatheringState($state), state2($state2)');
      };
      pc.onIceConnectionState = (state) async {
        var state2 = await pc.getIceConnectionState();
        print('remote pc: onIceConnectionState($state), state2($state2)');
      };
      pc.onConnectionState = (state) async {
        var state2 = await pc.getConnectionState();
        print('remote pc: onConnectionState($state), state2($state2)');
      };

      pc.onIceCandidate = _onRemoteCandidate;
      pc.onRenegotiationNeeded = _onRemoteRenegotiationNeeded;
      _remotePeerConnection = pc;
      await _negotiate();
    } catch (e) {
      print(e.toString());
    }

    if (!mounted) return;
    setState(() {
      _inCalling = true;
    });

    // Start CallQualityManager when the call is established
    // This could also be placed after negotiation completes successfully.
    _callQualityManager?.start();
    print('CallQualityManager started.');
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

    var offer = await _localPeerConnection!.createOffer({});
    await _localPeerConnection!.setLocalDescription(offer);
    var localDescription = await _localPeerConnection!.getLocalDescription();

    await _remotePeerConnection!.setRemoteDescription(localDescription!);
    var answer = await _remotePeerConnection!.createAnswer(oaConstraints);
    await _remotePeerConnection!.setLocalDescription(answer);
    var remoteDescription = await _remotePeerConnection!.getLocalDescription();

    await _localPeerConnection!.setRemoteDescription(remoteDescription!);
  }

  void _enableEncryption({bool video = false, bool enabled = true}) async {
    var senders = await _localPeerConnection?.senders;

    var kind = video ? 'video' : 'audio';

    senders?.forEach((element) async {
      if (kind != element.track?.kind) return;

      var trackId = element.track?.id;
      var id = kind + '_' + trackId! + '_sender';
      if (!_frameCyrptors.containsKey(id)) {
        var frameCyrptor =
            await _frameCyrptorFactory.createFrameCryptorForRtpSender(
                participantId: id,
                sender: element,
                algorithm: Algorithm.kAesGcm,
                keyProvider: _keySharedProvider!);
        frameCyrptor.onFrameCryptorStateChanged = (participantId, state) =>
            print('EN onFrameCryptorStateChanged $participantId $state');
        _frameCyrptors[id] = frameCyrptor;
        await frameCyrptor.setKeyIndex(0);
      }

      var _frameCyrptor = _frameCyrptors[id];
      await _frameCyrptor?.setEnabled(enabled);
      await _frameCyrptor?.updateCodec(
          kind == 'video' ? videoDropdownValue : audioDropdownValue);
    });
  }

  void _enableDecryption({bool video = false, bool enabled = true}) async {
    var receivers = await _remotePeerConnection?.receivers;
    var kind = video ? 'video' : 'audio';
    receivers?.forEach((element) async {
      if (kind != element.track?.kind) return;
      var trackId = element.track?.id;
      var id = kind + '_' + trackId! + '_receiver';
      if (!_frameCyrptors.containsKey(id)) {
        var frameCyrptor =
            await _frameCyrptorFactory.createFrameCryptorForRtpReceiver(
                participantId: id,
                receiver: element,
                algorithm: Algorithm.kAesGcm,
                keyProvider: _keySharedProvider!);
        frameCyrptor.onFrameCryptorStateChanged = (participantId, state) =>
            print('DE onFrameCryptorStateChanged $participantId $state');
        _frameCyrptors[id] = frameCyrptor;
        await frameCyrptor.setKeyIndex(0);
      }

      var _frameCyrptor = _frameCyrptors[id];
      await _frameCyrptor?.setEnabled(enabled);
      await _frameCyrptor?.updateCodec(
          kind == 'video' ? videoDropdownValue : audioDropdownValue);
    });
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

    // Stop and dispose CallQualityManager
    await _callQualityManager?.dispose();
    _callQualityManager = null;
    print('CallQualityManager disposed on hangup.');

    setState(() {
      _inCalling = false;
    });
  }

  void _ratchetKey() async {
    var newKey = await _keySharedProvider?.ratchetSharedKey(index: 0);
    print('newKey $newKey');
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
    try {
      var newStream = await navigator.mediaDevices
          .getUserMedia(_getMediaConstraints(audio: false, video: true));

      // Stop existing video tracks before adding new ones to avoid multiple video tracks in _localStream
      if (_localStream != null) {
        await _removeExistingVideoTrack(stopTracks: true); // Ensure old tracks are stopped
      }

      if (_localStream == null) {
        _localStream = newStream;
        // Listen to active state of the newly created local stream
        _localStream?.onActiveStateChanged.listen((isActive) {
          print('Local stream active state changed: $isActive');
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Local stream active state: ${isActive ? "Active" : "Inactive"}'),
              duration: Duration(seconds: 1),
            ));
          }
        });
      } else {
        // Add new video tracks to existing _localStream
        for (var track in newStream.getVideoTracks()) {
          await _localStream!.addTrack(track); // This will also subscribe in MediaStreamNative
        }
      }

      // Setup onEnded listener for the first video track of the local stream
      _localStream?.getVideoTracks().firstOrNull?.onEnded.listen((_) {
        print('Local video track ${ _localStream?.getVideoTracks().firstOrNull?.id} ended.');
         if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Your video track ended!'),
            ));
            // CallQualityManager will attempt auto-restart if enabled.
            // UI might need to reflect that camera is off.
            setState(() { _cameraOn = false; });
         }
      });

      await _addOrReplaceVideoTracks(); // This adds tracks to PC and sets _videoSender
    } on PermissionDeniedError catch (e) {
      print('Permission denied for video: ${e.message}');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Video permission denied: ${e.message}. Please check settings.'),
          backgroundColor: Colors.red,
        ));
      }
      return; // Don't proceed if permission denied
    } on NotFoundError catch (e) {
      print('Video device not found: ${e.message}');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No video device found: ${e.message}'),
          backgroundColor: Colors.red,
        ));
      }
      return; // Don't proceed if no device
    } catch (e) {
      print('Error starting video: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error starting video: $e'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    var transceivers = await _localPeerConnection?.getTransceivers();
    transceivers?.forEach((transceiver) {
      if (transceiver.sender.senderId != _videoSender?.senderId) return;
      var codecs = vcaps?.codecs
              ?.where((element) => element.mimeType
                  .toLowerCase()
                  .contains(videoDropdownValue.toLowerCase()))
              .toList() ??
          [];
      transceiver.setCodecPreferences(codecs);
    });
    await _negotiate();

    setState(() {
      _localRenderer.srcObject = _localStream;
      _cameraOn = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //handleStatsReport(timer);
    });
  }

  void _stopVideo() async {
    _frameCyrptors.removeWhere((key, value) {
      if (key.startsWith('video')) {
        value.dispose();
        return true;
      }
      return false;
    });

    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });

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
    try {
      var newStream = await navigator.mediaDevices
          .getUserMedia(_getMediaConstraints(audio: true, video: false));

      // Stop existing audio tracks before adding new ones
      if (_localStream != null) {
         await _removeExistingAudioTrack(stopTracks: true); // Ensure old tracks are stopped
      }

      if (_localStream == null) {
        _localStream = newStream;
         // Listen to active state of the newly created local stream
        _localStream?.onActiveStateChanged.listen((isActive) {
          print('Local stream active state changed: $isActive');
           if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Local stream active state: ${isActive ? "Active" : "Inactive"}'),
              duration: Duration(seconds: 1),
            ));
          }
        });
      } else {
        for (var track in newStream.getAudioTracks()) {
          await _localStream!.addTrack(track);
        }
      }

      // Setup onEnded listener for the first audio track of the local stream
      _localStream?.getAudioTracks().firstOrNull?.onEnded.listen((_) {
        print('Local audio track ${ _localStream?.getAudioTracks().firstOrNull?.id} ended.');
        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Your audio track ended!'),
            ));
            // CallQualityManager will attempt auto-restart if enabled.
            // UI might need to reflect that mic is off.
            setState(() { _micOn = false; });
        }
      });

      await _addOrReplaceAudioTracks(); // This adds tracks to PC and sets _audioSender
    } on PermissionDeniedError catch (e) {
      print('Permission denied for audio: ${e.message}');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Audio permission denied: ${e.message}. Please check settings.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    } on NotFoundError catch (e) {
      print('Audio device not found: ${e.message}');
       if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No audio device found: ${e.message}'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    } catch (e) {
      print('Error starting audio: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error starting audio: $e'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }
    var transceivers = await _localPeerConnection?.getTransceivers();
    transceivers?.forEach((transceiver) {
      if (transceiver.sender.senderId != _audioSender?.senderId) return;
      var codecs = acaps?.codecs
              ?.where((element) => element.mimeType
                  .toLowerCase()
                  .contains(audioDropdownValue.toLowerCase()))
              .toList() ??
          [];
      transceiver.setCodecPreferences(codecs);
    });
    await _negotiate();
    setState(() {
      _micOn = true;
    });
  }

  void _stopAudio() async {
    _frameCyrptors.removeWhere((key, value) {
      if (key.startsWith('audio')) {
        value.dispose();
        return true;
      }
      return false;
    });
    await _removeExistingAudioTrack(fromConnection: true);
    await _negotiate();
    setState(() {
      _micOn = false;
    });
  }

  void _switchSpeaker() async {
    setState(() {
      _speakerOn = !_speakerOn;
      if (!WebRTC.platformIsWeb) {
        Helper.setSpeakerphoneOn(_speakerOn);
      }
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

  // Added stopTracks parameter to ensure tracks are fully stopped.
  Future<void> _removeExistingVideoTrack({bool fromConnection = false, bool stopTracks = false}) async {
    if (_localStream == null) return;
    var tracks = _localStream!.getVideoTracks();
    for (var i = tracks.length - 1; i >= 0; i--) {
      var track = tracks[i];
      if (fromConnection) {
        await _connectionRemoveTrack(track);
      }
      try {
        // Removing from MediaStream also cancels its onEnded subscription internally
        await _localStream!.removeTrack(track);
      } catch (e) {
        print(e.toString());
      }
      if (stopTracks) { // Explicitly stop if requested
        await track.stop();
      }
    }
  }

  Future<void> _removeExistingAudioTrack({bool fromConnection = false, bool stopTracks = false}) async {
    if (_localStream == null) return;
    var tracks = _localStream!.getAudioTracks();
    for (var i = tracks.length - 1; i >= 0; i--) {
      var track = tracks[i];
      if (fromConnection) {
        await _connectionRemoveTrack(track);
      }
      try {
        await _localStream!.removeTrack(track);
      } catch (e) {
        print(e.toString());
      }
       if (stopTracks) { // Explicitly stop if requested
        await track.stop();
      }
    }
  }

  // Example function to demonstrate setting preferred codecs with addTransceiver
  // This is not directly integrated into the main call flow to keep changes minimal,
  // but shows how it could be used.
  Future<void> _addVideoTransceiverWithPreferredCodecs() async {
    if (_localPeerConnection == null || _localStream == null) {
      print('PeerConnection or LocalStream not ready for addTransceiver example.');
      return;
    }
    var videoTrack = _localStream!.getVideoTracks().firstOrNull;
    if (videoTrack == null) {
      print('No local video track available to add with transceiver.');
      return;
    }

    try {
      print('Getting video capabilities for preferred codecs example...');
      var videoCapabilities = await RTCRtpSender.getCapabilities('video');
      List<RTCRtpCodecCapability> preferredCodecs = [];

      // Example: Prefer VP9, then H264 with a specific profile
      var vp9Cap = videoCapabilities.codecs?.firstWhere((c) => c.mimeType.toLowerCase() == 'video/vp9', orElse: () => null);
      if (vp9Cap != null) preferredCodecs.add(vp9Cap);

      var h264Cap = videoCapabilities.codecs?.firstWhere((c) => c.mimeType.toLowerCase() == 'video/h264', orElse: () => null);
      if (h264Cap != null) {
        h264Cap.profile = '42e01f'; // Example: Constrained Baseline profile-level-id
        // h264Cap.sdpFmtpLine = 'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f'; // More explicit
        preferredCodecs.add(h264Cap);
      }

      if (preferredCodecs.isEmpty) {
         print('Could not find specified preferred codecs in capabilities.');
         // Fallback or error
      }

      print('Adding video transceiver with preferred codecs: $preferredCodecs');
      await _localPeerConnection!.addTransceiver(
        track: videoTrack,
        init: RTCRtpTransceiverInit(
          direction: TransceiverDirection.SendRecv,
          streams: [_localStream!],
          preferredCodecs: preferredCodecs.isNotEmpty ? preferredCodecs : null,
        ),
      );
      print('Video transceiver added with preferred codecs (if any were chosen).');
      // Note: This might replace an existing sender if one was already created by addTrack.
      // This example doesn't manage _videoSender variable update for simplicity here.
      await _negotiate(); // Renegotiation needed after addTransceiver
    } catch (e) {
      print('Error in _addVideoTransceiverWithPreferredCodecs: $e');
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
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text('audio codec:'),
                DropdownButton<String>(
                  value: audioDropdownValue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                  ),
                  elevation: 16,
                  style: const TextStyle(color: Colors.blue),
                  underline: Container(
                    height: 2,
                    color: Colors.blueAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      audioDropdownValue = value!;
                    });
                  },
                  items: audioCodecList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text('video codec:'),
                DropdownButton<String>(
                  value: videoDropdownValue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                  ),
                  elevation: 16,
                  style: const TextStyle(color: Colors.blue),
                  underline: Container(
                    height: 2,
                    color: Colors.blueAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      videoDropdownValue = value!;
                    });
                  },
                  items: videoCodecList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextButton(onPressed: _ratchetKey, child: Text('Ratchet Key'))
              ],
            ),
            Row(
              children: [
                Text('audio encrypt:'),
                Switch(
                    value: _audioEncrypt,
                    onChanged: (value) {
                      setState(() {
                        _audioEncrypt = value;
                        _enableEncryption(video: false, enabled: _audioEncrypt);
                      });
                    }),
                Text('video encrypt:'),
                Switch(
                    value: _videoEncrypt,
                    onChanged: (value) {
                      setState(() {
                        _videoEncrypt = value;
                        _enableEncryption(video: true, enabled: _videoEncrypt);
                      });
                    })
              ],
            ),
            Expanded(
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ],
        )),
      ),
      Expanded(
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text('audio decrypt:'),
                Switch(
                    value: _audioDecrypt,
                    onChanged: (value) {
                      setState(() {
                        _audioDecrypt = value;
                        _enableDecryption(video: false, enabled: _audioDecrypt);
                      });
                    }),
                Text('video decrypt:'),
                Switch(
                    value: _videoDecrypt,
                    onChanged: (value) {
                      setState(() {
                        _videoDecrypt = value;
                        _enableDecryption(video: true, enabled: _videoDecrypt);
                      });
                    })
              ],
            ),
            Expanded(
              child: RTCVideoView(_remoteRenderer),
            ),
          ],
        )),
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
                child: OverflowBar(
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
