import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/native/rtc_peerconnection_impl.dart';

/// Pins the platform-channel call order that the darwin native plugin
/// relies on when a peer connection is torn down.
///
/// close() invokes peerConnectionClose, and dispose() must cancel the
/// event channel subscription before it invokes peerConnectionDispose.
/// The darwin plugin only releases the event channel's stream handler
/// on peerConnectionDispose. If cancel reached the platform after that
/// call, the handler would already be gone and Flutter would report a
/// MissingPluginException for the event channel's cancel method instead
/// of tearing down cleanly.
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

    // Both calls are recorded synchronously by the mock handlers while
    // dispose() is awaited. Yield once more anyway so nothing is left pending.
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
