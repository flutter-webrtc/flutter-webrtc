import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/native/media_stream_track_impl.dart';
import 'package:flutter_webrtc/src/native/remote_audio_tap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('FlutterWebRTC.Method');
  final calls = <MethodCall>[];
  final audio =
      MediaStreamTrackNative('remote-audio', 'audio', 'audio', true, 'pc');
  final video =
      MediaStreamTrackNative('remote-video', 'video', 'video', true, 'pc');

  if (!Platform.isWindows && !Platform.isMacOS) {
    test('unsupported platforms reject remote audio taps', () async {
      await expectLater(
          RTCRemoteAudioTap.attach(audio), throwsUnsupportedError);
    });
    return;
  }

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'remoteAudioTapAttach':
          return {'tapId': 'tap1'};
        case 'remoteAudioTapStats':
          return {'deliveredFrames': 480};
      }
      return null;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  test('attach sends the track id and the silence option', () async {
    final tap = await RTCRemoteAudioTap.attach(audio);
    // WebRTC.invokeMethod may initialize the plugin first; the tap adds one call.
    final attach =
        calls.where((c) => c.method == 'remoteAudioTapAttach').single;
    expect(attach.arguments,
        {'trackId': 'remote-audio', 'silenceNativePlayout': true});
    calls.clear();
    expect(tap.id, 'tap1');
    expect((await tap.stats())['deliveredFrames'], 480);
    await tap.detach();
    await tap.detach(); // idempotent
    expect(
        calls.where((c) => c.method == 'remoteAudioTapDetach'), hasLength(1));
    expect(calls.map((c) => c.method),
        ['remoteAudioTapStats', 'remoteAudioTapDetach']);
    expect(await tap.stats(), isEmpty);
  });

  test('silencing the native playout is optional', () async {
    await RTCRemoteAudioTap.attach(audio, silenceNativePlayout: false);
    expect(
        calls
            .where((c) => c.method == 'remoteAudioTapAttach')
            .single
            .arguments['silenceNativePlayout'],
        false);
  });

  test('video tracks are rejected before any native call', () async {
    await expectLater(RTCRemoteAudioTap.attach(video), throwsArgumentError);
    expect(calls.where((c) => c.method.startsWith('remoteAudioTap')), isEmpty);
  });

  test('PCM events are decoded from the per-tap event channel', () async {
    final tap = await RTCRemoteAudioTap.attach(audio);
    final first = tap.pcm.first;
    const codec = StandardMethodCodec();
    final data = Uint8List.fromList(List.filled(960, 1));
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
            'FlutterWebRTC/remoteAudioTap/tap1',
            codec.encodeSuccessEnvelope({
              'data': data,
              'sampleRate': 48000,
              'channels': 1,
              'frames': 480
            }),
            (_) {});
    final pcm = await first;
    expect(pcm.sampleRate, 48000);
    expect(pcm.channels, 1);
    expect(pcm.frames, 480);
    expect(pcm.data, data);
  });
}
