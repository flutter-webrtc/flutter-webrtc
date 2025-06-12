import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_webrtc/src/call_quality_manager.dart'; // Adjust if path is different
import 'package:webrtc_interface/webrtc_interface.dart';

// Manual Mocks
class MockRTCPeerConnection extends Mock implements RTCPeerConnection {}
class MockRTCRtpSender extends Mock implements RTCRtpSender {}
class MockMediaStreamTrack extends Mock implements MediaStreamTrack {}
class MockRTCRtpParameters extends Mock implements RTCRtpParameters {
  // Need to allow mutable encodings for tests
  @override
  List<RTCRtpEncodingParameters> encodings = []; // Modifiable for testing
}

class MockRTCRtpEncodingParameters extends Mock implements RTCRtpEncodingParameters {
  @override
  int? maxBitrate; // Modifiable for testing

  MockRTCRtpEncodingParameters({this.maxBitrate});
}

// Mock StatsReport
class MockStatsReport implements StatsReport {
  @override
  final String id;
  @override
  final String type;
  @override
  final double timestamp;
  @override
  final Map<dynamic, dynamic> values;

  MockStatsReport(this.id, this.type, this.timestamp, this.values);
}

// Helper to create outbound-rtp stats
StatsReport createMockOutboundRtpStats({
  String id = 'outbound-rtp-1',
  double timestamp = 1.0,
  int? packetsSent,
  int? packetsLost,
  double? roundTripTime, // in seconds
  double? jitter, // in seconds
  String? kind, // 'video' or 'audio'
}) {
  final values = <String, dynamic>{};
  if (packetsSent != null) values['packetsSent'] = packetsSent;
  if (packetsLost != null) values['packetsLost'] = packetsLost;
  if (roundTripTime != null) values['roundTripTime'] = roundTripTime;
  if (jitter != null) values['jitter'] = jitter;
  if (kind != null) values['kind'] = kind; // Though 'kind' is usually on track, not stats report directly
  return MockStatsReport(id, 'outbound-rtp', timestamp, values);
}

// Helper to create candidate-pair stats
StatsReport createMockCandidatePairStats({
  String id = 'candidate-pair-1',
  double timestamp = 1.0,
  String state = 'succeeded',
  double? availableOutgoingBitrate, // bps
}) {
  final values = <String, dynamic>{'state': state};
  if (availableOutgoingBitrate != null) {
    values['availableOutgoingBitrate'] = availableOutgoingBitrate;
  }
  return MockStatsReport(id, 'candidate-pair', timestamp, values);
}


