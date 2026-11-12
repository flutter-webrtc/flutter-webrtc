import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/native/rtc_peerconnection_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const peerConnectionId = 'pc-set-bitrate-test';
  final methodChannel = MethodChannel('FlutterWebRTC.Method');

  late List<MethodCall> calls;
  late Object? Function(MethodCall) reply;

  setUp(() {
    calls = <MethodCall>[];
    reply = (_) => true;
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method != 'setBitrate') return null;
      calls.add(methodCall);
      return reply(methodCall);
    });
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
  });

  test('sends every limit when all are set', () async {
    final pc = RTCPeerConnectionNative(peerConnectionId, {});

    final ok = await pc.setBitrate(
        minBitrate: 100000, startBitrate: 300000, maxBitrate: 2000000);

    expect(ok, isTrue);
    expect(calls, hasLength(1));
    expect(calls.single.method, 'setBitrate');
    expect(calls.single.arguments, <String, dynamic>{
      'peerConnectionId': peerConnectionId,
      'minBitrate': 100000,
      'startBitrate': 300000,
      'maxBitrate': 2000000,
    });
  });

  test('omits keys for limits that are not set', () async {
    final pc = RTCPeerConnectionNative(peerConnectionId, {});

    await pc.setBitrate(startBitrate: 1000000);

    expect(calls.single.arguments, <String, dynamic>{
      'peerConnectionId': peerConnectionId,
      'startBitrate': 1000000,
    });
  });

  test('returns false when the platform rejects the values', () async {
    reply = (_) => false;
    final pc = RTCPeerConnectionNative(peerConnectionId, {});

    final ok = await pc.setBitrate(minBitrate: 2000000, startBitrate: 1000000);

    expect(ok, isFalse);
  });

  test('reports a platform error as a thrown message', () async {
    reply = (_) => throw PlatformException(
        code: 'setBitrateFailed', message: 'peerConnection is null');
    final pc = RTCPeerConnectionNative(peerConnectionId, {});

    await expectLater(
        pc.setBitrate(maxBitrate: 500000),
        throwsA(
            'Unable to RTCPeerConnection::setBitrate: peerConnection is null'));
  });
}
