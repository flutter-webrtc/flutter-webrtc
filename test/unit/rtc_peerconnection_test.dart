import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/native/rtc_data_channel_impl.dart';
import 'package:flutter_webrtc/src/native/rtc_peerconnection_impl.dart';
import 'package:flutter_webrtc/src/native/rtc_rtp_receiver_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final channel = MethodChannel('FlutterWebRTC.Method');
  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      await ServicesBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
              'FlutterWebRTC/peerConnectionEvent', null, (ByteData? data) {});
      await ServicesBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
              'FlutterWebRTC/dataChannelEvent', null, (ByteData? data) {});
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test(
      'Validate that not setting any public delegate this will not break the implementation by throwing NPE',
      () {
    final pc = RTCPeerConnectionNative('', {});
    final events = [
      'signalingState',
      'iceGatheringState',
      'iceConnectionState',
      'onCandidate',
      'onAddStream',
      'onRemoveStream',
      'onAddTrack',
      'onRemoveTrack',
      'didOpenDataChannel',
      'onRenegotiationNeeded'
    ];

    pc.onDataChannel = (dc) {
      final channel = dc as RTCDataChannelNative;
      channel.eventListener(<String, dynamic>{
        'event': 'dataChannelStateChanged',
        'id': 0,
        'flutterId': '',
        'state': 'open'
      });
    };

    for (var event in events) {
      pc.eventListener(<String, dynamic>{
        'event': event,

        //Minimum values for signalingState, iceGatheringState, iceConnectionState
        'state': 'stable', // just picking one valid value from the list

        //Minimum values for onCandidate
        'candidate': {'candidate': '', 'sdpMid': '', 'sdpMLineIndex': 1},

        //Minimum values for onAddStream
        'streamId': '',
        'audioTracks': [],
        'videoTracks': [],

        //Minimum values for onRemoveTrack
        'trackId': '',

        //Minimum values for onAddTrack
        'track': {
          'id': '',
          'label': '',
          'kind': '',
          'enabled': false,
        },
        'id': 0,
        'label': '',
        'flutterId': '',
      });
    }
  });

  group('onTrack receiver', () {
    final parameters = {
      'encodings': [],
      'headerExtensions': [],
      'codecs': [],
      'rtcp': {'cname': '', 'reducedSize': false},
    };
    final track = {'id': 'TR_a', 'label': '', 'kind': 'video', 'enabled': true};
    final receiver = {
      'receiverId': 'TR_a',
      'track': track,
      'rtpParameters': parameters,
    };

    String? receivedTransceiverId(Map<String, dynamic> event) {
      final pc = RTCPeerConnectionNative('', {});
      String? id;
      pc.onTrack =
          (e) => id = (e.receiver as RTCRtpReceiverNative).transceiverId;
      pc.eventListener(event);
      return id;
    }

    test('carries the transceiver id of its event', () {
      expect(
          receivedTransceiverId({
            'event': 'onTrack',
            'streams': [],
            'track': track,
            'receiver': receiver,
            'transceiver': {
              'transceiverId': 'transceiver-1',
              'direction': 'recvonly',
              'mid': '1',
              'sender': {
                'senderId': 's',
                'track': {},
                'rtpParameters': parameters,
                'ownsTrack': false,
              },
              'receiver': receiver,
            },
          }),
          'transceiver-1');
    });

    test('has none without a transceiver', () {
      expect(
          receivedTransceiverId({
            'event': 'onTrack',
            'streams': [],
            'track': track,
            'receiver': receiver,
          }),
          isNull);
    });
  });
}