void main() {
  late MockRTCPeerConnection mockPeerConnection;
  late CallQualityManager manager;
  late CallQualityManagerSettings defaultSettings;
  late MockRTCRtpSender mockVideoSender;
  late MockMediaStreamTrack mockVideoTrack;
  late MockRTCRtpParameters mockVideoParameters;
  late MockRTCRtpEncodingParameters mockVideoEncoding;

  setUp(() {
    mockPeerConnection = MockRTCPeerConnection();
    mockVideoSender = MockRTCRtpSender();
    mockVideoTrack = MockMediaStreamTrack();
    mockVideoParameters = MockRTCRtpParameters();
    mockVideoEncoding = MockRTCRtpEncodingParameters();

    defaultSettings = CallQualityManagerSettings(); // Use default settings

    // Default track setup
    when(mockVideoTrack.kind).thenReturn('video');
    when(mockVideoTrack.id).thenReturn('videoTrack1');
    when(mockVideoSender.track).thenReturn(mockVideoTrack);
    when(mockVideoSender.senderId).thenReturn('videoSender1');

    mockVideoParameters.encodings = [mockVideoEncoding];
    when(mockVideoSender.getParameters()).thenAnswer((_) async => mockVideoParameters);
    // Provide a default for setParameters, can be overridden in tests
    when(mockVideoSender.setParameters(any)).thenAnswer((_) async => true);

    when(mockPeerConnection.getSenders()).thenAnswer((_) async => [mockVideoSender]);
    // Default getStats to return an empty list, tests will override
    when(mockPeerConnection.getStats(any)).thenAnswer((_) async => []);
  });

  // Timer is used internally by CallQualityManager, tests will typically invoke _monitorCallQuality directly.
  // However, to make the manager itself testable without manually calling private methods,
  // we can pass a Timer mock or use a real timer and control its execution via FakeAsync.
  // For simplicity here, we'll call _monitorCallQuality directly in a test helper.
  Future<void> triggerMonitorCallQuality(CallQualityManager mgr) async {
    // Simulate the timer callback. We pass a dummy timer.
    // In a real test environment with more complex timer interactions, FakeAsync would be better.
    await mgr.testInvokeMonitorCallQuality();
  }

  group('CallQualityManager - Packet Loss Tests', () {
    test('should reduce bitrate on high packet loss', () async {
      mockVideoEncoding.maxBitrate = 1000000; // 1 Mbps
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
        createMockOutboundRtpStats(packetsSent: 100, packetsLost: 15), // 15% loss
      ]);

      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      expect(captured.encodings![0].maxBitrate, equals((1000000 * defaultSettings.packetLossBitrateFactor).toInt()));
    });

    test('should not reduce bitrate if packet loss is below threshold', () async {
      mockVideoEncoding.maxBitrate = 1000000;
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
        createMockOutboundRtpStats(packetsSent: 100, packetsLost: 5), // 5% loss
      ]);
       // No candidate pair stats or good BWE for this test
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => []);


      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      verifyNever(mockVideoSender.setParameters(any));
    });
  });

  group('CallQualityManager - RTT Tests', () {
    test('should reduce bitrate on high RTT', () async {
      mockVideoEncoding.maxBitrate = 1000000;
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
        createMockOutboundRtpStats(roundTripTime: 0.6), // 600ms
      ]);
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => []);


      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      expect(captured.encodings![0].maxBitrate, equals((1000000 * defaultSettings.rttBitrateFactor).toInt()));
    });
  });

  group('CallQualityManager - Jitter Tests', () {
    test('should reduce bitrate on high jitter', () async {
      mockVideoEncoding.maxBitrate = 1000000;
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
        createMockOutboundRtpStats(jitter: 0.04), // 40ms (default threshold 30ms)
      ]);
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => []); // No BWE stats for this test


      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      expect(captured.encodings![0].maxBitrate, equals((1000000 * defaultSettings.jitterBitrateFactor).toInt()));
    });
  });

  group('CallQualityManager - Combined Conditions Tests', () {
    test('should apply combined reduction for packet loss and RTT', () async {
      mockVideoEncoding.maxBitrate = 1000000; // 1 Mbps
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
        createMockOutboundRtpStats(packetsSent: 100, packetsLost: 15, roundTripTime: 0.6), // 15% loss, 600ms RTT
      ]);
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => []);


      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      // Expected: factor = 1.0 * packetLossFactor (0.8) * rttFactor (0.85) = 0.68
      int expectedBitrate = (1000000 * defaultSettings.packetLossBitrateFactor * defaultSettings.rttBitrateFactor).toInt();
      expect(captured.encodings![0].maxBitrate, equals(expectedBitrate));
    });
  });

  group('CallQualityManager - Bandwidth Estimation Tests', () {
    test('should reduce bitrate if BWE is significantly lower', () async {
      mockVideoEncoding.maxBitrate = 1000000; // 1 Mbps
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => [ // BWE stats
        createMockCandidatePairStats(availableOutgoingBitrate: 500000), // BWE is 500kbps
      ]);
      // No quality issue stats for this specific BWE test
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
         createMockOutboundRtpStats(packetsSent: 100, packetsLost: 1) // Good quality
      ]);

      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      // BWE (500k) < currentMax (1M) * bweMinDecreaseFactor (0.8) = 800k. So, BWE is lower.
      // newProposedMaxBitrate = 500k * bweTargetHeadroomFactor (0.9) = 450k
      expect(captured.encodings![0].maxBitrate, equals((500000 * defaultSettings.bweTargetHeadroomFactor).toInt()));
    });

    test('should cautiously increase bitrate if BWE is higher and quality is good', () async {
      mockVideoEncoding.maxBitrate = 500000; // 500 kbps
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => [ // BWE stats
        createMockCandidatePairStats(availableOutgoingBitrate: 1000000), // BWE is 1Mbps
      ]);
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [ // Good quality stats
        createMockOutboundRtpStats(packetsSent: 100, packetsLost: 1, roundTripTime: 0.1, jitter: 0.01),
      ]);

      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      // BWE (1M) > currentMax (500k) * bweMinIncreaseFactor (1.2) = 600k. So, BWE allows increase.
      // Quality is good, so qualityAdjustmentFactor is 1.0.
      // upwardAdjustedBitrate = currentMax (500k) * cautiousIncreaseFactor (1.1) = 550k
      // This is clamped by BWE * headroom = 1M * 0.9 = 900k. So, 550k is chosen.
      int expectedBitrate = (500000 * defaultSettings.cautiousIncreaseFactor).toInt();
      expectedBitrate = expectedBitrate.clamp(0, (1000000 * defaultSettings.bweTargetHeadroomFactor).toInt());
      expect(captured.encodings![0].maxBitrate, equals(expectedBitrate));
    });

     test('should not increase bitrate if BWE is higher but quality is bad', () async {
      mockVideoEncoding.maxBitrate = 500000; // 500 kbps
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => [ // BWE stats
        createMockCandidatePairStats(availableOutgoingBitrate: 1000000), // BWE is 1Mbps
      ]);
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [ // Bad quality stats
        createMockOutboundRtpStats(packetsSent: 100, packetsLost: 15, roundTripTime: 0.1, jitter: 0.01), // 15% packet loss
      ]);

      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      // Bitrate should be reduced due to packet loss, not increased by BWE
      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      int expectedBitrate = (500000 * defaultSettings.packetLossBitrateFactor).toInt();
      expect(captured.encodings![0].maxBitrate, equals(expectedBitrate));
    });

    test('should respect minSensibleBitrateBps when reducing bitrate', () async {
      mockVideoEncoding.maxBitrate = 100000; // 100 kbps
      // Packet loss is very high, causing a large reduction factor
      when(mockPeerConnection.getStats(mockVideoTrack)).thenAnswer((_) async => [
        createMockOutboundRtpStats(packetsSent: 100, packetsLost: 50), // 50% loss
      ]);
      when(mockPeerConnection.getStats(null)).thenAnswer((_) async => []); // No BWE override

      manager = CallQualityManager(mockPeerConnection, defaultSettings);
      await triggerMonitorCallQuality(manager);

      final RtcRtpParameters captured = verify(mockVideoSender.setParameters(captureAny)).captured.single;
      // Reduction would be 100k * 0.8 = 80k. But if minSensible is 50k, it's fine.
      // If reduction was to, say, 30k, it should clamp to 50k.
      // Let's make defaultSettings.packetLossBitrateFactor lead to lower than minSensible
      // (100000 * 0.8 = 80000). This is fine.
      // Let's test if currentMaxBitrate is slightly above minSensible and reduction goes below
      mockVideoEncoding.maxBitrate = 60000; // Slightly above minSensible
      // qualityAdjustmentFactor will be 0.8 (packetLossFactor)
      // 60000 * 0.8 = 48000. This should be clamped to minSensibleBitrateBps (50000)

      // Re-trigger with new setup for this specific sub-case:
      when(mockVideoSender.getParameters()).thenAnswer((_) async {
        // Need to return a parameters object where encoding has the updated maxBitrate
        var params = MockRTCRtpParameters();
        params.encodings = [mockVideoEncoding]; // mockVideoEncoding.maxBitrate is 60000 now
        return params;
      });

      await triggerMonitorCallQuality(manager);

      // This verify is tricky because setParameters might be called multiple times if not careful with mock setup
      // Let's assume the last call is what we care about or structure tests more atomically.
      // For now, we expect it to be called. The argument capture will get the last call.
      final RtcRtpParameters capturedClamped = verify(mockVideoSender.setParameters(captureAny)).captured.last;
      expect(capturedClamped.encodings![0].maxBitrate, equals(defaultSettings.minSensibleBitrateBps));
    });

  });

  // Add a placeholder for testInvokeMonitorCallQuality in CallQualityManager if it's not public
  // For now, assuming we can create a subclass or modify CallQualityManager for testing.
  // If CallQualityManager._monitorCallQuality is private, tests would need to be structured differently,
  // possibly by testing the public `start` and `stop` methods and using `FakeAsync` to control timers.
}

