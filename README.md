# Flutter-WebRTC

[![Financial Contributors on Open Collective](https://opencollective.com/flutter-webrtc/all/badge.svg?label=financial+contributors)](https://opencollective.com/flutter-webrtc) [![pub package](https://img.shields.io/pub/v/flutter_webrtc.svg)](https://pub.dartlang.org/packages/flutter_webrtc) [![Gitter](https://badges.gitter.im/flutter-webrtc/Lobby.svg)](https://gitter.im/flutter-webrtc/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![slack](https://img.shields.io/badge/join-us%20on%20slack-gray.svg?longCache=true&logo=slack&colorB=brightgreen)](https://join.slack.com/t/flutterwebrtc/shared_invite/zt-q83o7y1s-FExGLWEvtkPKM8ku_F8cEQ)

WebRTC plugin for Flutter Mobile/Desktop/Web

</br>
<p align="center">
<strong>Sponsored with 💖 &nbsp by</strong><br />
<a href="https://getstream.io/chat/flutter/tutorial/?utm_source=https://github.com/flutter-webrtc/flutter-webrtc&utm_medium=github&utm_content=developer&utm_term=flutter" target="_blank">
<img src="assets/sponsors/stream-logo.png" alt="Stream Chat" style="margin: 8px; width: 350px" />
</a>
<br />
Enterprise Grade APIs for Feeds, Chat, & Video. <a href="https://getstream.io/video/docs/flutter/?utm_source=https://github.com/flutter-webrtc/flutter-webrtc&utm_medium=sponsorship&utm_content=&utm_campaign=webrtcFlutterRepo_July2023_video_klmh22" target="_blank">Try the Flutter Video tutorial</a> 💬
</p>

</br>
<p align="center">
<a href="https://livekit.io/?utm_source=opencollective&utm_medium=github&utm_campaign=flutter-webrtc" target="_blank">
<img src="https://avatars.githubusercontent.com/u/69438833?s=200&v=4" alt="LiveKit" style="margin: 8px; width: 100px" />
</a>
<br />
   <a href="https://livekit.io/?utm_source=opencollective&utm_medium=github&utm_campaign=flutter-webrtc" target="_blank">LiveKit</a> - Open source WebRTC and realtime AI infrastructure
<p>

## Functionality

| Feature | Android | iOS | [Web](https://flutter.dev/web) | macOS | Windows | Linux | [Embedded](https://github.com/sony/flutter-elinux) | [Fuchsia](https://fuchsia.dev/) |
| :-------------: | :-------------:| :-----: | :-----: | :-----: | :-----: | :-----: | :-----: | :-----: |
| Audio/Video | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Data Channel | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Screen Capture | :heavy_check_mark: | [:heavy_check_mark:(*)](https://github.com/flutter-webrtc/flutter-webrtc/wiki/iOS-Screen-Sharing) | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Unified-Plan | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Simulcast | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| MediaRecorder | :warning: | :warning: | :heavy_check_mark: | | | | | |
| End to End Encryption | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | |
| Insertable Streams | | | | | | | | |

## Configuring RTCConfiguration

The `RTCConfiguration` object allows you to specify various parameters for how a peer connection should be established and managed. One key setting for adapting to network conditions is `degradationPreference`.

### `degradationPreference`

This setting, of type `RTCDegradationPreference`, hints to the WebRTC engine how to handle situations where network quality degrades and available bandwidth is limited. It helps balance between maintaining frame rate and maintaining resolution for video streams.

The possible values for `RTCDegradationPreference` are:

*   **`RTCDegradationPreference.disabled`**:
    *   Video quality will not be intentionally degraded. The WebRTC engine may still adapt, but it won't prioritize frame rate or resolution based on this hint. This can lead to choppy video if bandwidth is insufficient.
*   **`RTCDegradationPreference.maintainFramerate`**:
    *   Prioritizes keeping the frame rate smooth. If bandwidth is limited, the resolution will be reduced to maintain the frame rate. Use this if motion smoothness is critical.
*   **`RTCDegradationPreference.maintainResolution`**:
    *   Prioritizes keeping the video resolution clear. If bandwidth is limited, the frame rate will be reduced to maintain resolution. Use this if image clarity is more important than smooth motion.
*   **`RTCDegradationPreference.balanced`** (Default in native WebRTC, though default might vary by platform if not explicitly set):
    *   Attempts to strike a balance between frame rate and resolution. The WebRTC engine will make trade-offs based on its internal heuristics.

**Example Usage:**

To set the `degradationPreference`, include it in your `RTCConfiguration` map when creating a peer connection:

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

// ...

Map<String, dynamic> configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
  ],
  'sdpSemantics': 'unified-plan', // Or 'plan-b'
  // Add degradationPreference
  'degradationPreference': RTCDegradationPreference.maintainFramerate.toString().split('.').last
};

// When creating a peer connection:
// RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);

// Or if you are using the RTCConfiguration object directly (recommended):
RTCConfiguration rtcConfig = RTCConfiguration(
  iceServers: [RTCIceServer(urls: ['stun:stun.l.google.com:19302'])],
  sdpSemantics: SDPSemantics.UnifiedPlan, // Assuming an enum SDPSemantics exists or use string
  degradationPreference: RTCDegradationPreference.maintainFramerate,
);

// The toMap() method of RTCConfiguration will handle the correct string conversion for native platforms.
// Map<String, dynamic> configurationMap = rtcConfig.toMap();
// RTCPeerConnection pc = await createPeerConnection(configurationMap);
```

Setting `degradationPreference` can be particularly useful in mobile applications or any scenario where network conditions can vary significantly, helping to provide a better user experience during video calls.

### Hardware Acceleration Hint

*   **`hardwareAcceleration`**: `bool?`
    *   This field in `RTCConfiguration` serves as a hint for enabling or disabling hardware-accelerated video encoding/decoding.
    *   **Default Behavior**: WebRTC typically attempts to use hardware acceleration by default where available. Setting this to `true` (default if null on native) aligns with that.
    *   **Disabling**: Setting to `false` suggests a preference for software codecs.
    *   **Note**: Actual enforcement depends on platform capabilities and the underlying WebRTC implementation. The native layer in this plugin attempts to honor this by selecting software-only video factories if set to `false` *at the time the PeerConnectionFactory is initialized*. Since the factory is often initialized once globally, this hint is typically a global preference for the application's lifetime or until the factory is re-initialized. Changing it in `RTCConfiguration` for an already created factory might not change the active encoder/decoder factories for that specific peer connection.

### ICE Candidate Filtering

*   **`allowedIceCandidateTypes`: `List<RTCIceCandidateType>?`**
    *   Allows you to specify which types of ICE candidates should be collected and used. If set, candidates not matching these types will be filtered out at the native level before being sent to the Dart application.
    *   `RTCIceCandidateType` enum values: `host`, `srflx` (Server Reflexive), `prflx` (Peer Reflexive), `relay` (TURN relay).
    *   Example: `allowedIceCandidateTypes: [RTCIceCandidateType.host, RTCIceCandidateType.relay]`
*   **`allowedIceProtocols`: `List<RTCIceProtocol>?`**
    *   Allows you to filter ICE candidates by their transport protocol.
    *   `RTCIceProtocol` enum values: `udp`, `tcp`.
    *   Example: `allowedIceProtocols: [RTCIceProtocol.udp]`

### ICE Gathering Timeout

*   **`iceGatheringTimeoutSeconds`: `int?`**
    *   Specifies a timeout in seconds for the ICE gathering process.
    *   If ICE gathering does not complete (i.e., state does not become `complete`) within this duration, the gathering process is considered timed out.
    *   The plugin will then send a null ICE candidate to Dart, signaling the end of candidates, and will ignore further candidates from that gathering cycle.
    *   Set to `0` or `null` to disable the timeout (relying on WebRTC's default behavior).
    *   Example: `iceGatheringTimeoutSeconds: 10` (10 seconds)

```dart
// Example demonstrating new RTCConfiguration fields
RTCConfiguration rtcConfig = RTCConfiguration(
  iceServers: [RTCIceServer(urls: ['stun:stun.l.google.com:19302'])],
  sdpSemantics: SDPSemantics.UnifiedPlan, // Or your desired semantics
  degradationPreference: RTCDegradationPreference.balanced,
  hardwareAcceleration: true, // Hint for hardware acceleration
  allowedIceCandidateTypes: [RTCIceCandidateType.host, RTCIceCandidateType.srflx, RTCIceCandidateType.relay],
  allowedIceProtocols: [RTCIceProtocol.udp],
  iceGatheringTimeoutSeconds: 15,
);

// Map<String, dynamic> configurationMap = rtcConfig.toMap();
// RTCPeerConnection pc = await createPeerConnection(configurationMap);
```

## Advanced Codec Control

This plugin provides mechanisms to influence codec selection and parameters.

### Codec Profile Specification

*   **`RTCRtpCodecCapability.profile`: `String?`**
    *   When defining preferred codecs for an `RTCRtpTransceiver` (see below), you can specify a `profile` string within an `RTCRtpCodecCapability` object.
    *   This `profile` string is appended to the `sdpfmtpLine` attribute of the native `RTCRtpCodecCapability` when passed to the underlying WebRTC engine (e.g., `a=fmtp:...;profile=your_profile_string`). The exact interpretation and validity of the profile string are codec-specific (e.g., for H.264, this might relate to `profile-level-id`).
*   **`RTCRtpCodecParameters.profile`: `String?`**
    *   When RTP parameters are retrieved (e.g., from `RTCRtpSender.getParameters()` or `RTCRtpReceiver.getParameters()`), the `profile` field on `RTCRtpCodecParameters` will be populated if a "profile" key (or a recognized key like "profile-level-id") was found in the native codec's specific parameters map.
    *   When setting RTP parameters via `RTCRtpSender.setParameters()`, you can include a `codecs` list in the parameters map. Each codec map in this list can have a `profile` string, which will be stored in the native codec's parameter map under the key "profile".

### Preferred Codecs for Transceivers

*   **`RTCRtpTransceiverInit.preferredCodecs`: `List<RTCRtpCodecCapability>?`**
    *   When adding a new transceiver using `pc.addTransceiver(trackOrKind, init: rtpTransceiverInit)`, you can provide a list of `RTCRtpCodecCapability` objects in `rtpTransceiverInit.preferredCodecs`.
    *   This list tells the WebRTC engine your preferred order and configuration for codecs to be negotiated for that transceiver. The actual negotiated codec will depend on the capabilities of both peers.
    *   Each `RTCRtpCodecCapability` in the list can specify `mimeType`, `clockRate`, `channels`, `sdpFmtpLine`, and the new `profile` field.

**Example of setting preferred codecs:**

```dart
// Assuming 'pc' is your RTCPeerConnection instance
// and 'videoTrack' is a MediaStreamTrack

var videoCapabilities = await RTCRtpSender.getCapabilities('video'); // Or RTCRtpReceiver.getCapabilities('video')
// Example: Prefer H264 Constrained Baseline, then VP8
List<RTCRtpCodecCapability> preferredVideoCodecs = [];

// Find H264 capability and specify a profile (example profile-level-id for Constrained Baseline)
var h264Cap = videoCapabilities.codecs?.firstWhere(
  (c) => c.mimeType.toLowerCase() == 'video/h264',
  orElse: () => null, // Handle case where H264 might not be supported
);
if (h264Cap != null) {
  // Modify sdpFmtpLine or use profile if your parsing logic handles it.
  // For H264, profile-level-id is standard.
  // This example uses the custom 'profile' field which gets appended to sdpFmtpLine in native.
  h264Cap.profile = '42e01f'; // Example profile-level-id for Constrained Baseline
  // Alternatively, manipulate sdpFmtpLine directly if needed:
  // h264Cap.sdpFmtpLine = 'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f';
  preferredVideoCodecs.add(h264Cap);
}

// Find VP8 capability
var vp8Cap = videoCapabilities.codecs?.firstWhere(
  (c) => c.mimeType.toLowerCase() == 'video/vp8',
  orElse: () => null,
);
if (vp8Cap != null) {
  preferredVideoCodecs.add(vp8Cap);
}

if (preferredVideoCodecs.isNotEmpty) {
  await pc.addTransceiver(
    track: videoTrack, // Or kind: RTCRtpMediaType.Video
    init: RTCRtpTransceiverInit(
      direction: TransceiverDirection.SendRecv,
      preferredCodecs: preferredVideoCodecs,
    ),
  );
}
```

## Track and Stream Lifecycle, Recovery, and Error Handling

Understanding the state and lifecycle of media tracks and streams is crucial for building robust applications.

### MediaStreamTrack Lifecycle

*   **`MediaStreamTrack.readyState`: `String`**
    *   Indicates the current state of the track. Can be `'live'` or `'ended'`.
*   **`MediaStreamTrack.onEnded`: `Stream<void>`**
    *   A stream that fires an event when the track transitions to the `'ended'` state. This can happen if `stop()` is called, if a remote track is removed by the peer, or potentially if a local device is disconnected or its permissions are revoked (platform-dependent for automatic detection).
*   **`MediaStreamTrack.stop()`: `Future<void>`**
    *   Stops the track, releasing its underlying native resources. The track's `readyState` becomes `'ended'`, and the `onEnded` event is fired.
*   **`MediaStreamTrack.restart(Map<String, dynamic> mediaConstraints)`: `Future<MediaStreamTrack?>`**
    *   This method is available on local tracks (`MediaStreamTrackNative.isLocal == true`).
    *   It first stops the current track (firing `onEnded`).
    *   Then, it attempts to re-acquire a new track of the same kind using the provided `mediaConstraints` via `navigator.mediaDevices.getUserMedia()`.
    *   If successful, it returns a *new* `MediaStreamTrack` instance. The original track instance remains 'ended'.
    *   The application is responsible for updating any `RTCRtpSender` to use this new track via `sender.replaceTrack(newTrack)`.
    *   Returns `null` if re-acquisition fails. Throws `MediaDeviceAcquireError` or its subtypes if `getUserMedia` fails with a known error.

### MediaStream Lifecycle

*   **`MediaStream.active`: `bool`**
    *   A getter that returns `true` if the stream has at least one track with `readyState == 'live'`. Returns `false` if all tracks are 'ended' or if the stream has no tracks.
*   **`MediaStream.onActiveStateChanged`: `Stream<bool>`**
    *   A stream that fires `true` when the stream transitions from inactive to active, and `false` when it transitions from active to inactive. This is determined by the `readyState` of its constituent tracks.

### Specific Exceptions for Media Device Access

When using `navigator.mediaDevices.getUserMedia()` or `navigator.mediaDevices.getDisplayMedia()`, more specific exceptions can be caught:

*   **`PermissionDeniedError`**: Thrown if the user denies permission for camera/microphone access, or if the OS/browser policies prevent access.
*   **`NotFoundError`**: Thrown if no media tracks of the requested kind are found (e.g., no camera available).
*   **`MediaDeviceAcquireError`**: A more generic error for other issues encountered during device acquisition (e.g., hardware errors, constraints that cannot be satisfied).

**Example: Handling Permission Error**
```dart
try {
  final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
  // ... use the stream
} on PermissionDeniedError catch (e) {
  print('Permission denied: ${e.message}');
  // Show UI to user explaining the need for permissions
} on NotFoundError catch (e) {
  print('Device not found: ${e.message}');
  // Handle missing devices
} catch (e) {
  print('Error acquiring media: $e');
}
```

## Call Quality Management (`CallQualityManager`)

The `CallQualityManager` is a utility class (found in `package:flutter_webrtc/src/call_quality_manager.dart`) designed to proactively monitor and adapt call quality based on network conditions.

### Enhanced Adaptive Bitrate Algorithm
The manager's core logic (`_monitorCallQuality`) periodically performs the following:
1.  **Bandwidth Estimation**: It fetches `availableOutgoingBitrate` from active ICE candidate pair statistics to estimate available send bandwidth.
2.  **Per-Sender Stats Analysis**: For each video `RTCRtpSender`:
    *   It analyzes WebRTC statistics (`outbound-rtp`) for packet loss, round-trip time (RTT), and jitter.
3.  **Bitrate Adjustment**:
    *   **Downward**: If `availableOutgoingBitrate` is significantly lower than the current video sender's `maxBitrate`, the `maxBitrate` is reduced to target a percentage (e.g., 90%) of the estimated available bandwidth.
    *   If high packet loss, excessive RTT, or high jitter are detected, the `maxBitrate` is further reduced by configurable factors. These reductions are multiplicative if multiple issues occur.
    *   The bitrate will not be reduced below a configurable `minSensibleBitrateBps`.
    *   **Upward (Cautious)**: If network quality metrics (packet loss, RTT, jitter) are good, and `availableOutgoingBitrate` is significantly higher than the current `maxBitrate`, the `maxBitrate` may be cautiously increased (e.g., by 10%), but capped by a percentage of the `availableOutgoingBitrate`.

### Configuration (`CallQualityManagerSettings`)
The behavior of `CallQualityManager` is controlled by `CallQualityManagerSettings`. You can pass an instance of this class to the `CallQualityManager` constructor.

Key settings include:
*   `packetLossThresholdPercent`: e.g., `10.0` (10%)
*   `rttThresholdSeconds`: e.g., `0.5` (500ms)
*   `jitterThresholdSeconds`: e.g., `0.03` (30ms)
*   `bweMinDecreaseFactor`, `bweMinIncreaseFactor`, `bweTargetHeadroomFactor`: Control sensitivity to bandwidth estimation.
*   `packetLossBitrateFactor`, `rttBitrateFactor`, `jitterBitrateFactor`: Multiplicative factors for bitrate reduction (e.g., `0.8` for a 20% reduction).
*   `cautiousIncreaseFactor`: Factor for increasing bitrate (e.g., `1.1` for a 10% increase).
*   `minSensibleBitrateBps`: Minimum bitrate to target (e.g., `50000` for 50kbps).
*   `autoRestartLocallyEndedTracks`: `bool` (default `true`), enables the auto-restart policy.
*   `defaultAudioRestartConstraints`, `defaultVideoRestartConstraints`: Default constraints used by the auto-restart policy if a local track ends.

**Example: Customizing CallQualityManager**
```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
// Make sure to import CallQualityManager and CallQualityManagerSettings,
// typically from: package:flutter_webrtc/src/call_quality_manager.dart (if not re-exported)

// ... Assuming 'peerConnection' is your RTCPeerConnection instance

final customSettings = CallQualityManagerSettings(
  packetLossThresholdPercent: 15.0, // Be more tolerant to packet loss
  rttThresholdSeconds: 0.7,        // Be more tolerant to RTT
  minSensibleBitrateBps: 75000,    // Set a higher minimum bitrate
  autoRestartLocallyEndedTracks: true,
  defaultVideoRestartConstraints: {'video': {'width': 640, 'height': 480}} // Custom restart constraints
);

final callQualityManager = CallQualityManager(peerConnection, customSettings);
callQualityManager.start(); // Default period is 5 seconds

// Listen for track restart events
callQualityManager.onTrackRestarted.listen((MediaStreamTrack newTrack) {
  print('CallQualityManager automatically restarted track: ${newTrack.id}, kind: ${newTrack.kind}');
  // You might want to update UI or other application logic here.
});

// Don't forget to dispose the manager when the call ends
// callQualityManager.dispose();
```

### Auto-Restart Policy for Local Tracks
*   If `autoRestartLocallyEndedTracks` is true in settings, `CallQualityManager` will monitor local tracks associated with active `RTCRtpSender`s.
*   If such a track's `onEnded` event fires (signaling it has stopped, possibly unexpectedly), the manager will:
    1.  Attempt to call `track.restart()` using the `defaultAudioRestartConstraints` or `defaultVideoRestartConstraints` from its settings.
    2.  If `restart()` successfully returns a `newTrack`, the manager will call `sender.replaceTrack(newTrack)` to replace the ended track with the new one on the corresponding `RTCRtpSender`.
    3.  The `CallQualityManager.onTrackRestarted` stream will emit the `newTrack`.

This policy helps in automatically recovering from situations where a local media source might be temporarily lost and then re-acquired.

Additional platform/OS support from the other community

- flutter-tizen: <https://github.com/flutter-tizen/plugins/tree/master/packages/flutter_webrtc>
- flutter-elinux(WIP): <https://github.com/sony/flutter-elinux-plugins/issues/7>

Add `flutter_webrtc` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### iOS

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) Camera Usage!</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) Microphone Usage!</string>
```

This entry allows your app to access camera and microphone.

### Note for iOS

The WebRTC.xframework compiled after the m104 release no longer supports iOS arm devices, so need to add the `config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'` to your ios/Podfile in your project

ios/Podfile

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
     target.build_configurations.each do |config|
      # Workaround for https://github.com/flutter/flutter/issues/64502
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES' # <= this line
     end
  end
end
```

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

If you need to use a Bluetooth device, please add:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
```

The Flutter project template adds it, so it may already be there.

Also you will need to set your build settings to Java 8, because official WebRTC jar now uses static methods in `EglBase` interface. Just add this to your app level `build.gradle`:

```groovy
android {
    //...
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

If necessary, in the same `build.gradle` you will need to increase `minSdkVersion` of `defaultConfig` up to `23` (currently default Flutter generator set it to `16`).

### Important reminder

When you compile the release apk, you need to add the following operations,
[Setup Proguard Rules](https://github.com/flutter-webrtc/flutter-webrtc/blob/main/android/proguard-rules.pro)

## Contributing

The project is inseparable from the contributors of the community.

- [CloudWebRTC](https://github.com/cloudwebrtc) - Original Author
- [RainwayApp](https://github.com/rainwayapp) - Sponsor
- [亢少军](https://github.com/kangshaojun) - Sponsor
- [ION](https://github.com/pion/ion) - Sponsor
- [reSipWebRTC](https://github.com/reSipWebRTC) - Sponsor
- [沃德米科技](https://github.com/woodemi)-[36记手写板](https://www.36notes.com) - Sponsor
- [阿斯特网络科技有限公司](https://www.astgo.net/) - Sponsor

### Example

For more examples, please refer to [flutter-webrtc-demo](https://github.com/cloudwebrtc/flutter-webrtc-demo/).

## Contributors

### Code Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/cloudwebrtc/flutter-webrtc/graphs/contributors"><img src="https://opencollective.com/flutter-webrtc/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Become a financial contributor and help us sustain our community. [[Contribute](https://opencollective.com/flutter-webrtc/contribute)]

#### Individuals

<a href="https://opencollective.com/flutter-webrtc"><img src="https://opencollective.com/flutter-webrtc/individuals.svg?width=890"></a>

#### Organizations

Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/flutter-webrtc/contribute)]

<a href="https://opencollective.com/flutter-webrtc/organization/0/website"><img src="https://opencollective.com/flutter-webrtc/organization/0/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/1/website"><img src="https://opencollective.com/flutter-webrtc/organization/1/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/2/website"><img src="https://opencollective.com/flutter-webrtc/organization/2/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/3/website"><img src="https://opencollective.com/flutter-webrtc/organization/3/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/4/website"><img src="https://opencollective.com/flutter-webrtc/organization/4/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/5/website"><img src="https://opencollective.com/flutter-webrtc/organization/5/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/6/website"><img src="https://opencollective.com/flutter-webrtc/organization/6/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/7/website"><img src="https://opencollective.com/flutter-webrtc/organization/7/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/8/website"><img src="https://opencollective.com/flutter-webrtc/organization/8/avatar.svg"></a>
<a href="https://opencollective.com/flutter-webrtc/organization/9/website"><img src="https://opencollective.com/flutter-webrtc/organization/9/avatar.svg"></a>
