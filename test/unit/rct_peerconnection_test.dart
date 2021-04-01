import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/native/rtc_peerconnection_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final channel = WebRTC.methodChannel();
  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      await ServicesBinding.instance?.defaultBinaryMessenger
          .handlePlatformMessage(
              'FlutterWebRTC/peerConnectoinEvent', null, (ByteData? data) {});
      await ServicesBinding.instance?.defaultBinaryMessenger
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
    final rct = RTCPeerConnectionNative('', {});
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

    events.forEach((event) {
      rct.eventListener(<String, dynamic>{
        'event': event,

        //Minimum values for signalingState, iceGatheringState, iceConnectionState
        'state': 'stable', // just picking one valid value from the list

        //Minimum values for onCandidate
        'candidate': {'candidate': '', 'sdpMid': '', 'sdpMLineIndex': 1},

        //Minimum values for onAddStream
        'streamId': '',
        'audioTracks': [],
        'videoTracks': [],

        //Minimum values for onAddTrack
        'track': {
          'trackId': '',
          'label': '',
          'kind': '',
          'enabled': false,
        }
      });
    });
  });
}