// Extension to allow calling _monitorCallQuality for test purposes
extension TestCallQualityManager on CallQualityManager {
  Future<void> testInvokeMonitorCallQuality() async {
    return _monitorCallQuality(null);
  }
  // Helper to allow tests to hook into the _handleLocalTrackEnded method
  Future<void> testInvokeHandleLocalTrackEnded(MediaStreamTrack endedTrack, RTCRtpSender sender) async {
    return _handleLocalTrackEnded(endedTrack, sender);
  }
   // Helper to directly call _monitorTrack
  void testMonitorTrack(MediaStreamTrack track, RTCRtpSender sender) {
    _monitorTrack(track, sender);
  }
}

// Mock for MediaDevices to control getUserMedia in restart
class MockGlobalMediaDevices extends Mock implements MediaDevices {}

// The following would require CallQualityManager._monitorCallQuality to be made visible for testing (e.g. by not being private)
// or by using a package like `test_api`'s `@visibleForTesting`.
// For this exercise, I'll assume it's callable via the extension above.

// Note: RTCRtpParameters and RTCRtpEncodingParameters from the interface package
// might not have mutable fields. The mockito mocks above allow overriding this.
// If using the real objects, they would need to be constructed carefully.

// Mockito generation command (if using build_runner):
// flutter pub run build_runner build --delete-conflicting-outputs
// (Add @GenerateMocks for the classes to be mocked)

