# webrtc_example

Demonstrates how to use the webrtc plugin.

## Getting Started

Make sure your flutter is using the `dev` channel.

```bash
flutter channel dev
./scripts/project_tools.sh create
```

Android/iOS

```bash
flutter run
```

macOS

```bash
flutter run -d macos
```

Web

```bash
dart compile js ../web/e2ee.worker.dart -o web/e2ee.worker.dart.js
flutter run -d web
```

Windows

```bash
flutter channel master
flutter create --platforms windows .
flutter run -d windows
```

## Example: Setting Degradation Preference

You can configure how WebRTC adapts to poor network conditions by setting `degradationPreference` in the `RTCConfiguration`. This helps balance video frame rate and resolution.

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

// When creating or setting peer connection configuration:
RTCConfiguration rtcConfig = RTCConfiguration(
  iceServers: [
    RTCIceServer(urls: ['stun:stun.l.google.com:19302'])
  ],
  // Other settings like sdpSemantics can be added here
  degradationPreference: RTCDegradationPreference.maintainFramerate,
);

// Convert to map to pass to createPeerConnection or setConfiguration
// Map<String, dynamic> configurationMap = rtcConfig.toMap();
// RTCPeerConnection pc = await createPeerConnection(configurationMap);
// await pc.setConfiguration(configurationMap);
```

For more details on `degradationPreference` and other `RTCConfiguration` options, please see the main [README.md](../../README.md#configuring-rtcconfiguration) in the plugin root.

## More Advanced Configuration & Features

The `flutter_webrtc` plugin offers many advanced configuration options and features. Below are a few examples. For comprehensive documentation, always refer to the main [plugin README.md](../../README.md).

### Customizing Call Quality Management

The `CallQualityManager` can be tuned with `CallQualityManagerSettings`.

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
// If CallQualityManager is in src, direct import might be needed if not exported by main package file:
// import 'package:flutter_webrtc/src/call_quality_manager.dart';

// ... assuming 'pc' is your RTCPeerConnection instance
final customCQMSettings = CallQualityManagerSettings(
  packetLossThresholdPercent: 15.0,
  rttThresholdSeconds: 0.6,
  autoRestartLocallyEndedTracks: true,
  defaultVideoRestartConstraints: {'video': {'width': 640, 'height': 480}},
);
final callManager = CallQualityManager(pc, customCQMSettings);
callManager.start();

callManager.onTrackRestarted.listen((MediaStreamTrack newTrack) {
  print('A local track was automatically restarted: ${newTrack.id}');
});

// Remember to call callManager.dispose() when done.
```
See the main [README.md](../../README.md#call-quality-management-callqualitymanager) for more details on all settings.

### Handling Media Device Access Errors

When using `navigator.mediaDevices.getUserMedia()`, you can catch specific errors:

```dart
try {
  final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
  // ... use stream
} on PermissionDeniedError catch (e) {
  print('Error: Permission denied for media devices - ${e.message}');
  // Inform the user, guide them to settings, etc.
} on NotFoundError catch (e) {
  print('Error: No media devices found - ${e.message}');
  // Inform the user that no camera/mic was found.
} catch (e) {
  print('A generic error occurred: $e');
}
```
Details in the main [README.md](../../README.md#specific-exceptions-for-media-device-access).

### Track Lifecycle Events (`onEnded`)

Monitor when a track ends (e.g., remote user stops sending, or local track is stopped/crashed):

```dart
// Assuming 'videoTrack' is a MediaStreamTrack instance
videoTrack.onEnded.listen((_) {
  print('Track ${videoTrack.id} has ended. Current readyState: ${videoTrack.readyState}');
  // Update UI, attempt restart for local tracks, etc.
});

// You can also check track.readyState ('live' or 'ended')
```
Learn more in the main [README.md](../../README.md#mediastreamtrack-lifecycle).

### Other Notable Features (See main README.md for details):
- **Codec Profile & Preferred Codecs**: Control codec negotiation (see "Advanced Codec Control").
- **ICE Candidate Filtering**: Filter ICE candidates by type or protocol (see `allowedIceCandidateTypes`, `allowedIceProtocols` in "Configuring RTCConfiguration").
- **ICE Gathering Timeout**: Set a timeout for ICE gathering (see `iceGatheringTimeoutSeconds` in "Configuring RTCConfiguration").
- **MediaStream Active State**: Use `MediaStream.active` and `MediaStream.onActiveStateChanged` (see "MediaStream Lifecycle").
