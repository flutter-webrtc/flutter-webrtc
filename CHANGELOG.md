## Changelog

--------------------------------------------
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
