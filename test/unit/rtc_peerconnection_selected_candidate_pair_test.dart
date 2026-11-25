import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'package:flutter_webrtc/src/native/rtc_peerconnection_impl.dart';

const _local =
    'candidate:1 1 udp 2122260223 192.0.2.1 50000 typ host generation 1 ufrag AbCd network-id 1';
const _remote =
    'candidate:2 1 udp 2130706431 198.51.100.1 7882 typ host generation 1 ufrag RemoteUfrag';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final channel = MethodChannel('FlutterWebRTC.Method');
  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      await ServicesBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
              'FlutterWebRTC/peerConnectionEvent', null, (ByteData? data) {});
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  RTCIceCandidatePair? deliver(Map<String, dynamic> event) {
    final pc = RTCPeerConnectionNative('', {});
    RTCIceCandidatePair? received;
    pc.onSelectedCandidatePairChanged = (pair) => received = pair;
    pc.eventListener(event);
    return received;
  }

  void expectPair(RTCIceCandidatePair? pair) {
    expect(pair, isNotNull);
    expect(pair!.local.candidate, _local);
    expect(pair.local.sdpMid, '0');
    expect(pair.remote.candidate, _remote);
    expect(pair.local.usernameFragment, 'AbCd');
    expect(pair.remote.usernameFragment, 'RemoteUfrag');
    expect(pair.reason, 'candidate pair state changed');
    expect(pair.lastDataReceivedMs, 1234);
  }

  test('reads the pair iOS and macOS send at the top level of the event', () {
    expectPair(deliver(<String, dynamic>{
      'event': 'onSelectedCandidatePairChanged',
      'local': {'candidate': _local, 'sdpMLineIndex': -1, 'sdpMid': '0'},
      'remote': {'candidate': _remote, 'sdpMLineIndex': -1, 'sdpMid': '0'},
      'reason': 'candidate pair state changed',
      'lastDataReceivedMs': 1234,
    }));
  });

  test('reads the pair Android sends under candidate', () {
    expectPair(deliver(<String, dynamic>{
      'event': 'onSelectedCandidatePairChanged',
      'candidate': {
        'lastDataReceivedMs': 1234,
        'local': {'candidate': _local, 'sdpMLineIndex': -1, 'sdpMid': '0'},
        'remote': {'candidate': _remote, 'sdpMLineIndex': -1, 'sdpMid': '0'},
        'reason': 'candidate pair state changed',
      },
    }));
  });

  test('drops an event without both candidates', () {
    expect(
        deliver(<String, dynamic>{
          'event': 'onSelectedCandidatePairChanged',
          'local': {'candidate': _local, 'sdpMLineIndex': -1, 'sdpMid': '0'},
        }),
        isNull);
  });
}