// For this environment, manual mocks are used.

// --- Start of new tests for auto-restart ---
  group('CallQualityManager - Auto Restart Tests', () {
    late MediaStreamTrackNative localVideoTrack; // Use a real one for its stream controller
    late StreamController<void> localVideoTrackEndedController;
    late MockRTCRtpSender mockVideoSenderForRestart;
    late MockGlobalMediaDevices mockNavigatorMediaDevices; // Mock for navigator.mediaDevices
    late MediaDevices originalMediaDevices;


    setUp(() {
      // CQM already has mockPeerConnection, defaultSettings from outer setUp
      mockVideoSenderForRestart = MockRTCRtpSender();
      when(mockVideoSenderForRestart.senderId).thenReturn('videoSenderForRestart');

      localVideoTrackEndedController = StreamController<void>.broadcast();
      // Create a real MediaStreamTrackNative to test its onEnded stream interaction
      localVideoTrack = MediaStreamTrackNative(
        'localVideoTrack1', 'label', 'video', true, 'pc1', {}, true // isLocal = true
      );
      // Override the onEnded stream with our controller for testing
      // This is a bit of a hack. A better way would be to make MediaStreamTrackNative testable
      // or use a TestMediaStreamTrackNative that exposes its controller.
      // For now, we can't directly replace the onEnded stream of an existing object easily.
      // Instead, we will trigger setEnded() on the track, which uses its internal controller.

      when(mockVideoSenderForRestart.track).thenReturn(localVideoTrack);
      when(mockPeerConnection.getSenders()).thenAnswer((_) async => [mockVideoSenderForRestart]);
      when(mockVideoSenderForRestart.replaceTrack(any)).thenAnswer((_) async => true);

      // Mock navigator.mediaDevices for the track's restart() method
      mockNavigatorMediaDevices = MockGlobalMediaDevices();
      originalMediaDevices = navigator.mediaDevices; // Save original
      navigator.mediaDevices = mockNavigatorMediaDevices; // Replace with mock
    });

    tearDown(() {
       navigator.mediaDevices = originalMediaDevices; // Restore original
       localVideoTrackEndedController.close();
    });

    test('attempts to restart track if autoRestart is true and track ends', () async {
      final settings = CallQualityManagerSettings(autoRestartLocallyEndedTracks: true);
      manager = CallQualityManager(mockPeerConnection, settings);

      // Mock the new track that will be returned by restart()
      final newRestartedTrack = MediaStreamTrackNative(
          'restartedVideoTrack', 'label', 'video', true, 'pc1', {}, true);
      when(mockNavigatorMediaDevices.getUserMedia(settings.defaultVideoRestartConstraints!))
          .thenAnswer((_) async => MockMediaStream(videoTracks: [newRestartedTrack]));

      MediaStreamTrack? emittedTrack;
      manager.onTrackRestarted.listen((track) {
        emittedTrack = track;
      });

      // Manually add track to CQM monitoring (simulating what start() does)
      (manager as TestCallQualityManager).testMonitorTrack(localVideoTrack, mockVideoSenderForRestart);

      // Simulate track ending
      localVideoTrack.setEnded(); // This will fire the onEnded stream

      await Future.delayed(Duration.zero); // Allow async operations in _handleLocalTrackEnded to complete

      verify(mockNavigatorMediaDevices.getUserMedia(settings.defaultVideoRestartConstraints!)).called(1);
      verify(mockVideoSenderForRestart.replaceTrack(newRestartedTrack)).called(1);
      expect(emittedTrack, equals(newRestartedTrack));
    });

    test('does NOT attempt to restart track if autoRestart is false', () async {
      final settings = CallQualityManagerSettings(autoRestartLocallyEndedTracks: false);
      manager = CallQualityManager(mockPeerConnection, settings);

      (manager as TestCallQualityManager).testMonitorTrack(localVideoTrack, mockVideoSenderForRestart);
      localVideoTrack.setEnded();
      await Future.delayed(Duration.zero);

      verifyNever(mockNavigatorMediaDevices.getUserMedia(any));
      verifyNever(mockVideoSenderForRestart.replaceTrack(any));
    });

    test('does NOT attempt to restart if no default constraints for track kind', () async {
      final settings = CallQualityManagerSettings(
        autoRestartLocallyEndedTracks: true,
        defaultVideoRestartConstraints: null // No constraints for video
      );
      manager = CallQualityManager(mockPeerConnection, settings);

      (manager as TestCallQualityManager).testMonitorTrack(localVideoTrack, mockVideoSenderForRestart);
      localVideoTrack.setEnded();
      await Future.delayed(Duration.zero);

      verifyNever(mockNavigatorMediaDevices.getUserMedia(any));
      verifyNever(mockVideoSenderForRestart.replaceTrack(any));
    });

     test('does NOT call replaceTrack if track restart() returns null', () async {
      final settings = CallQualityManagerSettings(autoRestartLocallyEndedTracks: true);
      manager = CallQualityManager(mockPeerConnection, settings);

      // Simulate restart() failing by having getUserMedia return no matching track
      when(mockNavigatorMediaDevices.getUserMedia(settings.defaultVideoRestartConstraints!))
          .thenAnswer((_) async => MockMediaStream(audioTracks: [])); // No video track

      (manager as TestCallQualityManager).testMonitorTrack(localVideoTrack, mockVideoSenderForRestart);
      localVideoTrack.setEnded();
      await Future.delayed(Duration.zero);

      verify(mockNavigatorMediaDevices.getUserMedia(settings.defaultVideoRestartConstraints!)).called(1);
      verifyNever(mockVideoSenderForRestart.replaceTrack(any));
    });

  });
  // --- End of new tests ---
});

