import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/native/external_media.dart';
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
      if (call.method == 'externalMediaCreate') {
        return {
          'streamId': 'external',
          'ownerTag': 'local',
          'audioTracks': [
            {
              'id': 'audio',
              'label': 'external',
              'kind': 'audio',
              'enabled': true
            }
          ],
          'videoTracks': [
            {
              'id': 'video',
              'label': 'external',
              'kind': 'video',
              'enabled': true
            }
          ],
          'renderReference': false,
          'videoTimestampSource': 'arrival'
        };
      }
      return null;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));
  test('creation never invokes device capture and keeps factory policy',
      () async {
    final source = await RTCExternalMediaSource.create();
    expect(calls.map((c) => c.method), ['initialize', 'externalMediaCreate']);
    expect(calls.first.arguments['options']['externalAudioInputOnly'], true);
    expect(source.stream.getTracks(), hasLength(2));
    expect(source.hasRenderReference, false);
    expect(() => source.renderReference, throwsUnsupportedError);
    await source.dispose();
  });
  test('invalid buffers and timestamps never reach native injection', () async {
    final source = await RTCExternalMediaSource.create();
    await expectLater(source.pushAudio(Uint8List(958)), throwsArgumentError);
    await expectLater(
        source.pushVideo(Uint8List(4), 2, 2, 0), throwsArgumentError);
    await source.pushVideo(Uint8List(4), 1, 1, 10);
    await expectLater(
        source.pushVideo(Uint8List(4), 1, 1, 10), throwsArgumentError);
    expect(calls.where((c) => c.method == 'externalMediaAudio'), isEmpty);
    expect(calls.where((c) => c.method == 'externalMediaVideo'), hasLength(1));
    await source.dispose();
  });
  test('dispose is idempotent and prevents any further native writes',
      () async {
    final source = await RTCExternalMediaSource.create();
    await source.pushAudio(Uint8List(960));
    await source.flush();
    await source.dispose();
    await source.dispose();
    await expectLater(source.pushAudio(Uint8List(960)), throwsStateError);
    await expectLater(source.stats(), throwsStateError);
    expect(
        calls.where((c) => c.method == 'externalMediaDispose'), hasLength(1));
  });
}
