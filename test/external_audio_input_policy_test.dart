import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/native/utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('FlutterWebRTC.Method');
  final calls = <MethodCall>[];
  setUp(() {
    WebRTC.initialized = false;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));
  test('default policy and implicit repeated initialization preserve factory',
      () async {
    await WebRTC.initialize();
    await WebRTC.initialize();
    expect(calls, hasLength(1));
    expect(WebRTC.externalAudioInputOnly, isFalse);
    expect(() => WebRTC.initialize(options: {'externalAudioInputOnly': true}),
        throwsStateError);
    expect(calls, hasLength(1));
  });
  test('rejects invalid policy without touching native code', () async {
    await expectLater(
        WebRTC.initialize(options: {'externalAudioInputOnly': 'true'}),
        throwsArgumentError);
    expect(calls, isEmpty);
  });
  test('concurrent requests share initialization', () async {
    final ready = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return ready.future;
    });
    final first = WebRTC.initialize();
    final second = WebRTC.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(calls, hasLength(1));
    ready.complete();
    await Future.wait([first, second]);
  });
  test('failed native initialization can be retried', () async {
    var attempt = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (++attempt == 1) throw PlatformException(code: 'unsupported');
      return null;
    });
    await expectLater(WebRTC.initialize(), throwsA(isA<PlatformException>()));
    expect(WebRTC.initialized, isFalse);
    await WebRTC.initialize();
    expect(calls, hasLength(2));
  });
  test('external-only either forwards or rejects before factory creation',
      () async {
    if (Platform.isWindows || Platform.isMacOS) {
      await WebRTC.initialize(options: {'externalAudioInputOnly': true});
      await WebRTC.initialize();
      expect(calls, hasLength(1));
      expect(WebRTC.externalAudioInputOnly, isTrue);
      await expectLater(
          WebRTC.initialize(options: {'externalAudioInputOnly': false}),
          throwsStateError);
    } else {
      await expectLater(
          WebRTC.initialize(options: {'externalAudioInputOnly': true}),
          throwsUnsupportedError);
      expect(calls, isEmpty);
    }
  });
}
