# Changelog

--------------------------------------------
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
