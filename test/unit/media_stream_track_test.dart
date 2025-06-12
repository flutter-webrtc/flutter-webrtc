import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_webrtc/src/native/media_stream_track_impl.dart';
import 'package:flutter_webrtc/src/native/media_devices_impl.dart'; // For navigator.mediaDevices
import 'package:webrtc_interface/webrtc_interface.dart'; // For MediaStream, RTCIceGatheringState etc.

// Mocking WebRTC.invokeMethod is a bit tricky due to its static nature.
// One common approach is to use a mockable wrapper or a testing plugin.
// For this test, we'll assume a basic way to mock/verify its calls,
// or focus on the Dart logic that leads up to it.
// A simple way for this test is to use a mock MethodChannel.
class MockMethodChannel extends Mock implements MethodChannel {}

// Mock MediaDevices to control getUserMedia behavior
class MockMediaDevices extends Mock implements MediaDevices {}

// Mock MediaStream that can be returned by getUserMedia
class MockMediaStream extends Mock implements MediaStream {
  final List<MediaStreamTrack> _audioTracks = [];
  final List<MediaStreamTrack> _videoTracks = [];

  MockMediaStream({List<MediaStreamTrack>? audioTracks, List<MediaStreamTrack>? videoTracks}) {
    if (audioTracks != null) _audioTracks.addAll(audioTracks);
    if (videoTracks != null) _videoTracks.addAll(videoTracks);
  }

  @override
  List<MediaStreamTrack> getAudioTracks() => _audioTracks;
  @override
  List<MediaStreamTrack> getVideoTracks() => _videoTracks;
  @override
  String get id => 'mockStreamId'; // Or make it configurable
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Needed for MethodChannel mocking

  late MockMethodChannel mockChannel;
  // Original MethodCallHandler for WebRTC.methodChannel
  MethodCallHandler? originalMethodCallHandler;

