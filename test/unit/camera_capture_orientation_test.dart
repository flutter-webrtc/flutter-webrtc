import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/native/media_stream_track_impl.dart';

void main() {
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  const channel = MethodChannel('FlutterWebRTC.Method');
  const setOrientation = 'mediaStreamTrackSetCameraCaptureOrientation';
  final camera = MediaStreamTrackNative('camera-1', '', 'video', true, 'local');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'initialize') calls.add(call);
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test('$platform sends every lock and then restores automatic orientation',
        () async {
      debugDefaultTargetPlatformOverride = platform;
      for (final orientation in DeviceOrientation.values) {
        await Helper.lockCameraCaptureOrientation(camera, orientation);
      }
      await Helper.unlockCameraCaptureOrientation(camera);

      expect(calls.map((call) => call.method), everyElement(setOrientation));
      expect(calls.map((call) => call.arguments), [
        for (final name in [
          'portraitUp',
          'landscapeLeft',
          'portraitDown',
          'landscapeRight',
          null
        ])
          {'trackId': 'camera-1', 'orientation': name},
      ]);
    });
  }

  test('an unsupported platform never calls the native camera', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    await expectLater(
        Helper.unlockCameraCaptureOrientation(camera), throwsUnsupportedError);
    expect(calls, isEmpty);
  });

  test('an audio track cannot select a camera', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final mic = MediaStreamTrackNative('mic', '', 'audio', true, 'local');
    await expectLater(
        Helper.lockCameraCaptureOrientation(mic, DeviceOrientation.portraitUp),
        throwsArgumentError);
    expect(calls, isEmpty);
  });

  test('reports a camera removed between obtaining the track and locking it',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'initialize') return null;
      throw PlatformException(code: 'camera_not_found');
    });
    await expectLater(
        Helper.lockCameraCaptureOrientation(
            camera, DeviceOrientation.portraitUp),
        throwsA(isA<PlatformException>()
            .having((error) => error.code, 'code', 'camera_not_found')));
  });

  test('a received track cannot change a local camera with the same id',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final received =
        MediaStreamTrackNative(camera.id, '', 'video', true, 'receiving-peer');
    await expectLater(
        Helper.lockCameraCaptureOrientation(
            received, DeviceOrientation.portraitUp),
        throwsArgumentError);
    expect(calls, isEmpty);
  });
}
