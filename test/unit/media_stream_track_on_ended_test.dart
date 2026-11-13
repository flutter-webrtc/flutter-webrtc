import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/native/media_stream_track_impl.dart';

/// MediaStreamTrack.onEnded fires when the native side sends the
/// `mediaStreamTrackEnded` event for the track on the plugin event channel.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = StandardMethodCodec();
  final methodChannel = MethodChannel('FlutterWebRTC.Method');
  final eventChannel = MethodChannel('FlutterWebRTC.Event');

  Future<void> sendTrackEnded(String trackId) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'FlutterWebRTC.Event',
      codec.encodeSuccessEnvelope(<String, dynamic>{
        'event': 'mediaStreamTrackEnded',
        'trackId': trackId,
      }),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);
  }

  MediaStreamTrackNative screenTrack(String id) =>
      MediaStreamTrackNative(id, 'video', 'video', true, '');

  setUp(() {
    methodChannel.setMockMethodCallHandler((_) async => null);
    eventChannel.setMockMethodCallHandler((_) async => null);
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
    eventChannel.setMockMethodCallHandler(null);
  });

  test('fires once for its own track id', () async {
    final track = screenTrack('track-a');
    var ended = 0;
    track.onEnded = () => ended++;
    await Future<void>.delayed(Duration.zero);

    await sendTrackEnded('track-b');
    expect(ended, 0);

    await sendTrackEnded('track-a');
    expect(ended, 1);

    await sendTrackEnded('track-a');
    expect(ended, 1);
  });

  test('does not fire after the handler is cleared', () async {
    final track = screenTrack('track-c');
    var ended = 0;
    track.onEnded = () => ended++;
    track.onEnded = null;

    await sendTrackEnded('track-c');
    expect(ended, 0);
    expect(track.onEnded, isNull);
  });

  test('does not fire after the track is stopped', () async {
    final track = screenTrack('track-d');
    var ended = 0;
    track.onEnded = () => ended++;
    await track.stop();

    await sendTrackEnded('track-d');
    expect(ended, 0);
  });
}
