
# Changelog

[1.0.0] - 2025-07-25

* Bump version to 1.0.0
* [Native] feat: Upgrade libwebrtc to m137. (#1877).
* [Doc] fix: typo in package description (#1895)
* [Android] fix: Video recording crashing and freezing on Android 14 Devices (#1886)
* [Android] fix: Add audio recording for Android Platform (#1884)
* [Dart] fix: Removed outdated code to avoid UI not being displayed in Windows release mode (#1890)
* [Apple] fix: Fix compile warnings (#1887)
* [Apple] feat: Update to m137 with audio engine (#1875)
* [Android] fix: Ensure both video and audio tracks are added before starting the muxer (#1879)

[0.14.2] - 2025-07-01

* [Windows/Linux] feat: Add audio processing and sink API for cpp. (#1867)
* [Linux] fix: Fixed audio device selection error for Linux. (#1864)
* [Android] fix: Fix screen capture orientation for landscape-native devices (#1854)

[0.14.1] - 2025-05-22

* [Android] fix: Recording bug (#1839)
* [Android] fix: calls in terminated mode by disabling orientation manager (#1840)
* [Android] fix: Wait for audio and video thread to fully stop to avoid corrupted recordings (#1836)

[0.14.0] - 2025-05-06

* [iOS/Android]feat: Media Recorder implementation Android and iOS (#1810)
* [Wndows] fix: Pickup registrar for plugin by plugin registrar manager (#1752)
* [Linux] fix: add task runner for linux. (#1821)
* [iOS/macOS] fix: Fix deadlock when creating a frame cryptor on iOS/macOS.

[0.13.1+hotfix.1] - 2025-04-07

* [Android] fix: Fix `clearAndroidCommunicationDevice` call blocking.

[0.13.1] - 2025-04-03

* [Android] fix: remove setPreferredInputDevice when getUserAduio. (#1808)
* [Web] fix: race condition in RTCVideoRenderer for Web (#1805)
* [Android] fix: Migrate from onSurfaceDestroyed to onSurfaceCleanup for SurfaceProducer.Callback. (#1806)

[0.13.0] - 2025-03-24

* [All] feat: add getBufferedAmount for DataChannel. (#1796)
* [Windows] fix: fixed non-platform thread call error. (#1795)

[0.12.12+hotfix.1] - 2025-03-12

* [Android] fix: fixed video not rendered after resume from background.

[0.12.12] - 2025-03-09

* [Android] feat: Migrate to the new Surface API. (#1726)
* [Chore] chore: fix sponsors logo and links.

[0.12.11] - 2025-02-23

* [web] bump version for dart_webrtc.
* [web] fix: compile error for web with --wasm.

[0.12.10] - 2025-02-18

* [web] bump version for dart_webrtc.
* [web] fix: compile error for web with --wasm.

[0.12.9] - 2025-02-13

* [iOS] feat: Add option to start capture without broadcast picker (#1764)

[0.12.8] - 2025-02-07

* [Dart] feat: expose rtc video value (#1754)
* [Dart] chore: bump webrtc-interface to 1.2.1.
  
[0.12.7] - 2025-01-24

* [iOS] More robustness for video renderer. (#1751)

[0.12.6] - 2025-01-20

* [iOS] fix In-app screen recording.
* [Android] fix: avoid crashes when surfaceTextureHelper is null. (#1743)

[0.12.5+hotfix.2] - 2024-12-25

* [iOS] fix: Audio route issue for iOS.

[0.12.5+hotfix.1] - 2024-12-25

* [iOS/macOS] fix: Pass MediaConstraints for getUserAudio.

[0.12.5] - 2024-12-23

* [iOS/Android] Fixed buf for screen capture.
* [Android] Fixed first frame flickering.

[0.12.4] - 2024-12-16

* [iOS/Android] add FocusMode/ExposureMode settings for mobile. (#1435)
* [Dart] fix compiler errors.
* [eLinux] add $ORIGIN to rpath in elinux (#1720).

[0.12.3] - 2024-11-29

* [iOS/Android/macOS] feat: Expose AV Processing and Sink native APIs.

[0.12.2] - 2024-11-26

* [Dart] fix: race condition during video renderer initialization. (#1692)
* [Darwin] fix: Add mutex lock to avoid pixelbuffer access contention.  (#1694)

[0.12.1+hotfix.1] - 2024-10-25

* [iOS] fix: fix switch camera broken on iOS.

* [web] fix: add stub WebRTC.initialize for web.
* [Docs] Fixing proguard rules link (#1686)
* [iOS/Android] feat: support unprocessed audio (#825)
* [eLinux] feat: add support for eLinux (#1338)

[0.12.0+hotfix.1] - 2024-10-18

* [macOS] fix compilation error for macOS.

[0.12.0] - 2024-10-16

* [iOS/macOS] Fix memory leak for iOS/macOS.
* [iOS] Support MultiCam Session for iOS.

[0.11.7] - 2024-09-04

* [Web] Bump dart_webrtc to 1.4.9.
* [Web] Bump web version to 1.0.0.

[0.11.6+hotfix.1] - 2024-08-07

* [iOS] Fixed PlatformView not rendering after resuming from background.

[0.11.6] - 2024-08-02

* [Web] change VideoElement to HTMLVideoElement.
* [iOS] added shared singleton for FlutterWebRTCPlugin (#1634)
* [iOS] Using av samplebuffer for PlatformView (#1635)

[0.11.5] - 2024-07-23

* [Android] Report actual sizes for camera media stream track (#1636).

[0.11.4] - 2024-07-19

* [Android] fix issue for camera switching.

[0.11.3] - 2024-07-12

* Bump version for libwebrtc.

[0.11.2] - 2024-07-09

* [Windows] fix crash for windows.
* [Darwin] bump WebRTC version for darwin.

[0.11.1] - 2024-06-17

* [macOS] Downgrade macOS system dependencies to 10.14.

[0.11.0] - 2024-06-17

* [Native] upgrade libwebrtc to m125.6422.

[0.10.8] - 2024-06-05

* [iOS] fix(platform_view): fit cover works wrong (#1593)
* [iOS/macOS] fix: Fix the issue that the video is not displayed when using 'video': true (#1592)
* [Web] bump dart_webrtc to 1.4.6.

[0.10.7] - 2024-05-30

* [iOS] feat: add PlatformView Renderer for iOS. (#1569)
* [iOS] fix: audio session control for iOS. (#1590)

[0.10.6] - 2024-05-13

* [Web] Some important fixes for web.

[0.10.5] - 2024-05-13

* [Android] fix: make MediaDeviceInfo (Audio deviceId, label, groupId) consistent. (#1583)

[0.10.4] - 2024-05-06

* [iOS/macOS] chore: update swift webrtc sdks to 114.5735.10 (#1576)
* [Android] fix: actually call selectAudioOutput in enableSpeakerButPreferBluetooth
* [iOS] fix: remember speakerphone mode for ensureAudioSession (#1568)
* [Windows/Linux] Fix handling of unimplemented method (#1563)

[0.10.3] - 2024-04-09

* [iOS/macOS] Fix compilation warning for iOS/macOS.

[0.10.2] - 2024-04-08

* [Native/Web] feat: add keyRingSize/discardFrameWhenCryptorNotReady to KeyProviderOptions.

[0.10.1] - 2024-04-08

* [Web] fix renderer issue for web.

[0.10.0] - 2024-04-08

* [Web] move to package:web.

[0.9.48+hotfix.1] - 2024-02-05

* [Android] bump version for libwebrtc.

[0.9.48] - 2024-02-05

* [Android] bump version for libwebrtc.
* [iOS] Supports ensureAudioSsession method for iOS only. (#1514)
* [Android] fix android wrong display size. (#1508).

[0.9.47] - 2023-11-29

* [Windows/Linux] fix: Check the invalid value of candidate and session description. (#1484)
* [Windows/Linux/macOS] fix: screen sharing issue for desktop.
* [Web] fix: platformViewRegistry getter is deprecated (#1485)
* [Dart] Throw exception for set src object (#1491).

[0.9.46] - 2023-10-25

* [iOS/macOS] fix: Crop video output size to target settings. (#1472)
* [Android] fix: Fix bluetooth sco not stopping after room disconnect (#1475)

[0.9.45] - 2023-09-27

* [iOS/macOS] fix: send message on non-platform thread.
* [Windows] fix: fix setSrcObj with trackId for Windows.
* [Windows] fix: fix "unlock of unowned mutex" error when call "captureFrame()" func on windows.

[0.9.44] - 2023-09-25

* [Windows] fix: fix Renderer bug for Windows.
* [Native] fix: Use independent threads to process frame encryption/decryption
* [Native] fix: Correct handle SIF frame
* [Native] fix: Fix a fault tolerance judgment failure

[0.9.43] - 2023-09-20

* [Native] fix: send frame cryptor events from signaling thread.
* [Native] fix: h264 freeze when using E2EE.

[0.9.42+hotfix.1] - 2023-09-15

* [Windows/Linux] fix: fix cannot start vp8/h264 encoder correctly.

[0.9.42] - 2023-09-15

* [Dart/Native] feat: add more framcryptor api (#1444)
* [Dart/Native] feat: support scalability mode (#1442)
* [Android] fix: Turn off audio routing in non communication modes (#1438)

* [Android] feat: Add more control over android audio options.

[0.9.41] - 2023-08-30

* [Android] feat: Add more control over android audio options.

[0.9.40] - 2023-08-16

* [Windows/Linux] fix: nullptr checking for sender/receiver for getStats.

[0.9.39] - 2023-08-14

* [Dart/Native] feat: add async methods for getting pc states.

[0.9.38] - 2023-08-11

* [Android] fix: Expose helper to clearCommunicationDevice on AudioManager.AUDIOFOCUS_LOSS
* [Android] feat: support force SW codec list for android, and disable HW codec for VP9 by default.
* [Android] fix: issue for audio device switch (#1417)
* [Android/iOS] feat: Added setZoom method to support camera zooming while streaming. (#1412).

[0.9.37] - 2023-08-07

* [Native] fix: Skip set_sdp_fmtp_line if sdpFmtpLine is empty.
* [Android] fix: fix android earpiece not being replaced after wired headset is disconnected.
* [Dart] fix: partially rebuild RTCVideoView when renderVideo value changes.
* [Android] feat: expose android audio modes.
* [Android] feat: support forceSWCodec for Android.
* [Linux] fix: add $ORIGIN to rpath.

[0.9.36] - 2023-07-13

* [Native] upgrade libwebrtc to m114.5735.02.
* [Windows/Linux] Add implementation to MediaStreamTrack.captureFrame() for linux/windows.
* [Darwin/Android] Support to ignore network adapters used for ICE on Android, iOS and macOS.

[0.9.35] - 2023-06-30

* [iOS] feat: expose audio mode for ios.
* [Darwin] fix: compiler warning for Darwin.
* [Dart] Fix setMicrophoneMute() not awaitable.
* [Native] Update libwebrtc to m114.
* [Dart/Web] Separate frame cryptor to dart-webrtc.

[0.9.34] - 2023-06-14

* [Web] fix facingMode for flutter web mobile.

[0.9.33] - 2023-06-08

* [Android] fix frame drops for android.

[0.9.32] - 2023-05-30

* [Android] fix issue for get user audio.
* [Android] fix getStats throw LinkedHasMap exception.

[0.9.31] - 2023-05-23

* [Darwin] Improve iOS/macOS H264 encoder (Upgrade to WebRTC-SDK M104.5112.17).

[0.9.30+hotfix.2] - 2023-05-18

* [Windows/Linux] fix bug for eventchannel proxy.
* [Windows/Linux] fix: crash for pc.close/dispose on win/linux. (#1360)

[0.9.30+hotfix.1] - 2023-05-17

* [Windows/Linux] Fix compiler error.

[0.9.30] - 2023-05-16

* [Darwin] Handle exceptions for frame rate settings for darinw. (#1351)
* [Android] Fix bluetooth device enumerate. (#1349)
* [Darwin/Android/Windows/Linux] Added maxIPv6Networks configuration (#1350)
* [iOS] Fix: broadcast extension not found fallback logic (#1347)
* [Android] Move the call of capturer.stopCapture() outside the main thread to avoid blocking of flutter method call.
* [Windows/Linux] Fix the crash issue of video room (#1343)

[0.9.29+hotfix.1] - 2023-05-08

* [Android] fix: application context null when app is terminated.
* [Android/iOS] feat: add way to enable speaker but prefer bluetooth.

[0.9.28] - 2023-05-08

* [Windows/Linux] fix: use the correct transceiver id.
* [Windows/Linux] fix: Support restart camera for Windows/Linux.

[0.9.27] - 2023-04-27

* [Darwin/Android/Windows/Linux] feat: framecryptor.
* [Windows/Linux] Fix the type/code mistake.
* [Windows/Linux] Fix uneffective RTPTransceiver::GetCurrentDirection.
* [Windows/Linux] RTPtransceiver::getCurrentDirection returns correct value.

[0.9.26] - 2023-04-16

* [iOS/macOS] motify h264 profile-level-id to support high resolution.
* [Dawrin/Android/Windows] feat: add RTCDegradationPreference to RTCRtpParameters.

[0.9.25] - 2023-04-10

* [Dawrin/Android/Windows] Add  `addStreams` to `RTCRtpSender`
* [Android] fix: label for Wired Headset. (#1305)
* [Dawrin/Android/Windows] Feat/media stream track get settings (#1294)
* [Android/iOS] Fix track lookup in the platform specific code for Android and iOS (#1289)
* [iOS] fix: ICE Connectivity doesn't establish with DualSIM iPhones.
* [Android] Switch to webrtc hosted on maven central (#1288)

[0.9.24] - 2023-03-07

* [iOS] avaudiosession mode changed to AVAudioSessionModeVideoChat (#1285)
* [macOS] fix memory leak for screen capture.

[0.9.23] - 2023-02-17

* [Windows/Linux] Updated libwebrtc binary for windows/linux to fix two crashes.

[0.9.22] - 2023-02-14

* [iOS] fix: Without any setActive for rtc session, libwebrtc manages the session counter by itself. (#1266)
* [dart] fix: remove rtpsender.dispose.
* [web] fix video renderer issue for safari.
* [macOS] Fixed macOS desktop capture crash with simulcast enabled.
* [macOS] Fix the crash when setting the fps of the virtual camera.

[0.9.21] - 2023-02-10

* [Web] Fix: RTCRtpParameters.fromJsObject for Firefox.
* [Web] Add bufferedamountlow.
* [Android] Fixed frame capturer returning images with wrong colors (#1258).
* [Windows] bug fix.

[0.9.20] - 2023-02-03

* [Dawrin/Android/Windows] Add getCapabilities/setCodecPreferences methods
* [Darwin] buffered amount
* [Linux] Fixed audio device name buffer size
* [Android] Start audioswitch and only activate it when needed
* [Darwin] Fix typo which broke GcmCryptoSuites

[0.9.19] - 2023-01-10

* [Dart] Fix getStats: change 'track' to 'trackId' (#1199)
* [Android] keep the audio switch after stopping (#1202)
* [Dart] Enhance RTC video view with placeholder builder property (#1206)
* [Android] Use forked version of audio switch to avoid BLUETOOTH_CONNECT permission (#1218)

[0.9.18] - 2022-12-12

* [Web] Bump dart_webrtc to 1.0.12, Convert iceconnectionstate to connectionstate for Firefox.
* [Android] Start AudioSwitchManager only when audio track added (fix #1163) (#1196)
* [iOS] Implement detachFromEngineForRegistrar (#1192)
* [iOS] Handle Platform Exception on addCandidate (#1190)
* [Native] Code format with clang-format.

[0.9.17] - 2022-11-28

* [Android] Update android webrtc version to 104.5112.05
* [iOS] Update WebRTC.xframework version to 104.5112.07

[0.9.16] - 2022-11-14

* [Linux] Fixed compiler error for flutter 3.3.8.
* [Linux] Remove 32-bit precompiled binaries.
* [Linux] Supports linux-x64 and linux-arm64.

[0.9.15] - 2022-11-13

* [Linux] Add Linux Support.

[0.9.14] - 2022-11-12

* [iOS] Fix setSpeakerOn has no effect after change AVAudioSession mode to playback.

[0.9.13] - 2022-11-12

* [Dart] Change MediaStream.clone to async.
* [iOS] Fixed the bug that the mic indicator light was still on when mic recording was stopped.
* [iOS/macOS/Android/Windows] Allow sdpMLineIndex to be null when addCandidate.
* [macOS] Frame capture support for MacOS.
* [Android] Add enableCpuOveruseDetection configuration (#1165).
* [Android] Update comments (#1164).

[0.9.12] - 2022-11-02

* [iOS] Fixed the problem that iOS earphones and speakers do not switch.
* [Windows] fix bug for rtpSender->RemoveTrack/pc->getStats.
* [iOS] Return groupId.
* [Web] MediaRecorder.startWeb() should expose the timeslice parameter.
* [iOS] Implement RTCPeerConnectionDelegate didRemoveIceCandidates method.
* [iOS] fix disposing Broadcast Sharing stream.

[0.9.11] - 2022-10-16

* [iOS] fix audio route/setSpeakerphoneOn issues.
* [Windows] fix: Have same remote streams id then found wrong MediaStream.
* [Dart] feat: RTCVideoRenderer supports specific trackId when setting MediaStream.

[0.9.9+hotfix.1] - 2022-10-12

* [Darwin] Fix getStats for darwin when trackId is NSNull.

[0.9.9] - 2022-10-12

* [Darwin/Android/Windows] Support getStats for RtpSender/RtpReceiver (Migrate from Legacy to Standard Stats for getStats).
* [Android] Dispose streams and connections.
* [Android] Support rtp transceiver direction type 4.
* [Web] Update dart_webrtc dependendency.

[0.9.8] - 2022-09-30

* [Android] fix: Make sure local stream/track dispose correctly.
* [Android] Remove bluetooth permission on peerConnectionInit.
* [iOS] Fix system sound interruption on iOS (#1099).
* [Android] Fix: call mode on app start (#1097).
* [Dart] Avoid renderer initialization multiple times (#1067).

[0.9.7] - 2022-09-13

* [Windows] Support sendDtmf.
* [Windows] Fixed getStats.

[0.9.6] - 2022-09-06

* [Dart] The dc created by didOpenDataChannel needs to set state to open.
* [Dart] Added callback onFirstFrameRendered.

[0.9.5] - 2022-08-30

* [Android] fix: Fix crash when using multiple renderers.
* [Android] fix bug with track dispose cannot close video
* [Andorid/iOS/macOS/Windows] Fix bug of missing events in data-channel.

[0.9.4] - 2022-08-22

* [Andorid/iOS/macOS/Windows] New audio input/output selection API, ondevicechange event is used to monitor audio device changes.

[0.9.3] - 2022-08-15

* [Windows/macOS] Fix UI freeze when getting thumbnails.

[0.9.2] - 2022-08-09

* [Android] update libwebrtc to com.github.webrtc-sdk:android:104.5112.01.
* [iOS/macOS] update WebRTC-SDK to 104.5112.02.
* [Windows] update libwebrtc.dll to 104.5112.02.

[0.9.1] - 2022-08-01

* [iOS] fix : iOS app could not change camera resolutions cause by wrong datatype in the video Contraints.
* [Darwin] bump version for .podspec.

[0.9.0] - 2022-07-27

* [macOS] Added screen-sharing support for macOS
* [Windows] Added screen-sharing support for Windows
* [iOS/macOS] fix: Fix compile warning for Darwin
* [Darwin/Android/Windows] fix: Fix typo peerConnectoinEvent -> peerConnectionEvent for EventChannel name (#1019)

[0.8.12] - 2022-07-15

* [Darwin]: fix: camera release.

[0.8.11] - 2022-07-11

* [Windows] Fix variant exception of findLongInt. (#990)
* [Windows] fix unable to get username/credential when parsing iceServers containing urls
* [iOS] Fix RTCAudioSession properties set with libwebrtc m97, Fixes #987.

[0.8.10] - 2022-06-28

* [iOS] IPC Broadcast Upload Extension support for Screenshare

[0.8.9] - 2022-06-08

* [Android] Fixes DataChannel issue described in #974
* [iOS] Fixes DataChannel issue described in #974
* [Dawrin/Android/Windows] Split data channel's webrtc id from our internal id (#961)
* [Windows] Update to m97.
* [Windows] Add PeerConnectionState
* [Windows] Fix can't open mic alone when built-in AEC is enabled.

[0.8.8] - 2022-05-31

* [Android] Added onBufferedAmountChange callback which will return currentBuffer and changedBuffer and implemented bufferedAmount.
* [Android] Added onBufferedAmountLow callback which will return currentBuffer ans will be called if bufferedAmountLowThreshold is set a value.

[0.8.7] - 2022-05-18

* [iOS/macOS] fix: Use RTCYUVHelper instead of external libyuv library (#954).
* [iOS/macOS] Flutter 3.0 crash fixes, setStreamHandler on main thread (#953)
* [Android] Use mavenCentral() instead of jcenter() (#952)
* [Windows] Use uint8_t* instead of string in DataChannel::Send method, fix binary send bug.
* [Android] fix: "Reply already submitted" error and setVolume() not working on remote streams.

[0.8.6] - 2022-05-08

* [Web/Android/iOS/macOS] Support null tracks in replaceTrack/setTrack.
* [macOS] Remove absolute path from resolved spec to make checksum stable.
* [Android] Android 12 bluetooth permissions.
* [Dart] fix wrong id type for data-channel.
* [Android] Release i420 Buffer in FrameCapturer.

[0.8.5] - 2022-04-01

* [Dart] Expose RTCDataChannel.id (#898)
* [Android] Enable H264 high profile for SimulcastVideoEncoderFactoryWrapper (#890)

[0.8.4] - 2022-03-28

* [Android] Fix simulcast factory not sending back EncoderInfo (#891)
* [Android] fix: correct misspell in method screenRequestPermissions (#876)

[0.8.3] - 2022-03-01

* [Android/iOS] Update android/ios webrtc native sdk versions.
* [Windows] Feature of selecting i/o audio devices by passing sourceId and/or deviceId constraints (#851).

[0.8.2] - 2022-02-08

* [Android/iOS/macOS/Web] Add restartIce.

[0.8.1] - 2021-12-29

* [Android/iOS] Bump webrtc-sdk version to 93.4577.01.

[0.8.0] - 2021-12-05

* [Dart] Refactor: Use webrtc interface. (#777)
* [iOS] Fix crashes for FlutterRPScreenRecorder stop.
* [Web] Don't stop tracks when disposing MediaStream (#760)
* [Windows] Add the necessary parameters for onRemoveTrack (#763)
* [Example] Properly start foreground service in example (#764)
* [Android] Fix crash for Android, close #757 and #734.
* [Dart] Fix typo in deprecated annotations.
* [iOS] Fix IOS captureFrame and add support for remote stream captureFrame (#778)
* [Windows] Fix parsing stun configuration (#789)
* [Windows] Fix mute (#792)
* [iOS/Android/Windows] New video constraints syntax (#790)

[0.7.1] - 2021-11-04

* [iOS/macOS] Update framework.
* [Android] Update framework.
* [Windows] Implement mediaStreamTrackSetEnable (#756).
* [iOS/macOS] Enable audio capture when acquiring track.
* [Android] Call stopCaptureWithCompletionHandler instead (#748)
* [Windows] Fix bug for windows.

[0.7.0+hotfix.2] - 2021-10-21

* [iOS/macOS] Update .podspec for Darwin.

[0.7.0+hotfix.1] - 2021-10-21

* [Android] Fix bug for createDataChannel.

[0.7.0] - 2021-10-20

* [Android] Enable Android simulcast (#731)
* [macOS] Use pre-compiled WebRTC for macOS. (#717)
* [iOS/macOS] Fix the correct return value of createDataChannel under darwin.
* [Windows] Fix using the wrong id to listen datachannel events.
* [Dart] Fix(mediaStreamTrackSetEnable): remote track is unavaiable (#723).

[0.6.10+hotfix.1] - 2021-10-01

* [Web] Fix compiler errors for web.

[0.6.10] - 2021-10-01

* [iOS] Fix bug for RtpTransceiver.getCurrentDirection.
* [Dart] Improve MethodChannel calling.

[0.6.9] - 2021-10-01

* [iOS] Update WebRTC build (#707).
* [Windows] Add Unified-Plan support for windows. (#688)
* [iOS] Improve audio handling on iOS (#705)

[0.6.8] - 2021-09-27

* [Android] Use ApplicationContext to verify permissions when activity is null.
* [iOS] Add support for lightning microphone. (#693)
* [Windows] Fix FlutterMediaStream::GetSources.
* [Web] Fix Flutter 2.5.0 RTCVideoRendererWeb bug (#681)
* [Web] Bug fix (#679)

[0.6.7] - 2021-09-08

* [Android] upgrade webrtc sdk to m92.92.4515.
* [Web] `addTransceiver` bug fix (#675)
* [Web] Use low-level jsutil to call createOffer/createrAnswer to solve the issue on safari/firefox.
* [Dart] Fix currentDirection/direction implementation confusion.

[0.6.6] - 2021.09.01

* [Sponsorship] Thanks for LiveKit sponsorship.
* [Web] Avoid removing all audio elements when stopping a single video renderer (#667)
* [Web] Properly cleanup srcObject to avoid accidental dispose
* [Dart] Removed warnings (#647)
* [Web] Switch transferFromImageBitmap to be invoked using js.callMethod (#631)
* [Web] Fix sending binary data over DataChannel in web implementation. (#634)
* [Darwin] Nullable return for GetLocalDescription/GetRemoteDiscription
* [Darwin] Fix incorrect argument name at RTCRtpSender (#600)

[0.6.5] - 2021.06.18

* [Android] Falling back to the first available camera fix #580
* [Android] Fix application exit null-pointer exception (#582)
* [Dart] Add label getter to DataChannel Interface (#585)
* [Dart] Fix exception raised at RTCPeerConnection.removeTrack and RTCRtpSender.setParameters (#588)
* [Dart] Fix: null check (#595)
* [Dart] Fix: null check for RTCRtpTransceiverNative.fromMap

[0.6.4] - 2021.05.02

* [Android] Fix getting screen capture on Huawei only successful in the first time. (#523)
* [Android] Add configuration "cryptoOptions" in parseRTCConfiguration().
* [Dart] Change getLocalDescription,getRemoteDescription,RTCRtpSenderWeb.track returns to nullable.
* [Dart] Fixed bug in RTCPeerConnectionWeb.removeTrack.
* [Dart] Change MediaStreamTrack.captureFrame returns to ByteBuffer to compatible with web API.
* [Dart]  Do null safety check in onRemoveStream,onRemoveTrack and MediaStream.getTrackById.
* [Android] Add reStartCamera method when the camera is preempted by other apps.
* [Web] Refactored RTCVideoRendererWeb and RTCVideoViewWeb, using video and audio HTML tags to render audio and video streams separately.

[0.6.3] - 2021.04.03

* [Dart] Change RTCRtpSender.track to nullable.
* [Web] Fix RTCVideoView/Renderer pauses when changing child in IndexedStack.

[0.6.2] - 2021.04.02

* [Dart] Use enumerateDevices instead of getSources.
* [Android] Use flutter_background to fix screen capture example.

[0.6.1] - 2021.04.02

* [Darwin] Fixed getting crash when call setLocalDescription multiple time.
* [Dart] Get more pub scores.

[0.6.0] - 2021.04.01

* [Sponsorship] Thanks for Stream sponsorship (#475)
* [Android] Fixed a crash when switching cameras on Huawei devices.
* [Windows] Correct signalingState & iceConnectionState event name on Windows. (#502)
* [Dart] Clip behaviour. (#511)
* [Dart] null-safety (@wer-mathurin Thanks for the hard work).
* [Dart] Fix setMicrophoneMute (#466)
* [Web] Fix pc.addTransceiver method, fix RTCRtpMediaType to string, fix (#437)
* [Android] fix sdpSemantics issue (#478)

[0.6.0-nullsafety.0] - 2021.03.22

* [Dart] null-safety (@wer-mathurin Thanks for the hard work).

[0.5.8] - 2021.01.26

* [Web] Support selecting audio output.
* [Web] Fix issue for getDisplayMedia with audio.
* [Windows] Add Windows Support.
* [macOS] Fix compile error for macos.
* [Dart] Add FilterQuality to RTCVideoView.
* [iOS/Android] Unified plan gettracks.
* [iOS/Android] Bluetooth switching enabled when switching `enableSpeakerphone` value (if they are connected). #201 (#435)
* [Android] Increase necessary Android min SDK version after add Unified-Plan API.

[0.5.7] - 2020.11.21

* [Web] Fix events callback for peerconnection.

[0.5.6] - 2020.11.21

* [Android/Darwin/Web] Add onResize event for RTCVideoRenderer.

[0.5.5] - 2020.11.21

* [Android/Darwin] Fix Simulcast issue.

[0.5.4] - 2020.11.21

* [Native/Web] Add videoWidth/videoHeight getter for RTCVideoRenderer.
* [Web] Add optional parameter track to call getStats.

[0.5.3] - 2020.11.21

* Fix bug.

[0.5.2] - 2020.11.19

* Improve web code

[0.5.1] - 2020.11.19

* Improve unfied-plan API for web.
* Add getTransceivers,getSenders, getReceivers methods.

[0.5.0+1] - 2020.11.18

* Remove dart-webrtc and reuse the code in dart:html
  because the code generated by package:js cannot be run in dart2js.

[0.5.0] - 2020.11.15

* [Web] Add Unified-Plan for Flutter Web.
* [Web] Add video frame mirror support for web.
* [Web] Support Simulcast for web.
* [Web] Use dart-webrtc as flutter web plugin.
* [Android/Darwin] Fix crash when unset streamIds in RtpTransceiverInit.
* [Dart]Change the constraints of createOffer/createAnswer as optional.
* [iOS]Fix adding track to stream igal committed (#413)

[0.4.1] - 2020.11.11

* Add transceiver to onTrack events.
* Remove unnecessary log printing.
* Fixed a crash caused by using GetTransceivers under non-unified-plan,
  close #389.
* FIX - Invalid type inference (#392)
* [Web]Add onEnded and onMuted for Web (#387)
* [Darwin]Fix PeerConnectionState for darwin.
* [Darwin] Fix compilation warning under darwin.
* [Android] Fixed 'Sender is null' issue when removing track. (#401)
* [iOS] fix removeTrack methodChannel response, onTrack's `stream` and `track` not being registered in native.
* [Darwin/Android] `RtpSender` `setParameters` functionality.

[0.4.0] - 2020.10.14

* Support Unified-Plan for Android/iOS/macOS.
* Add PeerConnectionState and add RTCTrackEvent..
* [Android] Upgrade GoogleWebRTC@android to 1.0.32006.
* [iOS] Upgrade GoogleWebRTC@ios to 1.1.31999.
* Api standardization across implementation (#364), thanks @wer-mathurin.

[0.3.3] - 2020.09.14

* Add RTCDTMFSender for mobile, web and macOS.
* Improve RenegotiationNeededCallback.
* Refactor RTCVideoView for web and solve the resize problem.
* Reduce code size.

[0.3.2] - 2020.09.11

* Reorganize the directory structure.
* Replace class name navigator to MediaDevices.
* Downgrade pedantic version to 1.9.0.

[0.3.1] - 2020.09.11

* [Dart] Apply pedantic linter and more rigorous analysis options.

[0.3.0+1] - 2020.09.06

* [Dart] FIX - missing null check onIceGatheringState (web)

[0.3.0] - 2020.09.05

* [Dart] Improve RTCVideoView.
* [Android] Refactors Android plugin alongside the embedding V2 migration.
* [Dart] Fix .ownerTag not defined for web.
* [Dart] Added label as read only property.
* [macOS] Updated WebRTC framework to work with AppStoreConnect.
* [Dart] Make 'constraints' argument optional.
* [Dart] Make createOffer constraints optional.
* [iOS/Android/Web] Adding createLocalMediaStream method to PeerConnectionFactory.
* [Web] Fixing multiple video renderers on the same HTML page for Flutter Web.
* [iOS] Add peerConnectionId to data channel EventChannel.
* [Android] Add library module ProGuard configuration file.
* [iOS] Fix typo in render size change check condition
* [README] Add missed Android usage hint.

[0.2.8] - 2020.04.22

* [macOS/iOS] Fix typo in render size change check condition.
* [macOS] Fix hot restart videoCapturer crash.
* [Android] Fix Android crash when getUserVideo.

[0.2.7] - 2020.03.15

* [macOS] Fix crash with H264 HW Encoder.
* [Web] Add addTransceiver API.
* [Android] Removed duplicate method that was causing compilation error.
* [iOS] Use MrAlek Libyuv pod fixing incompatibility with FirebaseFirestore.
* [iOS] Upgrade GoogleWebRTC dependency to 1.1.29400.

[0.2.6] - 2020.02.03

* Fixed the interruption of the Bluetooth headset that was playing music after the plugin started.

[0.2.4] - 2020.02.03

* Fixed bug.

[0.2.3] - 2020.02.03

* Fixed bug for enableSpeakerphone (Android/iOS).
* Fix RtcVideoView not rebuild when setState called and renderer is changed.
* Fix Android frame orientation.

[0.2.2] - 2019.12.13

* Removed the soft link of WebRTC.framework to fix compile errors of macos version when third-party flutter app depends on plugins

[0.2.1] - 2019.12.12

* Code format.
* Remove unused files.

[0.2.0] - 2019.12.12

* Add support for macOS (channel dev).
* Add support for Flutter Web (channel dev).
* Add hasTorch support for Android (Camera2 API) and iOS.
* Fix(PeerConnections) split dispose and close
* Add microphone mute support for Android/iOS.
* Add enable speakerphone support for Android/iOS.
* Fix 'createIceServer' method Invalid value error (Android).
* Store SignalingState/IceGatheringState/IceConnectionState in RTCPeerConnection.
* Fixed rendering issues caused by remote MediaStream using the same msid/label when using multiple PeerConntions.

[0.1.7] - 2019.05.16

* Add RTCDataChannelMessage for data channel and remove base64 type.
* Add streaming API for datachannel messages and state changes.
* Remove cloudwebrtc prefix in the plugin method/event channel name.
* Other bug fixes.

[0.1.6] - 2019.03.31

* Add getConfiguration/setConfiguration methods for Peerconnection.
* Add object fit for RTCVideoView.

[0.1.5] - 2019.03.27

* Remove unnecessary parameter for getLocalDescription method.

[0.1.4] - 2019.03.26

* switchCamera method now returns future with isFrontCamera as result
* Fix camera stuck in rare cases
* Add getLocalDescription/getRemoteDescription methods

[0.1.3] - 2019.03.25

* Add horizontal flip (mirror) function for RTCVideoView.
* Fixed ScreenCapture preview aspect ratio for Android.

[0.1.2] - 2019.03.24

* Fix compilation failure caused by invalid code.

[0.1.1] - 2019.03.24

* Migrated to AndroidX using Refactoring from Andoid Studio
* Fix mediaStreamTrackSetEnable not working.
* Fix iOS can't render video when resolution changes.
* Some code style changes.

[0.1.0] - 2019.01.21

* Fix camera switch issues.
* Support data channel, please use the latest demo to test.
* Support screen sharing, but the work is not perfect, there is a problem with the local preview.

[0.0.3] - 2018.12.20

* Update WebRTC to 1.0.25821.
* Implemented MediaStreamTrack.setVolume().
* Add public getter for texture id.
* Fixed getUserMedia does not work for capturing audio only.

[0.0.2] - 2018.11.04

* Add 'enabled' method for MediaStreamTrack.
* Implement switch camera.
* Add arm64-v8a and x86_64 architecture support for android.

[0.0.1] - 2018.05.30

* Initial release.