// Extension to allow calling _monitorCallQuality for test purposes
// (and other private/protected methods for more granular testing if needed)
extension TestCallQualityManager on CallQualityManager {
  Future<void> testInvokeMonitorCallQuality() async {
    // This is a way to call the private method.
    // In a real scenario, you might not do this, or use a different testing strategy.
    // For this exercise, it simplifies directly testing the core logic.
    // Reflectable or making it protected could also be options.
    // Here, we assume it's accessible or made accessible for tests.
    // This direct call bypasses the Timer.
    return _monitorCallQuality(null); // Pass null as Timer is not used by current impl of _monitorCallQuality
  }
}

// The following would require CallQualityManager._monitorCallQuality to be made visible for testing (e.g. by not being private)
// or by using a package like `test_api`'s `@visibleForTesting`.
// For this exercise, I'll assume it's callable via the extension above.

// Note: RTCRtpParameters and RTCRtpEncodingParameters from the interface package
// might not have mutable fields. The mockito mocks above allow overriding this.
// If using the real objects, they would need to be constructed carefully.

// Mockito generation command (if using build_runner):
// flutter pub run build_runner build --delete-conflicting-outputs
// (Add @GenerateMocks for the classes to be mocked)

// For this environment, manual mocks are used.
// Further tests: combined conditions, BWE logic, minSensibleBitrate, custom settings.