  setUp(() {
    // Mock the method channel used by WebRTC.invokeMethod
    mockChannel = MockMethodChannel();
    originalMethodCallHandler = WebRTC.methodChannel.checkMockMethodCallHandler((call) => null);

    WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      // Default mock behavior: return null or a specific value if needed for a call
      if (methodCall.method == 'trackDispose') {
        return null; // Simulate successful dispose
      }
      if (methodCall.method == 'mediaStreamTrackSetEnable') {
        return null;
      }
      // Let other calls pass through to the mockChannel if needed, or handle here
      return mockChannel.invokeMethod(methodCall.method, methodCall.arguments);
    });
  });

  tearDown(() {
    WebRTC.methodChannel.setMockMethodCallHandler(originalMethodCallHandler);
  });

  group('MediaStreamTrackNative onEnded and readyState', () {
    test('setEnded() updates readyState and fires onEnded stream', () async {
      final track = MediaStreamTrackNative('testTrackId', 'label', 'audio', true, 'local', {}, true);

      expect(track.readyState, 'live');
      bool onEndedFired = false;
      final sub = track.onEnded.listen((_) {
        onEndedFired = true;
      });

      track.setEnded();

      expect(track.readyState, 'ended');
      // Wait for stream event to propagate
      await Future.delayed(Duration.zero);
      expect(onEndedFired, isTrue);
      expect(track.enabled, isFalse); // setEnded should also disable

      // Calling setEnded again should do nothing
      onEndedFired = false; // Reset
      track.setEnded();
      await Future.delayed(Duration.zero);
      expect(onEndedFired, isFalse); // Controller is closed, should not fire again

      await sub.cancel();
    });

    test('stop() updates readyState and fires onEnded stream', () async {
      final track = MediaStreamTrackNative('testTrackId', 'label', 'audio', true, 'local', {}, true);

      expect(track.readyState, 'live');
      bool onEndedFired = false;
      final sub = track.onEnded.listen((_) {
        onEndedFired = true;
      });

      await track.stop(); // stop calls setEnded

      expect(track.readyState, 'ended');
      await Future.delayed(Duration.zero);
      expect(onEndedFired, isTrue);

      // Verify native trackDispose was called
      // This requires more complex MethodChannel mocking to capture calls.
      // For now, we trust stop() calls it.

      await sub.cancel();
    });
  });

  group('MediaStreamTrackNative restart()', () {
    late MediaStreamTrackNative localVideoTrack;
    late MockMediaDevices mockNavigatorMediaDevices;

    // Store original navigator.mediaDevices and restore it
    late MediaDevices originalMediaDevices;

    setUp(() {
      mockNavigatorMediaDevices = MockMediaDevices();
      // Replace the global navigator.mediaDevices with our mock
      originalMediaDevices = navigator.mediaDevices;
      navigator.mediaDevices = mockNavigatorMediaDevices;

      localVideoTrack = MediaStreamTrackNative(
        'localVideo1', 'label', 'video', true, 'pc1', {}, true // isLocal = true
      );
    });

    tearDown(() {
      // Restore original mediaDevices
      navigator.mediaDevices = originalMediaDevices;
    });

    test('throws error if called on a remote track', () async {
      final remoteTrack = MediaStreamTrackNative(
        'remoteVideo1', 'label', 'video', true, 'pc1', {}, false // isLocal = false
      );
      expect(
        () async => await remoteTrack.restart({}),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('non-local track')))
      );
    });

    test('calls stop() on the original track', () async {
      // Arrange
      final Map<String,dynamic> constraints = {'video': true};
      final newVideoTrack = MediaStreamTrackNative('newVideoId', 'new label', 'video', true, 'local', {}, true);
      final newStream = MockMediaStream(videoTracks: [newVideoTrack]);

      when(mockNavigatorMediaDevices.getUserMedia(constraints))
          .thenAnswer((_) async => newStream);

      // Spy on localVideoTrack.stop() - or check side effects like readyState
      bool originalTrackStopped = false;
      localVideoTrack.onEnded.listen((_) => originalTrackStopped = true );

      // Act
      await localVideoTrack.restart(constraints);

      // Assert
      expect(originalTrackStopped, isTrue);
      expect(localVideoTrack.readyState, 'ended');
    });

    test('calls navigator.mediaDevices.getUserMedia() with correct constraints', () async {
      final Map<String,dynamic> constraints = {'video': true, 'width': 1280};
      final newVideoTrack = MediaStreamTrackNative('newVideoId', 'new label', 'video', true, 'local', {}, true);
      final newStream = MockMediaStream(videoTracks: [newVideoTrack]);

      when(mockNavigatorMediaDevices.getUserMedia(any)) // Use any initially
          .thenAnswer((_) async => newStream);

      await localVideoTrack.restart(constraints);

      verify(mockNavigatorMediaDevices.getUserMedia(constraints)).called(1);
    });

    test('returns a new track of the correct kind on success', () async {
      final Map<String,dynamic> constraints = {'video': true};
      final newVideoTrack = MediaStreamTrackNative('newVideoId', 'new label', 'video', true, 'local', {}, true);
      final newStream = MockMediaStream(videoTracks: [newVideoTrack]);

      when(mockNavigatorMediaDevices.getUserMedia(constraints))
          .thenAnswer((_) async => newStream);

      final resultTrack = await localVideoTrack.restart(constraints);

      expect(resultTrack, isNotNull);
      expect(resultTrack, isA<MediaStreamTrackNative>());
      expect(resultTrack!.id, 'newVideoId');
      expect(resultTrack.kind, 'video');
      expect(resultTrack.isLocal, true); // New track from getUserMedia should be local
    });

     test('returns null if getUserMedia fails to return a track of the same kind', () async {
      final Map<String,dynamic> constraints = {'video': true};
      // Simulate getUserMedia returning a stream with only an audio track
      final newAudioTrack = MediaStreamTrackNative('newAudioId', 'new label', 'audio', true, 'local', {}, true);
      final newStream = MockMediaStream(audioTracks: [newAudioTrack]);

      when(mockNavigatorMediaDevices.getUserMedia(constraints))
          .thenAnswer((_) async => newStream);

      final resultTrack = await localVideoTrack.restart(constraints);

      expect(resultTrack, isNull);
    });

    test('returns null and handles exception if getUserMedia throws', () async {
      final Map<String,dynamic> constraints = {'video': true};

      when(mockNavigatorMediaDevices.getUserMedia(constraints))
          .thenThrow(PlatformException(code: 'ERROR', message: 'getUserMedia failed'));

      final resultTrack = await localVideoTrack.restart(constraints);
      expect(resultTrack, isNull);
    });

     test('propagates MediaDeviceAcquireError if getUserMedia throws it', () async {
      final Map<String,dynamic> constraints = {'video': true};

      when(mockNavigatorMediaDevices.getUserMedia(constraints))
          .thenThrow(PermissionDeniedError('Permission denied by user'));

      expect(
        () async => await localVideoTrack.restart(constraints),
        throwsA(isA<PermissionDeniedError>())
      );
    });

  });
}

// Helper to ensure navigator.mediaDevices can be mocked
// This would typically be handled by the plugin's test setup if it uses a specific navigator instance.
// For this standalone test, we temporarily replace the global static accessor.
class TestNavigator {
  MediaDevices mediaDevices = MockMediaDevices(); // Default to a mock
}
final TestNavigator testNavigator = TestNavigator();

// This is a bit of a hack to allow mocking navigator.mediaDevices
// In a real plugin, you'd likely have an injectable MediaDevices service.
// For now, MediaStreamTrackNative directly calls the global `navigator.mediaDevices`.
// This setup assumes MediaStreamTrackNative uses `import 'package:webrtc_interface/webrtc_interface.dart';`
// which exports a top-level `navigator` object.
// If it uses a different way to access mediaDevices, this mock setup needs adjustment.
// This shows the difficulty of mocking global/static accessors.
// The actual `MediaStreamTrackNative` uses `navigator.mediaDevices.getUserMedia`.
// The `navigator` object is from `package:webrtc_interface/src/navigator.dart`.
// We need to ensure this global `navigator` uses our mock `mediaDevices`.
// This is usually done by configuring the `WebRTCPlatform.instance`.
// For this unit test, direct replacement is simpler if the structure allows.
// The provided `media_stream_track_impl.dart` uses `navigator.mediaDevices...` so this should work.
