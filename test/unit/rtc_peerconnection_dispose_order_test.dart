import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/native/rtc_peerconnection_impl.dart';

/// Pins the platform-channel call order that the darwin native plugin
/// relies on when a peer connection is torn down.
///
/// close() invokes peerConnectionClose, and dispose() must cancel the
/// event channel subscription before it invokes peerConnectionDispose.
/// The darwin plugin only releases the event channel's stream handler
/// on peerConnectionDispose, so if cancel is sent after (or is skipped
/// before) that call, the platform side is already gone and Flutter
/// reports a MissingPluginException for the event channel's cancel
/// method instead of tearing down cleanly.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const peerConnectionId = 'pc-order-test';
  final methodChannel = MethodChannel('FlutterWebRTC.Method');
  final eventChannel =
      MethodChannel('FlutterWebRTC/peerConnectionEvent$peerConnectionId');

  final calls = <String>[];

  setUp(() {
    calls.clear();
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      calls.add(methodCall.method);
      return null;
    });
    eventChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      calls.add('event:${methodCall.method}');
      return null;
    });
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
    eventChannel.setMockMethodCallHandler(null);
  });

  test('close then dispose cancels the event subscription before disposing',
      () async {
    final pc = RTCPeerConnectionNative(peerConnectionId, {});

    // Let the constructor's subscription reach the platform side.
    await Future<void>.delayed(Duration.zero);

    await pc.close();
    await pc.dispose();

    // Flush again so the async cancel/dispose calls are fully recorded.
    await Future<void>.delayed(Duration.zero);

    expect(calls, contains('peerConnectionClose'));
    expect(calls, contains('event:listen'));
    expect(calls, contains('event:cancel'));
    expect(calls, contains('peerConnectionDispose'));

    expect(
        calls.indexOf('event:listen'), lessThan(calls.indexOf('event:cancel')));
    expect(calls.indexOf('event:cancel'),
        lessThan(calls.indexOf('peerConnectionDispose')));
  });
}
